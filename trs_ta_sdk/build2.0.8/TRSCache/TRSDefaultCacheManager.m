//
//  TRSDefaultCacheManager.m
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/27.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import "TRSDefaultCacheManager.h"
#import "TRSSystemInfo.h"
#import "TRSDefaultCache.h"
#import "TRSGetUUID2.h"

#define kTRSDefaultCache ([TRSDefaultCache sharedManage])
@interface TRSDefaultCacheManager()
{
    NSMutableDictionary *_deviceInfoDic;
}

@end
@implementation TRSDefaultCacheManager
+ (TRSDefaultCacheManager *)sharedManager{
    static TRSDefaultCacheManager *shareManage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManage = [[TRSDefaultCacheManager alloc] init];
        
    });
    return shareManage;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _deviceInfoDic = [@{
                            @"an"        :[TRSSystemInfo appName],
                            @"av"        :[TRSSystemInfo appVersion],
                            @"bid"       :[TRSSystemInfo bundleID],
                            @"country"   :[TRSSystemInfo country],
                            @"dm"        :[TRSSystemInfo deviceModel],
                            @"sh"        :[TRSSystemInfo screenHeight],
                            @"sw"        :[TRSSystemInfo screenWidth],
                            @"jb"        :[TRSSystemInfo jailbroken],
                            @"lang"      :[TRSSystemInfo language],
                            @"os"        :[TRSSystemInfo os],
                            @"ov"        :[TRSSystemInfo osVersion],
                            @"sv"        :[TRSSystemInfo sdkVersion],
                            @"tz"        :[TRSSystemInfo timeZone],
                            @"UUID"      :[TRSGetUUID2 getUUID],
                            @"IDFA"      :[TRSSystemInfo IDFA]
                            } mutableCopy];
        [kTRSDefaultCache memoryDeviceInfoWitDictionary:_deviceInfoDic];
    }
    return self;
}
- (void)memoryDeviceInfoWithKey:(NSString *)key value:(id)value{
    [kTRSDefaultCache memoryDeviceInfoWithKey:key value:value];
}
- (void)deleteDeviceInfoWithKey:(NSString *)key{
    [kTRSDefaultCache deleteDeviceInfoWithKey:key];
}
- (id)deviceInfoWithKey:(NSString *)key{
    return [kTRSDefaultCache deviceInfoValueWithKey:key];
}
- (void)updateDeviceInfo{
    _deviceInfoDic = [@{
                        @"an"        :[TRSSystemInfo appName],
                        @"av"        :[TRSSystemInfo appVersion],
                        @"bid"       :[TRSSystemInfo bundleID],
                        @"country"   :[TRSSystemInfo country],
                        @"dm"        :[TRSSystemInfo deviceModel],
                        @"sh"        :[TRSSystemInfo screenHeight],
                        @"sw"        :[TRSSystemInfo screenWidth],
                        @"jb"        :[TRSSystemInfo jailbroken],
                        @"lang"      :[TRSSystemInfo language],
                        @"os"        :[TRSSystemInfo os],
                        @"ov"        :[TRSSystemInfo osVersion],
                        @"sv"        :[TRSSystemInfo sdkVersion],
                        @"tz"        :[TRSSystemInfo timeZone],
                        @"UUID"      :[TRSGetUUID2 getUUID],
                        @"IDFA"      :[TRSSystemInfo IDFA]
                        } mutableCopy];
    [kTRSDefaultCache memoryDeviceInfoWitDictionary:_deviceInfoDic];
}
- (NSDictionary *)deviceInfoDic{
    return kTRSDefaultCache.deviceInfoDic;
}
- (NSInteger)LaunchTotalCount{
    NSNumber *totalCount = [kTRSDefaultCache deviceInfoValueWithKey:@"LaunchTotalCount"];
    return [totalCount integerValue];
}
- (NSInteger)PageVisitTotalCount{
    NSNumber *totalCount = [kTRSDefaultCache deviceInfoValueWithKey:@"PageVisitTotalCount"];
    return [totalCount integerValue];
}
- (void)updateLaunchTotalCountWithCount:(NSInteger)count{
    NSNumber *number = [NSNumber numberWithInteger:count];
    [self memoryDeviceInfoWithKey:@"LaunchTotalCount" value:number];
}
- (void)updatePageVisitTotalCountWithCount:(NSInteger)count{
    NSNumber *number = [NSNumber numberWithInteger:count];
    [self memoryDeviceInfoWithKey:@"PageVisitTotalCount" value:number];
}

@end
