//
//  TRSSystemEventConfig.m
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/27.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import "TRSSystemEventConfig.h"
#import "TRSCommen.h"
#import "TRSDefaultCacheManager.h"
#import "TRSSystemInfo.h"
#import "TRSBaseModel.h"
@interface TRSSystemEventConfig()
@property (nonatomic, strong) TRSDefaultCacheManager *defaultCacheManager;

@end
@implementation TRSSystemEventConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defaultCacheManager = [TRSDefaultCacheManager sharedManager];
        self.browsePageCount = 0;
    }
    return self;
}

- (TRSBaseModel *)configSystemEventModelWithEventType:(TRSSystemEventType)eventType{
    TRSBaseModel *baseModel = [[TRSBaseModel alloc] init];
    NSMutableDictionary *jsonDic = [@{} mutableCopy];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"mpId"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"mpId"] forKey:@"mpId"];
    if ([_defaultCacheManager deviceInfoWithKey:@"appkey"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"appkey"] forKey:@"appkey"];
    if ([TRSSystemInfo networkType] != nil) [jsonDic setObject:[TRSSystemInfo networkType] forKey:@"nt"];
    if ([TRSSystemInfo carrier] != nil) [jsonDic setObject:[TRSSystemInfo carrier] forKey:@"carrier"];
    if ([_defaultCacheManager deviceInfoWithKey:@"os"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"os"] forKey:@"os"];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"ov"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"ov"] forKey:@"ov"];
    if ([_defaultCacheManager deviceInfoWithKey:@"UUID"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"UUID"] forKey:@"UUID"];
    if ([_defaultCacheManager deviceInfoWithKey:@"sv"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"sv"] forKey:@"sv"];
    if ([_defaultCacheManager deviceInfoWithKey:@"sh"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"sh"] forKey:@"sh"];
    if ([_defaultCacheManager deviceInfoWithKey:@"sw"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"sw"] forKey:@"sw"];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"lang"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"lang"] forKey:@"lang"];
    if ([_defaultCacheManager deviceInfoWithKey:@"country"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"country"] forKey:@"country"];
    if ([_defaultCacheManager deviceInfoWithKey:@"av"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"av"] forKey:@"av"];
    if ([_defaultCacheManager deviceInfoWithKey:@"channel"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"channel"] forKey:@"channel"];
    if ([_defaultCacheManager deviceInfoWithKey:@"jb"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"jb"] forKey:@"jb"];
    
    if ([_defaultCacheManager deviceInfoWithKey:@"tz"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"tz"] forKey:@"tz"];
    if ([_defaultCacheManager deviceInfoWithKey:@"dm"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"dm"] forKey:@"dm"];
    if ([_defaultCacheManager deviceInfoWithKey:@"an"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"an"] forKey:@"an"];
    [jsonDic setObject:@"bas_sdk_event" forKey:@"e_type"];
    if ([_defaultCacheManager deviceInfoWithKey:@"bid"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"bid"] forKey:@"bid"];
    if ([_defaultCacheManager deviceInfoWithKey:@"IDFA"] != nil)  [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"IDFA"] forKey:@"mc"];
    
    
    // -----------以下为非毕传参数-------------
    
    if ([_defaultCacheManager deviceInfoWithKey:@"uid"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"uid"] forKey:@"uid"];
    if ([_defaultCacheManager deviceInfoWithKey:@"se_un"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"se_un"] forKey:@"se_un"];
    if ([_defaultCacheManager deviceInfoWithKey:@"lng"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"lng"] forKey:@"lng"];
    if ([TRSSystemInfo clientIP] != nil) [jsonDic setObject:[TRSSystemInfo clientIP] forKey:@"ip"];
    if ([_defaultCacheManager deviceInfoWithKey:@"lat"] != nil) [jsonDic setObject:[_defaultCacheManager deviceInfoWithKey:@"lat"] forKey:@"lat"];
    
    
   [jsonDic setObject:[NSString stringWithFormat:@"%@_%@_%ld_%@_%@",
                        TRSCurrentTime36radix(self.beginTime),
                        [_defaultCacheManager deviceInfoWithKey:@"LaunchTotalCount"],
                        (long)self.browsePageCount,
                        [_defaultCacheManager deviceInfoWithKey:@"PageVisitTotalCount"],
                        [_defaultCacheManager deviceInfoWithKey:@"UUID"]] forKey:@"pv"];
    
    
    switch (eventType) {
        case TRSSystemEventTypeBas_startup:
            
            [jsonDic setObject:@"bas_startup" forKey:@"e_key"];
            [jsonDic setObject:TRSCurrentTime36radix(self.beginTime) forKey:@"vt"];
            [jsonDic setObject:@0 forKey:@"se_ost"];
            [jsonDic setObject:[TRSSystemInfo currentVC] forKey:@"vc"];
            break;
        case TRSSystemEventTypeBas_suspend:
            
            [jsonDic setObject:@"bas_suspend" forKey:@"e_key"];
            [jsonDic setObject:TRSCurrentTime36radix(TRSCurrentTime()) forKey:@"vt"];
            [jsonDic setObject:[NSString stringWithFormat:@"%lld",[self.endTime longLongValue]-[self.beginTime longLongValue]] forKey:@"e_dur"];
            [jsonDic setObject:[TRSSystemInfo currentVC] forKey:@"vc"];
            
            break;
        case TRSSystemEventTypeBas_resume:
            
            [jsonDic setObject:@"bas_resume" forKey:@"e_key"];
            [jsonDic setObject:TRSCurrentTime36radix(self.beginTime) forKey:@"vt"];
            [jsonDic setObject:@0 forKey:@"se_ost"];
            [jsonDic setObject:[TRSSystemInfo currentVC] forKey:@"vc"];
            
            
            break;
        case TRSSystemEventTypeBas_activedOnly:
            
            [jsonDic setObject:@"bas_activedOnly" forKey:@"e_key"];
            [jsonDic setObject:TRSCurrentTime36radix(self.beginTime) forKey:@"vt"];
            [jsonDic setObject:@0 forKey:@"se_ost"];
            [jsonDic setObject:[TRSSystemInfo currentVC] forKey:@"vc"];
            
            break;
        default:
            break;
    }
    
    baseModel.jsonData = TRSDirectoryToData(jsonDic);
    
    return baseModel;
}

@end
