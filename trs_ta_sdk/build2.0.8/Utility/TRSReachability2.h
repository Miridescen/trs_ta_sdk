//
//  TRSReachability2.h
//  TRS_SDK
//
//  Created by 824810056 on 2018/1/17.
//  Copyright © 2018年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TRSReachabilityStatus) {
    TRSReachabilityStatusNone  = 0, ///< 无网
    TRSReachabilityStatusWWAN  = 1, ///< WWAN (2G/3G/4G)
    TRSReachabilityStatusWiFi  = 2, ///< WiFi
};

typedef NS_ENUM(NSUInteger, TRSReachabilityWWANStatus) {
    TRSReachabilityWWANStatusNone  = 0, ///< 无网
    TRSReachabilityWWANStatus2G = 2, ///< 2G (GPRS/EDGE)       10~100Kbps
    TRSReachabilityWWANStatus3G = 3, ///< 3G (WCDMA/HSDPA/...) 1~10Mbps
    TRSReachabilityWWANStatus4G = 4, ///< 4G (eHRPD/LTE)       100Mbps
};
@interface TRSReachability2 : NSObject

@property (nonatomic, readonly) SCNetworkReachabilityFlags flags;
@property (nonatomic, readonly) TRSReachabilityStatus status;
@property (nonatomic, readonly) TRSReachabilityWWANStatus WWANStatus NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly, getter=isReachable) BOOL reachable;

/// 网络变换时将在主线程调用.
@property (nullable, nonatomic, copy) void (^notifyBlock)(TRSReachability2 *reachability);

/// 创建一个reachability.
+ (instancetype)reachability;

/// 根据当地的wifi创建一个reachability
+ (instancetype)reachabilityForLocalWifi DEPRECATED_MSG_ATTRIBUTE("有害方法");

/// 通过传入的网址创建一个reachability
+ (nullable instancetype)reachabilityWithHostname:(NSString *)hostname;

/// 根据IP创建一个reachability
+ (nullable instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;
@end
NS_ASSUME_NONNULL_END
