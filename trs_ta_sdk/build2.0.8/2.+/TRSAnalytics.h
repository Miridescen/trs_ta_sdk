//
//  TRSAnalytics.h
//  TRS_SDK
//
//  Created by 824810056 on 2018/1/16.
//  Copyright © 2018年 牟松. All rights reserved.
//  本文件提供了SDK的初始化方法及相关参数设置方法

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface TRSAnalytics : NSObject

#pragma mark -- 必须调用方法
/**
 SDK初始化方法 必须调用
 
 @param appKey 分发的appKey
 @param appID 分发的appID
 @param staticURL 统计地址
 @param deviceID 设备ID
 @param channel 渠道（不传则默认为“APP Store”）
 @param attributes 自定义信息   注* 旧设备标识信息以key/value的形式放到该参数中，key = oldDeviceID，如果key传错，将收集不到
                                  个像设备标识信息以key/value的形式放到该参数中，key = gxDeviceID，如果key传错，将收集不到
 */

+ (void)startWithAppKey:(NSString *)appKey
                  appID:(NSString *)appID
              staticURL:(NSString *)staticURL
               deviceID:(nullable NSString *)deviceID
                channel:(nullable NSString *)channel
             attributes:(nullable NSDictionary *)attributes;

#pragma mark -- 可选调用方法
/**
 是否在控制台打印日志信息，默认不打印
 
 @param logEnable YES = 打印，NO = 不打印
 */
+ (void)setLogEnable:(BOOL)logEnable;

/**
 是否切换到debug模式，debug模式下数据会逐条发送，并可实时在网脉分析端查看，默认是非debug模式
 
 @param debugEnable YES = 切换，NO = 不切换
 */
+ (void)setDebugEnable:(BOOL)debugEnable;

/**
 设置经纬度信息
 
 @param longitude 经度
 @param latitude 纬度
 */
+ (void)setLongitude:(nullable NSString *)longitude latitude:(nullable NSString *)latitude;

#pragma mark -- 事件统计方法


/**
 进入页面调用

 @param pageName 自定义页面名称
 */
+ (void)pageBegin:(NSString *)pageName;

/**
 离开页面调用

 @param pageName 自定义页面名称
 */
+ (void)pageEnd:(NSString *)pageName;

/**
 离开页面调用

 @param pageName 自定义页面名称
 @param properties 其他页面相关信息 注* 相关字段见文档
 */
+ (void)pageEnd:(NSString *)pageName properties:(nullable NSMutableDictionary *)properties;


/**
 事件方法

 @param eventCode 事件编号
 */
+ (void)event:(NSString *)eventCode;

/**
 事件方法

 @param eventCode 事件编号
 @param properties 事件其他相关信息 注* 相关字段见文档
 */
+ (void)event:(NSString *)eventCode properties:(nullable NSMutableDictionary *)properties;

#pragma mark -- 用户相关方法

/**
 登录方法

 @param userInfo 用户信息  注* 目前只支持用户名称和用户ID两个字段
 */
+ (void)login:(NSMutableDictionary *)userInfo;

/**
 修改用户信息

 @param userInfo 用户信息  注* 目前只支持用户名称和用户ID两个字段
 */
+ (void)modifyUserInfo:(NSMutableDictionary *)userInfo;

/**
 退出方法
 */
+ (void)logout;



@end
NS_ASSUME_NONNULL_END

