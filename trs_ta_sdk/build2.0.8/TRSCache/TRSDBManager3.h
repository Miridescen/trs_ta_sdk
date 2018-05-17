//
//  TRSDBManager3.h
//  TRSAnalytics
//
//  Created by 824810056 on 2018/3/28.
//  Copyright © 2018年 Miridescent. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRSBaseModel;
@interface TRSDBManager3 : NSObject
/**
 使用单利，单利创建的时候就生成了四张用来存取数据的数据库表格，分别是系统事件（systemEventDB）、上传系统事件失败（sendSystemEventDefaultDB）、自定义事件（customEventDB）、上传自定义时间失败（sendCustomEventDefaultDB）
 
 @return 单利
 */
+ (TRSDBManager3 *)sharedManager;
// ------------CommonMethod----------

/**
 通用方法，插入一条数据，根据数据类型，方法内部会将数据插入到对应的表中
 
 @param model 数据model
 */
- (BOOL)managerInsertOneDataWithDataModel:(TRSBaseModel *)model;

/**
 通用方法，插入一批数据，根据数据类型，方法内部会将数据插入到对应的表中
 
 @param modelArray 数据Array
 @return 是否插入成功
 */
- (BOOL)managerInsertDataWithDataModelArray:(NSArray<TRSBaseModel *> *)modelArray;

/**
 通用方法，删除一条数据，根据数据类型，方法内部会将数据插入到对应的表中
 
 @param model 数据model
 @return bool 是否删除成功
 */
- (BOOL)managerDeleteOneDataWithDataModel:(TRSBaseModel *)model;

/**
 通用方法， 清空某个数据库
 
 @param modelArray 要删除的数据数组(当modelArray为nil的时候，删除所有数据)
 @return 是否清空成功
 */
- (BOOL)managerDeleteDataWithDataModelArray:(NSArray<TRSBaseModel *> *)modelArray;

/**
 通用方法，根据类型获取当前库中所有数据
 
 @oaram count 取出的数据条数（当count传入0的时候取出所有数据）
 @return 数据数组
 */
- (NSArray *)managerGetDataWithDataCount:(NSInteger)count;


/**
 通用方法，获取当前类型数据的总条数
 
 @return 数据条数
 */
- (NSInteger)managerGatDataTotalCount;
@end
