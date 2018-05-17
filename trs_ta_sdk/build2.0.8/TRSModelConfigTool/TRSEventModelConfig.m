
//
//  TRSEventModelConfig.m
//  TRSAnalytics
//
//  Created by 824810056 on 2018/3/8.
//  Copyright © 2018年 Miridescent. All rights reserved.
//

#import "TRSEventModelConfig.h"

#import "TRSCommen.h"
#import "TRSDefaultCacheManager.h"
#import "TRSSystemInfo.h"
#import "TRSBaseModel.h"

@interface TRSEventModelConfig()

@property (nonatomic, strong) TRSDefaultCacheManager *defaultCacheManager;

@end

@implementation TRSEventModelConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defaultCacheManager = [TRSDefaultCacheManager sharedManager];
        self.se_no = 0;
    }
    return self;
}

- (TRSBaseModel *)configPageModelWith:(NSDictionary *)properties{
    TRSBaseModel *baseModel = [[TRSBaseModel alloc] init];
    
    NSMutableDictionary *dataDic = [@{} mutableCopy];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"mpId"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"mpId"] forKey:@"mpId"];
    if ([_defaultCacheManager deviceInfoWithKey:@"appkey"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"appkey"] forKey:@"appkey"];
    if ([TRSSystemInfo networkType]) [dataDic setObject:[TRSSystemInfo networkType] forKey:@"nt"];
    if ([TRSSystemInfo carrier]) [dataDic setObject:[TRSSystemInfo carrier] forKey:@"carrier"];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"os"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"os"] forKey:@"os"];
    if ([_defaultCacheManager deviceInfoWithKey:@"ov"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"ov"] forKey:@"ov"];
    if ([_defaultCacheManager deviceInfoWithKey:@"UUID"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"UUID"] forKey:@"UUID"];
    if ([_defaultCacheManager deviceInfoWithKey:@"sv"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"sv"] forKey:@"sv"];
    if ([_defaultCacheManager deviceInfoWithKey:@"sh"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"sh"] forKey:@"sh"];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"sw"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"sw"] forKey:@"sw"];
    if ([_defaultCacheManager deviceInfoWithKey:@"lang"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"lang"] forKey:@"lang"];
    if ([_defaultCacheManager deviceInfoWithKey:@"country"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"country"] forKey:@"country"];
    if ([_defaultCacheManager deviceInfoWithKey:@"av"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"av"] forKey:@"av"];
    if ([_defaultCacheManager deviceInfoWithKey:@"channel"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"channel"] forKey:@"channel"];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"jb"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"jb"] forKey:@"jb"];
    if ([_defaultCacheManager deviceInfoWithKey:@"tz"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"tz"] forKey:@"tz"];
    if ([_defaultCacheManager deviceInfoWithKey:@"dm"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"dm"] forKey:@"dm"];
    if ([_defaultCacheManager deviceInfoWithKey:@"an"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"an"] forKey:@"an"];
    if ([_defaultCacheManager deviceInfoWithKey:@"bid"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"bid"] forKey:@"bid"];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"uid"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"uid"] forKey:@"uid"];
    if ([_defaultCacheManager deviceInfoWithKey:@"se_un"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"se_un"] forKey:@"se_un"];
    if ([TRSSystemInfo clientIP]) [dataDic setObject:[TRSSystemInfo clientIP] forKey:@"ip"];
    if ([_defaultCacheManager deviceInfoWithKey:@"lng"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"lng"] forKey:@"lng"];
    if ([_defaultCacheManager deviceInfoWithKey:@"lat"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"lat"] forKey:@"lat"];
    if ([_defaultCacheManager deviceInfoWithKey:@"IDFA"]) [dataDic setObject:[_defaultCacheManager deviceInfoWithKey:@"IDFA"] forKey:@"mc"];
    
    if (properties) {
        [dataDic addEntriesFromDictionary:[self dicWithOriginalDic:properties]];
    }

    if (self.pv) [dataDic setObject:self.pv forKey:@"pv"];
    if (self.vt) [dataDic setObject:self.vt forKey:@"vt"];
    if (self.vt) [dataDic setObject:self.vt forKey:@"se_vt"];
    if (self.eventCode) [dataDic setObject:self.eventCode forKey:@"se_code"];
    
    baseModel.jsonData = TRSDirectoryToData(dataDic);
    
    return baseModel;
}

- (NSDictionary *)dicWithOriginalDic:(NSDictionary *)dic{
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    NSArray *allKeys = [dic allKeys];
    for (NSString *key in allKeys) {
        if ([key isEqualToString:@"se_duration"]) {
            [resultDic setObject:dic[key] forKey:@"se_dur"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_action"]) {
            [resultDic setObject:dic[key] forKey:@"se_ac"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_pageType"]) {
            [resultDic setObject:dic[key] forKey:@"se_pt"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_objectType"]) {
            [resultDic setObject:dic[key] forKey:@"se_ot"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_objectID"]) {
            [resultDic setObject:dic[key] forKey:@"se_oid"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_objectShortName"]) {
            [resultDic setObject:dic[key] forKey:@"se_osn"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_objectIDs"]) {
            [resultDic setObject:dic[key] forKey:@"se_oids"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_classID"]) {
            [resultDic setObject:dic[key] forKey:@"se_cid"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_classShortName"]) {
            [resultDic setObject:dic[key] forKey:@"se_csn"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_searchWord"]) {
            [resultDic setObject:dic[key] forKey:@"se_sw"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_objectAmount"]) {
            [resultDic setObject:dic[key] forKey:@"se_oam"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_objectNO"]) {
            [resultDic setObject:dic[key] forKey:@"se_ono"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_pagePercent"]) {
            [resultDic setObject:dic[key] forKey:@"se_pp"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_success"]) {
            [resultDic setObject:dic[key] forKey:@"se_su"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_selfObjectID"]) {
            [resultDic setObject:dic[key] forKey:@"se_soid"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_attachObjectID"]) {
            [resultDic setObject:dic[key] forKey:@"se_aoid"];
            [resultDic removeObjectForKey:key];
        }
        if ([key isEqualToString:@"se_openStyle"]) {
            [resultDic setObject:dic[key] forKey:@"se_ost"];
            [resultDic removeObjectForKey:key];
        }
    }
    
    return resultDic;
}

@end
