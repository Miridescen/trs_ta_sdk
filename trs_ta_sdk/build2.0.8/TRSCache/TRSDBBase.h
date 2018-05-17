//
//  TRSDBBase.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/20.
//  Copyright © 2017年 牟松. All rights reserved.
//  提供数据库的基本操作方法

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@class TRSDBResultSet;
@interface TRSDBBase : NSObject



+ (TRSDBBase *)sharedManager;
- (sqlite3 *)db;
- (BOOL)open;
- (BOOL)close;
- (BOOL)insertDataWithSqlStr:(NSString *)sqlStr,...;
- (BOOL)deleteDataWithSqlStr:(NSString *)sqlStr,...;
- (TRSDBResultSet *)getDataWithSqlStr:(NSString *)sqlStr,...;
- (BOOL)cleanSeqWithSqlStr:(NSString *)sqlStr,...;
- (NSInteger)getDataCountWithSqlStr:(NSString *)sqlStr,...;

@end
