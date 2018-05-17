//
//  TRSDBResultSet.m
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/22.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import "TRSDBResultSet.h"
#import "TRSCommen.h"


@interface TRSDBResultSet()
{
    NSMutableDictionary *_columnNameToIndexMap;
}


@end

@implementation TRSDBResultSet

+ (instancetype)resultSetWithStatement:(sqlite3_stmt *)statement currentDB:(sqlite3 *)currentDB{
    
    TRSDBResultSet *resultSet = [[TRSDBResultSet alloc] init];
    [resultSet setStatement:statement];
    [resultSet setCurrent_sqlite:currentDB];
    return TRSDBReturnAutoreleased(resultSet);
}

- (void)close{
    if (_statement) {
        sqlite3_reset(_statement);
    }
    sqlite3_finalize(_statement);
    TRSDBRelease(_statement);
    _statement = nil;
    
}
- (BOOL)next{
    
    int rc = sqlite3_step(_statement);
    
    if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
        TRSNSLog(@"TRSDBResultSet  数据库忙");

    }
    else if (SQLITE_ERROR == rc) {
        TRSNSLog(@"TRSDBResultSet 执行sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg(_current_sqlite));

    }
    else if (SQLITE_MISUSE == rc) {
        TRSNSLog(@"TRSDBResultSet 执行sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg(_current_sqlite));
    }
    else if (SQLITE_DONE == rc || SQLITE_ROW == rc) {
    }
    else {
        TRSNSLog(@"TRSDBResultSet 未知错误 执行sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg(_current_sqlite));

    }
    if (rc != SQLITE_ROW) {
        if (_statement) {
            sqlite3_reset(_statement);
        }
    }
    
    
    return (rc == SQLITE_ROW);
}


- (int)intForColumn:(NSString*)columnName{
    return sqlite3_column_int(_statement, [self columnIndexForName:columnName]);
}
- (long)longForColumn:(NSString*)columnName{
    return (long)sqlite3_column_int64(_statement, [self columnIndexForName:columnName]);
}
- (long long int)longLongIntForColumn:(NSString*)columnName{
    return sqlite3_column_int64(_statement, [self columnIndexForName:columnName]);
}
- (unsigned long long int)unsignedLongLongIntForColumn:(NSString*)columnName{
    return (unsigned long long int)sqlite3_column_int64(_statement, [self columnIndexForName:columnName]);
}
- (BOOL)boolForColumn:(NSString*)columnName{
    return ([self intForColumn:columnName] != 0);
}
- (double)doubleForColumn:(NSString*)columnName{
    return sqlite3_column_double(_statement, [self columnIndexForName:columnName]);
}
- (NSString * _Nullable)stringForColumn:(NSString*)columnName{
    if (sqlite3_column_type(_statement, [self columnIndexForName:columnName]) == SQLITE_NULL || ([self columnIndexForName:columnName] < 0) || [self columnIndexForName:columnName] >= sqlite3_column_count(_statement)) {
        return nil;
    }
    
    const char *c = (const char *)sqlite3_column_text(_statement, [self columnIndexForName:columnName]);
    
    if (!c) {
        return nil;
    }
    return [NSString stringWithUTF8String:c];
}
- (NSData * _Nullable)dataForColumn:(NSString *)columnName{
    if (sqlite3_column_type(_statement, [self columnIndexForName:columnName]) == SQLITE_NULL || ([self columnIndexForName:columnName] < 0) || [self columnIndexForName:columnName] >= sqlite3_column_count(_statement)) {
        return nil;
    }
    
    const char *dataBuffer = sqlite3_column_blob(_statement, [self columnIndexForName:columnName]);
    int dataSize = sqlite3_column_bytes(_statement, [self columnIndexForName:columnName]);
    
    if (dataBuffer == NULL) {
        return nil;
    }
    
    return [NSData dataWithBytes:(const void *)dataBuffer length:(NSUInteger)dataSize];
}

#pragma mark -- private method
- (int)columnIndexForName:(NSString*)columnName {
    columnName = [columnName lowercaseString];
    
    NSNumber *n = [[self columnNameToIndexMap] objectForKey:columnName];
    
    if (n != nil) {
        return [n intValue];
    }
    
    TRSNSLog(@"TRSDBResultSet 没有找到columnName '%@'.", columnName);
    
    return -1;
}

- (NSMutableDictionary *)columnNameToIndexMap {
    
    if (!_columnNameToIndexMap) {
        int columnCount = sqlite3_column_count(_statement);
        _columnNameToIndexMap = [[NSMutableDictionary alloc] initWithCapacity:(NSUInteger)columnCount];
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            [_columnNameToIndexMap setObject:[NSNumber numberWithInt:columnIdx]
                                      forKey:[[NSString stringWithUTF8String:sqlite3_column_name(_statement, columnIdx)] lowercaseString]];
        }
    }
    return _columnNameToIndexMap;
}

@end
