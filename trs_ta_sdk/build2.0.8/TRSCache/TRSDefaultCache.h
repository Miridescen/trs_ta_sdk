//
//  TRSDefaultCache.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/27.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRSDefaultCache : NSObject
{
    NSString *_cachePath; // 存储路径
    dispatch_queue_t _ioQueue;
    NSMutableDictionary *_deviceInfoDic;
    
}
@property dispatch_queue_t ioQueue;
/**
 存储路径
 */
@property (nonatomic, copy) NSString *cachePath;

/**
 存储的内容信息
 */
@property (nonatomic, strong) NSMutableDictionary *deviceInfoDic;

/**
 实例化方法
 
 @return 单利
 */
+ (TRSDefaultCache *)sharedManage;


/**
 存储DeviceInfo，具体值以键值对存取，有key更新，无key添加
 
 @param key 键
 @param value 值
 */
- (void)memoryDeviceInfoWithKey:(NSString *)key value:(NSString *)value;

/**
 根据key删除某个字段

 @param key 键
 */
- (void)deleteDeviceInfoWithKey:(NSString *)key;
/**
 根据key取值
 
 @param key 键
 @return 键对应的值
 */
- (id)deviceInfoValueWithKey:(NSString *)key;

/**
 存储整个DeviceInfo字典
 
 @param dic DeviceInfo字典
 */
- (void)memoryDeviceInfoWitDictionary:(NSDictionary *)dic;
@end
