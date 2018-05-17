//
//  TRSSystemInfo.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/8.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TRSSystemInfo : NSObject
/** APP名称 */
+ (NSString *)appName;

/** APP版本 */
+ (NSString *)appVersion;

/** bundleID */
+ (NSString *)bundleID;

/** 运营商 */
+ (NSString *)carrier;

/** 内网IP */
+ (NSString *)clientIP;

/** 地区设置（国家） */
+ (NSString *)country;

/** 设备型号 */
+ (NSString *)deviceModel;

/** 设备屏幕高度 */
+ (NSString *)screenHeight;

/** 设备屏幕宽度 */
+ (NSString *)screenWidth;


/**
 是否越狱
 
 @return 0 == 没有越狱， 1 == 已经越狱
 */
+ (NSString *)jailbroken;

/** 语言设置 */
+ (NSString *)language;

/**
 网络类型
 
 @return 手机上网方式，如Wifi、4G、3G、2G、无网络等
 */
+ (NSString *)networkType;

/**
 操作系统
 
 @return 固定返回ios
 */
+ (NSString *)os;

/** 操作系统版本 */
+ (NSString *)osVersion;

/** sdk版本 */
+ (NSString *)sdkVersion;

/** 设置时区 */
+ (NSString *)timeZone;

/** IDFA */
+ (NSString *)IDFA;

/** 手机名称 */
+ (NSString *)phoneName;

/** 获取当前VC名称 */
+ (NSString *)currentVC;
@end
