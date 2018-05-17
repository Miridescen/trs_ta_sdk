//
//  TRSDefaultCacheManager.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/27.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRSDefaultCacheManager : NSObject
+ (TRSDefaultCacheManager *)sharedManager;


/**
 增加设备信息
 
 @param key 键
 @param value 值
 */
- (void)memoryDeviceInfoWithKey:(NSString *)key value:(id)value;

/**
 删除设备信息

 @param key 键
 */
- (void)deleteDeviceInfoWithKey:(NSString *)key;
/**
 根据key获取对应infoCache中得值
 
 @param key 键
 @return 值
 */
- (id)deviceInfoWithKey:(NSString *)key;

/**
 全量更新DeviceInfo信息（手机的所有信息从新收集一遍）
 */
- (void)updateDeviceInfo;

/**
 获取存储的的DeviceInfo
 
 @return DeviceInfoDic
 */
- (NSDictionary *)deviceInfoDic;

- (NSInteger)LaunchTotalCount;
- (void)updateLaunchTotalCountWithCount:(NSInteger)count;
- (NSInteger)PageVisitTotalCount;
- (void)updatePageVisitTotalCountWithCount:(NSInteger)count;
@end
