//
//  TRSManager.h
//  TRS_SDK
//
//  Created by 824810056 on 2018/1/16.
//  Copyright © 2018年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TRSDefaultCacheManager.h"
#import "TRSHTTPManager.h"
#import "TRSSystemEventConfig.h"
#import "TRSReachability2.h"
#import "TRSDBManager3.h"

#import "TRSCommen.h"
typedef void (^TRSSendDataSuccess)(void);
typedef void (^TRSSendDataFailure)(NSError *error);

typedef NS_ENUM(NSUInteger, TRSAppOpenType) {
    TRSAppOpenTypeLaunch,
    TRSAppOpenTypeForground,
    TRSAppOpenTypeActivedOnly,
};

@interface TRSManager : NSObject
{
    TRSDBManager3 *_DBManager3;
    TRSDefaultCacheManager *_defaultCacheManage;
    TRSHTTPManager *_HTTPManager;
}

@property (nonatomic, strong) TRSDefaultCacheManager *defaultCacheManage;
@property (nonatomic, strong) TRSDBManager3 *DBManager3;
@property (nonatomic, strong) TRSHTTPManager *HTTPManager;

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@property (nonatomic) TRSAppOpenType appOpenType;

@property (nonatomic, assign) NSInteger browsePageCount; // 本次会话访问页面次数

@property (nonatomic, strong) NSNumber *appStartTime; // app启动时间
@property (nonatomic, strong) NSNumber *appEndTime; // app结束时间

@property (nonatomic, strong) NSMutableArray *pageConfigArray; // 放页面数组
@property (nonatomic, strong) NSMutableArray *eventModelArray; // 放事件的数组

@property (nonatomic, assign) BOOL killAppTagSendPageEvent; // 用于当程序被杀死时，判断事件是否发出
@property (nonatomic, strong) NSArray *killPageEventArray; // 用于程序被杀死，Background通知中用
@property (nonatomic, assign) BOOL killAppTagSendPageEvent2;
@property (nonatomic, strong) NSArray *killPageEventArray2;

@property (nonatomic, assign) BOOL logEnable;
@property (nonatomic, assign) BOOL debugEnable;
@property (nonatomic, assign) BOOL debugSuccess; // 发送debug模式是否成功

@property (nonatomic, assign) BOOL hasDeviceID; // 用于判断是否有deviceID
@property (nonatomic, assign) BOOL hasSendDeviceID; // 判断deviceID是否发送成功

@property (nonatomic, assign) BOOL hasUID; // 用于判断是否有用户信息
@property (nonatomic, assign) BOOL hasSendUID; // 判断用户信息是否发送成功


@property (nonatomic, assign) BOOL appActivitySuccess; // 用于判断是否走完activity通知，防止出现pv的appstarttime为0

@property (nonatomic, copy) NSString *refer; // 上一个页面


+ (TRSManager *)sharedManager;

- (void)browsePageCountAdd; // 页面浏览次数自增一
- (void)launchCountAdd; // 启动次数自增一

- (void)sendPageEventWithDataArray:(NSArray *)dataArray; // 供页面结束时发送数据调用

- (void)sendDebugPageEventWithDataArray:(NSArray *)dataArray; // debug模式下发送数据

- (void)sendDebugStateDeviceMessage; // debug下发送设备信息

- (void)sendUserInfo;

@end

