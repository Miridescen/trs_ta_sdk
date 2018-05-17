//
//  TRSDBManager3.m
//  TRSAnalytics
//
//  Created by 824810056 on 2018/3/28.
//  Copyright © 2018年 Miridescent. All rights reserved.
//

#import "TRSDBManager3.h"
#import "TRSBaseModel.h"
#import "TRSDBBase.h"
#import "TRSCommen.h"
#import "TRSDBResultSet.h"
@interface TRSDBManager3()

@property (nonatomic, strong) TRSDBBase *DBBase;

@end
@implementation TRSDBManager3
/**
 使用单利，单利创建的时候就生成了四张用来存取数据的数据库表格，分别是系统事件（systemEventDB）、上传系统事件失败（sendSystemEventDefaultDB）、自定义事件（customEventDB）、上传自定义时间失败（sendCustomEventDefaultDB）
 
 @return 单利
 */
+ (TRSDBManager3 *)sharedManager{
    static TRSDBManager3 *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TRSDBManager3 alloc] init];
    });
    return manager;
}
// ------------CommonMethod----------

/**
 通用方法，插入一条数据，根据数据类型，方法内部会将数据插入到对应的表中
 
 @param model 数据model
 */
- (BOOL)managerInsertOneDataWithDataModel:(TRSBaseModel *)model{
    if (model == nil){
        TRSNSLog(@"TRSDBManager 传入的model不能为nil");
        return NO;
    }
    BOOL result = NO;
    TRSBaseModel *baseModel = (TRSBaseModel *)model;
    
    result = [self.DBBase insertDataWithSqlStr:@"insert into totalEvent(jsonData,createAt) values (?,?)",
              baseModel.jsonData,
              baseModel.createAt];
    return result;
}

/**
 通用方法，插入一批数据，根据数据类型，方法内部会将数据插入到对应的表中
 
 @param modelArray 数据Array
 @return 是否插入成功
 */
- (BOOL)managerInsertDataWithDataModelArray:(NSArray<TRSBaseModel *> *)modelArray{
    if (modelArray.count == 0 || modelArray == nil) {
        return YES;
    }
    BOOL result = NO;
    @try{
        char *errorMsg;
        if (sqlite3_exec([self.DBBase db], "BEGIN", nil, nil, &errorMsg) == SQLITE_OK) {
            
            sqlite3_free(errorMsg);
            
            for (TRSBaseModel *model in modelArray) {
                TRSBaseModel *baseModel = (TRSBaseModel *)model;
                [self.DBBase insertDataWithSqlStr:@"insert into totalEvent(jsonData,createAt) values (?,?)",
                 baseModel.jsonData,
                 baseModel.createAt];
                
            }
            if (sqlite3_exec([self.DBBase db], "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK) {
                result = YES;
            }
            sqlite3_free(errorMsg);
            
        } else {
            sqlite3_free(errorMsg);
        }
        
    }
    @catch(NSException *e){
        char *errorMsg;
        if (sqlite3_exec([self.DBBase db], "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK) {
            TRSNSLog(@"TRSDBManager 回滚事务成功");
        }
        sqlite3_free(errorMsg);
    }
    @finally{
    }
    
    return result;
}

/**
 通用方法，删除一条数据，根据数据类型，方法内部会将数据插入到对应的表中
 
 @param model 数据model
 @return bool 是否删除成功
 */
- (BOOL)managerDeleteOneDataWithDataModel:(TRSBaseModel *)model{
    if (model == nil){
        TRSNSLog(@"TRSDBManager 传入的model不能为nil");
    }
    BOOL result = NO;
    TRSBaseModel *baseModel = (TRSBaseModel *)model;
    result = [self.DBBase deleteDataWithSqlStr:@"delete from totalEvent where createAt = ? ", baseModel.createAt];
    return result;
}

/**
 通用方法， 清空某个数据库
 
 @param modelArray 要删除的数据数组(当modelArray为nil的时候，删除所有数据)
 @return 是否清空成功
 */
- (BOOL)managerDeleteDataWithDataModelArray:(NSArray<TRSBaseModel *> *)modelArray{
    BOOL result = NO;
    NSString *sqlStr;
    if (modelArray == nil) {
        sqlStr = @"delete from totalEvent";
        result = [self.DBBase deleteDataWithSqlStr:sqlStr];
        if (result) {
            [self.DBBase cleanSeqWithSqlStr:@"UPDATE sqlite_sequence set seq = 0 where name='totalEvent'"];
        }
    } else {
        
        @try{
            char *errorMsg;
            if (sqlite3_exec([self.DBBase db], "BEGIN", nil, nil, &errorMsg) == SQLITE_OK) {
                
                sqlite3_free(errorMsg);
                
                for (TRSBaseModel *model in modelArray) {
                    [self.DBBase deleteDataWithSqlStr:@"delete from totalEvent where createAt = ?", model.createAt];
                    
                }
                if (sqlite3_exec([self.DBBase db], "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK) {
                    result = YES;
                }
                sqlite3_free(errorMsg);
                
            } else {
                sqlite3_free(errorMsg);
            }
            
        }
        @catch(NSException *e){
            char *errorMsg;
            if (sqlite3_exec([self.DBBase db], "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK) {
                TRSNSLog(@"TRSDBManager 回滚事务成功");
            }
            sqlite3_free(errorMsg);
        }
        @finally{
        }
        
    }
    return result;
}

/**
 通用方法，根据类型获取当前库中所有数据
 
 @oaram count 取出的数据条数（当count传入0的时候取出所有数据）
 @return 数据数组
 */
- (NSArray *)managerGetDataWithDataCount:(NSInteger)count{
    NSMutableArray *arr = [@[] mutableCopy];
    NSString *sqlStr;
    if (count == 0) {
        sqlStr = @"select *from totalEvent";
    } else {
        sqlStr = [NSString stringWithFormat:@"select *from totalEvent order by id limit %ld", (long)count];
    }
    TRSDBResultSet *resultSet = [self.DBBase getDataWithSqlStr:sqlStr];
    while ([resultSet next]) {
        TRSBaseModel *model = [[TRSBaseModel alloc] init];
        model.jsonData     = [resultSet dataForColumn:@"jsonData"];
        model.createAt = [resultSet stringForColumn:@"createAt"];
        
        [arr addObject:model];
        
    }
    [resultSet close];
    return arr;
}


/**
 通用方法，获取当前类型数据的总条数
 
 @return 数据条数
 */
- (NSInteger)managerGatDataTotalCount{
    NSInteger totalCount = 0;
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT COUNT(*) FROM totalEvent"];
    totalCount = [self.DBBase getDataCountWithSqlStr:sqlStr];
    return totalCount;
}
- (instancetype) init{
    self = [super init];
    if (self) {
        self.DBBase = [TRSDBBase sharedManager];
        
    }
    return self;
}
@end
