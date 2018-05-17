//
//  TRSDBBase.m
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/20.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import "TRSDBBase.h"
#import "TRSCommen.h"
#import "TRSDBResultSet.h"



@interface TRSDBBase()
{
    NSString *_DBPath;
    dispatch_queue_t _ioQueue;
    sqlite3 *_db;
}
@end

@implementation TRSDBBase
+ (TRSDBBase *)sharedManager{
    static TRSDBBase *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TRSDBBase alloc] init];
    });
    return manager;
}
#pragma mark -- publicMethod
- (sqlite3 *)db{
    return _db;
}
- (BOOL)open {
    if (_db) {
        return YES;
    }
    
    int result = sqlite3_open([NSString stringWithFormat:@"%@TRSDB.sqlite", _DBPath].UTF8String, (sqlite3**)&_db );
    if(result != SQLITE_OK) {
        TRSNSLog(@"TRSDBManager 打开数据库失败: %d", result);
        return NO;
    }
    
    return YES;
}
- (BOOL)close {
    
    if (!_db) {
        return YES;
    }
    
    int  rc;
    BOOL retry;
    BOOL triedFinalizingOpenStatements = NO;
    
    do {
        retry   = NO;
        rc      = sqlite3_close(_db);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(_db, nil)) !=0) {
                    sqlite3_finalize(pStmt);
                    retry = YES;
                }
            }
        }
        else if (SQLITE_OK != rc) {
            TRSNSLog(@"TRSDBManager 数据库关闭出错!: %d", rc);
        }
    }
    while (retry);
    
    _db = nil;
    return YES;
}
- (BOOL)insertDataWithSqlStr:(NSString *)sqlStr,...{
    if (TRSBlankStr(sqlStr)) {
        TRSNSLog(@"TRSDBManager 插入SQL语句不能为nil");
        return NO;
    }
    BOOL result = NO;
    if ([self open]) {
        va_list args;
        va_start(args, sqlStr);
        result = [self executeWithSql:sqlStr args:args];
        va_end(args);
    } else {
        TRSNSLog(@"TRSDBManager 打开数据库失败");
        return NO;
    }

    return result;
}
- (BOOL)deleteDataWithSqlStr:(NSString *)sqlStr,...{
    if (TRSBlankStr(sqlStr)) {
        TRSNSLog(@"TRSDBManager 删除SQL语句不能为nil");
        return NO;
    }
    BOOL result = NO;
    if ([self open]) {
        va_list args;
        va_start(args, sqlStr);
        result = [self executeWithSql:sqlStr args:args];
        va_end(args);
    } else {
        TRSNSLog(@"TRSDBManager 打开数据库失败");
        return NO;
    }
    return result;
}
- (BOOL)cleanSeqWithSqlStr:(NSString *)sqlStr,...{
    if (TRSBlankStr(sqlStr)) {
        TRSNSLog(@"TRSDBManager 清除seq语句不能为nil");
        return NO;
    }
    
    BOOL result = NO;
    if ([self open]) {
        va_list args;
        va_start(args, sqlStr);
        result = [self executeWithSql:sqlStr args:args];
        va_end(args);
    } else {
        TRSNSLog(@"TRSDBManager 打开数据库失败");
        return NO;
    }
    
    return result;
}
- (TRSDBResultSet *)getDataWithSqlStr:(NSString *)sqlStr,...{
    if (TRSBlankStr(sqlStr)) {
        TRSNSLog(@"TRSDBManager 清除seq语句不能为nil");
        return nil;
    }
    TRSDBResultSet *result;
    if ([self open]) {
        va_list args;
        va_start(args, sqlStr);
        result = [self executeQueryWithSql:sqlStr args:args];
        va_end(args);
    } else {
        TRSNSLog(@"TRSDBManager 打开数据库失败");
        return nil;
    }
    
    return result;
}
- (NSInteger)getDataCountWithSqlStr:(NSString *)sqlStr,...{
    if (TRSBlankStr(sqlStr)) {
        TRSNSLog(@"TRSDBManager 查找数据条数语句不能为nil");
        return 0;
    }
    int totalCount = 0;
    if ([self open]) {
        va_list args;
        va_start(args, sqlStr);
        TRSDBResultSet *result = [self executeQueryWithSql:sqlStr args:args];
        va_end(args);
        if ([result next]) {
            totalCount = sqlite3_column_int(result.statement, 0);
        }
        [result close];
    } else {
        TRSNSLog(@"TRSDBManager 打开数据库失败");
        return 0;
    }
    
    
    return totalCount;
}
#pragma mark -- private method
- (id)executeQueryWithSql:(NSString *)sql args:(va_list)args{
    if (TRSBlankStr(sql)) {
        return nil;
    }
    int rc                   = 0x00;
    sqlite3_stmt *pStmt      = 0x00;
    TRSDBResultSet *rs       = 0x00;
    if (!pStmt) {
        rc = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, 0);
        
        if (SQLITE_OK != rc) {
            sqlite3_finalize(pStmt);
            return nil;
        }
    }
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(pStmt);
    while (idx < queryCount) {
        obj = va_arg(args, id);
        idx++;
        [self bindObject:obj toColumn:idx inStatement:pStmt];
    }
    rs = [TRSDBResultSet resultSetWithStatement:pStmt currentDB:self->_db];
    return rs;
}
// 执行SQL语句
- (BOOL)executeWithSql:(NSString *)sql args:(va_list)args {
    if (TRSBlankStr(sql)) {
        return NO;
    }
    int rc                   = 0x00;
    sqlite3_stmt *pStmt      = 0x00;
    if (!pStmt) {
        rc = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, 0);
        
        if (SQLITE_OK != rc) {
            sqlite3_finalize(pStmt);
            return NO;
        }
    }
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(pStmt);
    while (idx < queryCount) {
        obj = va_arg(args, id);
        idx++;
        [self bindObject:obj toColumn:idx inStatement:pStmt];
    }
    rc = sqlite3_step(pStmt);
    sqlite3_finalize(pStmt);
    return (rc == SQLITE_DONE || rc == SQLITE_OK);
    
}
- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt {
    
    if ((!obj) || ((NSNull *)obj == [NSNull null])) {
        sqlite3_bind_null(pStmt, idx);
    }
    
    // FIXME - someday check the return codes on these binds.
    else if ([obj isKindOfClass:[NSData class]]) {
        const void *bytes = [obj bytes];
        if (!bytes) {
            // it's an empty NSData object, aka [NSData data].
            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
            bytes = "";
        }
        sqlite3_bind_blob(pStmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        
        if (strcmp([obj objCType], @encode(char)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj charValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned char)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj unsignedCharValue]);
        }
        else if (strcmp([obj objCType], @encode(short)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj shortValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned short)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj unsignedShortValue]);
        }
        else if (strcmp([obj objCType], @encode(int)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj intValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned int)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedIntValue]);
        }
        else if (strcmp([obj objCType], @encode(long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongValue]);
        }
        else if (strcmp([obj objCType], @encode(long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongLongValue]);
        }
        else if (strcmp([obj objCType], @encode(float)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj floatValue]);
        }
        else if (strcmp([obj objCType], @encode(double)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        else if (strcmp([obj objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
        }
        else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    else {
        sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
}

- (instancetype) init{
    self = [super init];
    if (self) {
        
        NSString *documentDicPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _DBPath = [documentDicPath stringByAppendingString:@"/TRSFile/TRSDB/"];
        if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:_DBPath] )
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:_DBPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        _ioQueue = dispatch_queue_create("com.TRS.DB", DISPATCH_QUEUE_SERIAL);
        TRSNSLog(@"TRSDBManager  DBPath = %@",_DBPath);
        if ([self open]) {
            [self createDB];
        }
        
    }
    return self;
}
- (void)createDB{
    // system_Launch时间
    /*
    NSString *systemEventTable = @"create table IF NOT EXISTS systemEvent (id integer PRIMARY KEY AUTOINCREMENT,mpId text, appkey text,pv text,nt text,carrier text,os text, ov text,UUID text,sv text,sh text,sw text, lang text,country text,av text,channel text,jb text, tz text,dm text,vt text,an text,e_key text, e_type text,e_dur text,bid text,se_vt text,se_no integer,se_code text, se_pt text,se_ot text,se_oid text,se_cid text,uid text, refer text,ip text,lng text,lat text,dur text, se_dur text,se_name text,se_ac text,se_osn text,se_oids text, se_csn text,se_sw text,se_oam integer,se_ono integer,se_pp float, se_su text,se_ex text,se_soid text,se_aoid text,se_ost text,mc text,vc text,uex text,aex text,ilurl text,un text,title text,createAt text)";
    NSString *systemEventTempTable = @"create table IF NOT EXISTS systemEventTemp (id integer PRIMARY KEY AUTOINCREMENT,mpId text, appkey text,pv text,nt text,carrier text,os text, ov text,UUID text,sv text,sh text,sw text, lang text,country text,av text,channel text,jb text, tz text,dm text,vt text,an text,e_key text, e_type text,e_dur text,bid text,se_vt text,se_no integer,se_code text, se_pt text,se_ot text,se_oid text,se_cid text,uid text, refer text,ip text,lng text,lat text,dur text, se_dur text,se_name text,se_ac text,se_osn text,se_oids text, se_csn text,se_sw text,se_oam integer,se_ono integer,se_pp float, se_su text,se_ex text,se_soid text,se_aoid text,se_ost text,mc text,vc text,uex text,aex text,ilurl text,un text,title text,createAt text)";
    NSString *pageEventTable = @"create table IF NOT EXISTS pageEvent (id integer PRIMARY KEY AUTOINCREMENT,mpId text, appkey text,pv text,nt text,carrier text,os text, ov text,UUID text,sv text,sh text,sw text, lang text,country text,av text,channel text,jb text, tz text,dm text,vt text,an text,e_key text, e_type text,e_dur text,bid text,se_vt text,se_no integer,se_code text, se_pt text,se_ot text,se_oid text,se_cid text,uid text, refer text,ip text,lng text,lat text,dur text, se_dur text,se_name text,se_ac text,se_osn text,se_oids text, se_csn text,se_sw text,se_oam integer,se_ono integer,se_pp float, se_su text,se_ex text,se_soid text,se_aoid text,se_ost text,mc text,vc text,uex text,aex text,ilurl text,un text,title text,createAt text)";
    NSString *pageEventTempTable = @"create table IF NOT EXISTS pageEventTemp (id integer PRIMARY KEY AUTOINCREMENT,mpId text, appkey text,pv text,nt text,carrier text,os text, ov text,UUID text,sv text,sh text,sw text, lang text,country text,av text,channel text,jb text, tz text,dm text,vt text,an text,e_key text, e_type text,e_dur text,bid text,se_vt text,se_no integer,se_code text, se_pt text,se_ot text,se_oid text,se_cid text,uid text, refer text,ip text,lng text,lat text,dur text, se_dur text,se_name text,se_ac text,se_osn text,se_oids text, se_csn text,se_sw text,se_oam integer,se_ono integer,se_pp float, se_su text,se_ex text,se_soid text,se_aoid text,se_ost text,mc text,vc text,uex text,aex text,ilurl text,un text,title text,createAt text)";
     */
//    NSArray *createTableArr = @[systemEventTable, systemEventTempTable, pageEventTable, pageEventTempTable];
    
//    NSString *totalEventTable = @"create table IF NOT EXISTS totalEvent (id integer PRIMARY KEY AUTOINCREMENT,mpId text, appkey text,pv text,nt text,carrier text,os text, ov text,UUID text,sv text,sh text,sw text, lang text,country text,av text,channel text,jb text, tz text,dm text,vt text,an text,e_key text, e_type text,e_dur text,bid text,se_vt text,se_no integer,se_code text, se_pt text,se_ot text,se_oid text,se_cid text,uid text, refer text,ip text,lng text,lat text,dur text, se_dur text,se_name text,se_ac text,se_osn text,se_oids text, se_csn text,se_sw text,se_oam integer,se_ono integer,se_pp float, se_su text,se_ex text,se_soid text,se_aoid text,se_ost text,mc text,vc text,uex text,aex text,ilurl text,un text,title text,createAt text)";
    
    NSString *totalEventTable = @"create table IF NOT EXISTS totalEvent (id integer PRIMARY KEY AUTOINCREMENT,jsonData BLOB,createAt text)";
    NSArray *createTableArr = @[totalEventTable];
    for (NSString *createTableSQL in createTableArr) {
        char *error;
        int result = sqlite3_exec(self->_db, createTableSQL.UTF8String, nil, nil, &error);
        if (result == SQLITE_OK) {
            TRSNSLog(@"TRSDBManager 创建表成功");
        } else {
            TRSNSLog(@"TRSDBManager  执行创建表语句失败\nerror == %s", error);
        }
        sqlite3_free(error);
    }
    
    
    /*   给表添加某一列
    NSString *addColumn = @"alter table 'pageEvent' add 'title' text";
    char *error;
    int result = sqlite3_exec(self->_db, addColumn.UTF8String, nil, nil, &error);
    if (result == SQLITE_OK) {
        TRSNSLog(@"TRSDBManager 添加列成功");
    } else {
        TRSNSLog(@"TRSDBManager  添加列失败\nerror == %s", error);
    }
    sqlite3_free(error);
     */
    
}


@end
