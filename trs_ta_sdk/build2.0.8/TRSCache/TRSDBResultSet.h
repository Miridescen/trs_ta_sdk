//
//  TRSDBResultSet.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/22.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
NS_ASSUME_NONNULL_BEGIN

@interface TRSDBResultSet : NSObject

+ (instancetype)resultSetWithStatement:(sqlite3_stmt *)statement currentDB:(sqlite3 *)currentDB;

@property (atomic) sqlite3 *current_sqlite;

@property (atomic, strong, nullable) NSString *query;

@property (atomic, assign) sqlite3_stmt *statement;

@property (readonly) NSMutableDictionary *columnNameToIndexMap;

- (void)close;

- (BOOL)next;

- (int)intForColumn:(NSString*)columnName;
- (long)longForColumn:(NSString*)columnName;
- (long long int)longLongIntForColumn:(NSString*)columnName;
- (unsigned long long int)unsignedLongLongIntForColumn:(NSString*)columnName;
- (BOOL)boolForColumn:(NSString*)columnName;
- (double)doubleForColumn:(NSString*)columnName;
- (NSString * _Nullable)stringForColumn:(NSString*)columnName;
- (NSData * _Nullable)dataForColumn:(NSString *)columnName;



@end
NS_ASSUME_NONNULL_END
