//
//  TRSManager.m
//  TRS_SDK
//
//  Created by 824810056 on 2018/1/16.
//  Copyright © 2018年 牟松. All rights reserved.
//

#import "TRSManager.h"
#import "TRSPageConfig.h"
#import "TRSSystemInfo.h"
#import "TRSBaseModel.h"

@interface TRSManager()


@end
@implementation TRSManager

+ (TRSManager *)sharedManager{
    static TRSManager *shareManage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManage = [[TRSManager alloc] init];
    });
    return shareManage;
}
#pragma mark -- privat method
- (instancetype)init{
    self = [super init];
    if (self) {
        _defaultCacheManage = [TRSDefaultCacheManager sharedManager];
        _DBManager3 = [TRSDBManager3 sharedManager];
        _HTTPManager = [TRSHTTPManager sharedManger];
        _pageConfigArray = [@[] mutableCopy];
        _eventModelArray = [@[] mutableCopy];
        _browsePageCount = 0;
        _logEnable = NO;
        _debugEnable = NO;
        _debugSuccess = NO;
        _hasDeviceID = NO;
        _hasSendDeviceID = NO;
        _hasUID = NO;
        _hasSendUID = NO;
        _appOpenType = TRSAppOpenTypeActivedOnly;
        self.refer = @"";
        
        _killAppTagSendPageEvent = NO;
        _killPageEventArray = [[NSArray alloc] init];
        _killAppTagSendPageEvent2 = NO;
        _killPageEventArray2 = [[NSArray alloc] init];
        
        _appActivitySuccess = NO;
        self.appStartTime = TRSCurrentTime();
        [self launchCountAdd];
        
        //启动加载
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(APPLaunching)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        //应用进入前台通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(APPForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        //程序变活
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(APPBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        
        //程序将被杀死
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(APPResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        //程序将被杀死
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(APPWillTerminateNotification)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
 
    }
    return self;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark ------------------ notifiction --------------

- (void)APPLaunching{
    TRSNSLog(@"APPLaunch");
    [self sendDeviceID];
    _appOpenType = TRSAppOpenTypeLaunch;
}
- (void)APPForeground{
    TRSNSLog(@"APPForground");
    _appOpenType = TRSAppOpenTypeForground;
}

- (void)APPBecomeActive{
    TRSNSLog(@"APPActivie");
    self.debugSuccess = NO;
    self.refer = @"";
    
    if (self.appActivitySuccess) {
        self.appStartTime = TRSCurrentTime();
        [self launchCountAdd];
    }
    
    self.browsePageCount = 0;
    self.appActivitySuccess = YES;
    
    if (_debugEnable) { // debug模式
        // 生成一次APP启动事件
        TRSSystemEventConfig *systemEventConfig = [[TRSSystemEventConfig alloc] init];
        systemEventConfig.beginTime = self.appStartTime;
        TRSBaseModel *systemBaseModel = [[TRSBaseModel alloc] init];
        switch (_appOpenType) {
            case TRSAppOpenTypeLaunch:
                systemBaseModel = [systemEventConfig configSystemEventModelWithEventType:TRSSystemEventTypeBas_startup];
                break;
            case TRSAppOpenTypeForground:
                systemBaseModel = [systemEventConfig configSystemEventModelWithEventType:TRSSystemEventTypeBas_resume];
                break;
            case TRSAppOpenTypeActivedOnly:
                systemBaseModel = [systemEventConfig configSystemEventModelWithEventType:TRSSystemEventTypeBas_resume];
                break;
            default:
                break;
        }
        // 发送启动事件
        NSArray *startSystemEventArray = @[systemBaseModel];
        [self sendDebugDataWithWithDataArray:startSystemEventArray];
    } else {
        // 生成一次APP启动事件并入库
        TRSSystemEventConfig *systemEventConfig = [[TRSSystemEventConfig alloc] init];
        systemEventConfig.beginTime = self.appStartTime;
        TRSBaseModel *systemBaseModel = [[TRSBaseModel alloc] init];
        switch (_appOpenType) {
            case TRSAppOpenTypeLaunch:
                systemBaseModel = [systemEventConfig configSystemEventModelWithEventType:TRSSystemEventTypeBas_startup];
                break;
            case TRSAppOpenTypeForground:
                systemBaseModel = [systemEventConfig configSystemEventModelWithEventType:TRSSystemEventTypeBas_resume];
                break;
            case TRSAppOpenTypeActivedOnly:
                systemBaseModel = [systemEventConfig configSystemEventModelWithEventType:TRSSystemEventTypeBas_resume];
                break;
            default:
                break;
        }
        [self->_DBManager3 managerInsertOneDataWithDataModel:systemBaseModel];
        
        
        // ---------发送数据-----------------------------------------------------------------------------------
        
        // 发送启动事件
        NSArray *startSystemEventArray = @[systemBaseModel];
        @weakify(self);
        [self sendDataWithWithDataArray:startSystemEventArray Success:^{
            @strongify(self);
            if (!self) return;
            TRSNSLog(@"成功采集并发送%ld条SystemEvent数据", (unsigned long)startSystemEventArray.count);
            if ([self->_DBManager3 managerDeleteOneDataWithDataModel:systemBaseModel]) {
                TRSNSLog(@"发送启动事件成功，删除系统事件成功");
            } else {
                TRSNSLog(@"发送启动事件成功，删除系统事件失败，出现重复数据");
            }
            // 检查是否有缓存数据
            [self sendTotalData];
        } failure:^(NSError *error){
            TRSNSLog(@"发送启动事件失败");
        }];
        
    }
}
- (void)APPResignActive{
    TRSNSLog(@"APP进入后台");
    UIApplication *app = [UIApplication sharedApplication];
    @weakify(self);
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        @strongify(self);
        if (!self) return;
        dispatch_async(dispatch_get_main_queue(),^{
            
            if( self.bgTask != UIBackgroundTaskInvalid){
                self.bgTask = UIBackgroundTaskInvalid;
            }
        });
        
        [app endBackgroundTask:self.bgTask];
        
    }];

    self.appEndTime = TRSCurrentTime();
    _appOpenType = TRSAppOpenTypeActivedOnly;
    
    if (_debugEnable) {
        // 生成挂起事件
        TRSSystemEventConfig *systemEventConfig = [[TRSSystemEventConfig alloc] init];
        systemEventConfig.beginTime = self.appStartTime;
        systemEventConfig.endTime = self.appEndTime;
        systemEventConfig.browsePageCount = self.browsePageCount;
        TRSBaseModel *systemBaseModel = [systemEventConfig configSystemEventModelWithEventType:TRSSystemEventTypeBas_suspend];
        // 发送启动事件
        NSArray *suspendSystemEventArray = @[systemBaseModel];
        [self sendDebugDataWithWithDataArray:suspendSystemEventArray];
    } else {
        NSMutableArray *eventArray = [@[] mutableCopy];
        // ---------系统事件处理-----------------------------------------------------------------------------------
        
        // 生成挂起事件
        TRSSystemEventConfig *systemEventConfig = [[TRSSystemEventConfig alloc] init];
        systemEventConfig.beginTime = self.appStartTime;
        systemEventConfig.endTime = self.appEndTime;
        systemEventConfig.browsePageCount = self.browsePageCount;
        TRSBaseModel *systemBaseModel = [systemEventConfig configSystemEventModelWithEventType:TRSSystemEventTypeBas_suspend];
        [eventArray addObject:systemBaseModel];
        
        
        // -------页面事件处理------------------------------------------------------------------------------------
        
        /*  // 是否处理页面，还有待于研究
        if (self.pageConfigArray.count > 0) {
            for (TRSPageConfig *pageConfig in self.pageConfigArray) { // 找到与其匹配的beginPage
                pageConfig.pageEndTime = TRSCurrentTime();
                TRSPageEventModel *pageModel = [pageConfig configPageModelWith:nil eventMdoel:nil];
                [eventArray addObject:pageModel];
            }
        }
         */
        
        [self.pageConfigArray removeAllObjects];
        if (self.eventModelArray.count >0) {
            [eventArray addObjectsFromArray:self.eventModelArray];
            [self.eventModelArray removeAllObjects];
        }

        // ---------发送数据-----------------------------------------------------------------------------------
        
        _killPageEventArray = eventArray;
        @weakify(self);
        [self sendDataWithWithDataArray:eventArray Success:^{
            @strongify(self);
            if (!self) return;
            TRSNSLog(@"成功采集并发送%ld条pageEvent数据", (unsigned long)eventArray.count);
            // 检查是否有缓存数据
            [self sendTotalData];
        } failure:^(NSError *error) {
            @strongify(self);
            if (!self) return;
            if ([self->_DBManager3 managerInsertDataWithDataModelArray:eventArray]) {
                TRSNSLog(@"采集%ld条pageEvent数据，发送数据失败，数据入库", (unsigned long)eventArray.count);
            } else {
                TRSNSLog(@"采集%ld条pageEvent成功，数据入库失败，数据丢失", (unsigned long)eventArray.count);
            }
        }];
        
        
    }

    self.browsePageCount = 0;
 
}
- (void)APPWillTerminateNotification{
    TRSNSLog(@"APP关闭");
    
    [self.defaultCacheManage deleteDeviceInfoWithKey:@"se_un"];
    [self.defaultCacheManage deleteDeviceInfoWithKey:@"uid"];
    [self.defaultCacheManage deleteDeviceInfoWithKey:@"extraInfo"];
    
    if (_debugEnable) return;
    if (self.killAppTagSendPageEvent != YES) {
        if (_killPageEventArray.count > 0) {
            if ([self->_DBManager3 managerInsertDataWithDataModelArray:_killPageEventArray]) {
                if (_logEnable) {
                    TRSNSLog(@"111111----------采集%ld条pageEvent事件----------\n", (long)_killPageEventArray.count);
                }
            } else {
                TRSNSLog(@"采集启动事件入库失败，数据丢失");
            }
        }
    } else {
        TRSNSLog(@"程序出错了，处理杀死程序时逻辑有问题，需要修改");
    }
    if (self.killAppTagSendPageEvent2 != YES) {
        if (_killPageEventArray2.count > 0) {
            if ([self->_DBManager3 managerInsertDataWithDataModelArray:_killPageEventArray2]) {
                if (_logEnable) {
                    TRSNSLog(@"111111----------采集%ld条pageEvent事件----------\n", (long)_killPageEventArray2.count);
                }
            } else {
                TRSNSLog(@"采集启动事件入库失败，数据丢失");
            }
        }
    } else {
        TRSNSLog(@"程序出错了，处理杀死程序时逻辑有问题，需要修改");
    }
    
}


#pragma mark ------------------ public method --------------

- (void)sendDebugPageEventWithDataArray:(NSArray *)dataArray{
    if (dataArray.count == 0 || dataArray == nil) {
        return;
    }
    [self sendDebugDataWithWithDataArray:dataArray];
}
- (void)sendPageEventWithDataArray:(NSArray *)dataArray{
    if (dataArray.count == 0 || dataArray == nil) {
        return;
    }
    _killPageEventArray2 = dataArray;
    @weakify(self);
    [self sendDataWithWithDataArray:dataArray Success:^{
        TRSNSLog(@"采集并发送%ld条pageEvent数据", (unsigned long)dataArray.count);
        return;
    } failure:^(NSError *error){
        @strongify(self);
        if (!self) return;
        if ([self->_DBManager3 managerInsertDataWithDataModelArray:dataArray]) {
            TRSNSLog(@"发送pageEvent数据失败，插入临时表%ld条数据", (unsigned long)dataArray.count);
        } else {
            TRSNSLog(@"*****发送失败插入临时表%ld条pageEvent数据失败，数据丢失******", (unsigned long)dataArray.count);
        }
    }];
}


#pragma mark ------------------ private method --------------
/**
 发送时数据
 
 @param dataArray 要发送的数据
 @param success 发送成功回调
 @param failure 发送失败回调
 */
- (void)sendDataWithWithDataArray:(NSArray *)dataArray Success:(TRSSendDataSuccess)success failure:(TRSSendDataFailure)failure{
    if (dataArray.count == 0 || dataArray == nil) {
        return;
    }

    _killAppTagSendPageEvent = NO;
    _killAppTagSendPageEvent2 = NO;
    
    NSString *staticURL = [NSString stringWithFormat:@"%@", [self->_defaultCacheManage deviceInfoWithKey:@"staticURL"]];
    NSArray *staticURLArr = [staticURL componentsSeparatedByString:@"/"];
    if (staticURLArr.count>3) {
        staticURL = staticURLArr[2];
    }
    TRSReachability2 *reachability = [TRSReachability2 reachabilityWithHostname:staticURL];
    if (reachability.reachable) {
        // model转字典
        NSMutableArray *arr = [NSMutableArray array];
        for (TRSBaseModel *model in dataArray) {
            NSDictionary *dic = TRSDataToDirectory(model.jsonData);
            if (dic) [arr addObject:dic];
            
        }
        // 发送
        NSString *url = [self->_defaultCacheManage deviceInfoWithKey:@"staticURL"];
        NSString *head1 = [NSString stringWithFormat:@"%@", [self->_defaultCacheManage deviceInfoWithKey:@"UUID"]];
        NSString *head2 = [self->_defaultCacheManage deviceInfoWithKey:@"appkey"];
        
        @weakify(self);
        [self->_HTTPManager managerSendHTTPRequestWithUrl:url head1:head1 head2:head2 dataArray:arr success:^(id response) {
            @strongify(self);
            if (!self) return;
            if (self.logEnable) {
                NSLog(@"----------成功发送%ld条数据----------", (unsigned long)arr.count);
                NSLog(@"%@", arr);
            }
            self.killAppTagSendPageEvent = YES;
            self.killAppTagSendPageEvent2 = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                if (self.hasDeviceID && !self.hasSendDeviceID) {
                    [self sendDeviceID];
                }
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                if (self.hasUID && !self.hasSendUID) {
                    [self sendUserInfo];
                }
            });
  
        } failure:^(NSError *error) {
            @strongify(self);
            if (!self) return;
            self.killAppTagSendPageEvent = YES;
            self.killAppTagSendPageEvent2 = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            
            
        }];
        
    } else {
        TRSNSLog(@"网络不好用");
        NSError *error = [[NSError alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);
        });
        
        return;
    }
    
    
}

/**
 发送debug数据用
 */
- (void)sendDebugDataWithWithDataArray:(NSArray *)dataArray{
    if (dataArray.count == 0 || dataArray == nil) {
        return;
    }
    
    NSString *staticURL = [NSString stringWithFormat:@"%@", [self->_defaultCacheManage deviceInfoWithKey:@"staticURL"]];
    NSArray *staticURLArr = [staticURL componentsSeparatedByString:@"/"];
    if (staticURLArr.count>3) {
        staticURL = staticURLArr[2];
    }
    TRSReachability2 *reachability = [TRSReachability2 reachabilityWithHostname:staticURL];
    
    if (reachability.reachable) {
        // model转字典
        NSMutableArray *arr = [NSMutableArray array];
        for (TRSBaseModel *model in dataArray) {
            NSDictionary *dic = TRSDataToDirectory(model.jsonData);
            if (dic) [arr addObject:dic];
        }
        NSString *url = [self->_defaultCacheManage deviceInfoWithKey:@"staticURL"];
        NSString *head1 = [NSString stringWithFormat:@"%@", [self->_defaultCacheManage deviceInfoWithKey:@"UUID"]];
        NSString *head2 = [self->_defaultCacheManage deviceInfoWithKey:@"appkey"];

        [self->_HTTPManager managerDebugSendHTTPRequestWithUrl:url head1:head1 head2:head2 dataArray:arr success:^(id response) {
            NSLog(@"----------debug成功发送1条数据----------\n");
            NSLog(@"%@", arr);
        } failure:^(NSError *error) {
            NSLog(@"----------debug发送数据失败，数据如下----------\n");
            NSLog(@"%@", arr);
        }];

    } else {
        NSLog(@"----------网络不好用，发送数据失败----------\n");
    }
}
/**
 数据校验
 
 @param arr 要发送的数据
 @return 校验结果
 */
- (NSString *)checkResultWithModelArray:(NSArray *)arr{
    long long checkVt = 0, checkPv = 0;
    for (NSInteger i = 0; i<arr.count; i++) {
        NSString *vtStr = arr[i][@"vt"];
        NSString *pvStr = arr[i][@"pv"];
        long long vt = strtoll([vtStr UTF8String],0,36);
        NSArray *pvSubStrArr = [pvStr componentsSeparatedByString:@"_"];
        long long pageVisitTotalCount = 0;
        if (pvSubStrArr.count > 3) {
            pageVisitTotalCount = [pvSubStrArr[3] longLongValue];
        }
        if (i == 0) {
            checkVt = vt;
            checkPv = pageVisitTotalCount;
        } else {
            checkVt = (checkVt+vt)/2;
            checkPv = (checkPv+pageVisitTotalCount)/2;
        }
    }
    return [NSString stringWithFormat:@"%@%lld", TRSCurrentTime36radix([NSNumber numberWithLongLong:checkVt]),checkPv];
}


// 统一到一张表的发送逻辑
- (void)sendTotalData{
    NSInteger count = [self->_DBManager3 managerGatDataTotalCount];
    if (count == 0) {
        return;
    } else if (count > 0 && count <= 50) {
        NSArray *dataArray = [self->_DBManager3 managerGetDataWithDataCount:0];
        
        @weakify(self);
        [self sendDataWithWithDataArray:dataArray Success:^{
            @strongify(self);
            if (!self) return;
            TRSNSLog(@"成功发送%ld条数据", (unsigned long)dataArray.count);
            if ([self->_DBManager3 managerDeleteDataWithDataModelArray:dataArray]) {
                TRSNSLog(@"成功删除%ld条数据", (unsigned long)dataArray.count);
            } else {
                TRSNSLog(@"*****发送数据成功，删除数据失败*****");
            }
            
            return;
        } failure:^(NSError *error){
            @strongify(self);
            if (!self) return;
            TRSNSLog(@"发送数据失败");
            if (error.code == -2) {
                if ([self->_DBManager3 managerDeleteDataWithDataModelArray:dataArray]) {
                    TRSNSLog(@"%ld条数据有问题，清空该表", (unsigned long)dataArray.count);
                } else {
                    TRSNSLog(@"*****数据有问题，清空该表失败*****");
                }
            }
            return;
        }];
        
    } else {
        NSArray *dataArray = [self->_DBManager3 managerGetDataWithDataCount:50];
        @weakify(self);
        [self sendDataWithWithDataArray:dataArray Success:^{
            
            @strongify(self);
            if (!self) return;
            TRSNSLog(@"成功发送%ld条数据", (unsigned long)dataArray.count);
            if ([self->_DBManager3 managerDeleteDataWithDataModelArray:dataArray]) {
                TRSNSLog(@"成功删除%ld条数据", (unsigned long)dataArray.count);
            } else {
                TRSNSLog(@"*****发送数据成功，删除数据失败*****");
            }
            // 再次发送数据请求
            [self sendTotalData];
        } failure:^(NSError *error){
            @strongify(self);
            if (!self) return;
            TRSNSLog(@"发送数据失败");
            if (error.code == -2) {
                if ([self->_DBManager3 managerDeleteDataWithDataModelArray:dataArray]) {
                    TRSNSLog(@"%ld条数据有问题，清空该表", (unsigned long)dataArray.count);
                } else {
                    TRSNSLog(@"*****数据有问题，清空该表失败*****");
                }
            }
            return;
        }];
        
    }
}

/**
 发送设备ID
 */
- (void)sendDeviceID{
    
    NSString *staticURL = [[NSString stringWithFormat:@"%@", [self->_defaultCacheManage deviceInfoWithKey:@"staticURL"]] stringByAppendingString:@"/openapi/appDeviceId"];

    NSString *param;
    NSString *url;
    
    
    TRSNSLog(@"-------------发送设备信息-----------------");
    
    if (!TRSBlankStr([self->_defaultCacheManage deviceInfoWithKey:@"deviceID"])) {
        self.hasDeviceID = YES;
    }

    if (!TRSBlankStr([self->_defaultCacheManage deviceInfoWithKey:@"deviceID"])) {
        
        param = [NSString stringWithFormat:@"wmDeviceId=%@&mpId=%@&deviceId=%@&osVersion=%@&sdkVersion=%@",
                 [self->_defaultCacheManage deviceInfoWithKey:@"UUID"],
                 [self->_defaultCacheManage deviceInfoWithKey:@"mpId"],
                 [self->_defaultCacheManage deviceInfoWithKey:@"deviceID"],
                 [self->_defaultCacheManage deviceInfoWithKey:@"ov"],
                 [self->_defaultCacheManage deviceInfoWithKey:@"sv"]];
        
        if (!TRSBlankStr([self->_defaultCacheManage deviceInfoWithKey:@"olddeviceid"])) {
           param =  [param stringByAppendingString:[NSString stringWithFormat:@"&oldDeviceId=%@", [self->_defaultCacheManage deviceInfoWithKey:@"olddeviceid"]]];
        }
        
        url = [NSString stringWithFormat:@"%@?%@", staticURL, param];
        
//        NSLog(@"sendDeviceIDUrl1111 == %@", url);
        @weakify(self);
        [self->_HTTPManager managerSendDeviceIDWithUrl:url success:^(id response) {
            @strongify(self);
            if (!self) return;
            self.hasSendDeviceID = YES;
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    if (!TRSBlankStr([self->_defaultCacheManage deviceInfoWithKey:@"gxdeviceid"])) {
        TRSNSLog(@"-------------发送gx设备信息-----------------");
        param = [NSString stringWithFormat:@"wmDeviceId=%@&mpId=%@&osVersion=%@&sdkVersion=%@&machineCode=%@&deviceIdJSON={gxDeviceId:'%@'}",
                 [self->_defaultCacheManage deviceInfoWithKey:@"UUID"],
                 [self->_defaultCacheManage deviceInfoWithKey:@"mpId"],
                 [self->_defaultCacheManage deviceInfoWithKey:@"ov"],
                 [self->_defaultCacheManage deviceInfoWithKey:@"sv"],
                 [TRSSystemInfo IDFA],
                 [self->_defaultCacheManage deviceInfoWithKey:@"gxdeviceid"]];
        
        if (!TRSBlankStr([self->_defaultCacheManage deviceInfoWithKey:@"deviceID"])) {
            param =  [param stringByAppendingString:[NSString stringWithFormat:@"&deviceId=%@", [self->_defaultCacheManage deviceInfoWithKey:@"deviceID"]]];
        }
        
        url = [NSString stringWithFormat:@"%@?%@", staticURL, param];
        
//        NSLog(@"sendDeviceIDUrl2222 == %@", url);
        
        [self->_HTTPManager managerSendDeviceIDWithUrl:url success:^(id response) {
            
            
        } failure:^(NSError *error) {
            
            
        }];
    }
    
}
- (void)sendUserInfo{

    
    TRSNSLog(@"-------------发送用户信息-----------------");
    
    if (!TRSBlankStr([self->_defaultCacheManage deviceInfoWithKey:@"uid"])) {
        self.hasUID = YES;
    } else {
        TRSNSLog(@"没有用户信息");
        return;
    }
    
    
    NSString *staticURL = [[NSString stringWithFormat:@"%@", [self->_defaultCacheManage deviceInfoWithKey:@"staticURL"]] stringByAppendingString:@"/openapi/appLoginUserInfo"];
    NSString *param;
    NSString *url;
    
    param = [NSString stringWithFormat:@"wmDeviceId=%@&mpId=%@&uidstr=%@&userName=%@&extraInfo=%@",
             [self->_defaultCacheManage deviceInfoWithKey:@"UUID"],
             [self->_defaultCacheManage deviceInfoWithKey:@"mpId"],
             [self->_defaultCacheManage deviceInfoWithKey:@"uid"],
             [self->_defaultCacheManage deviceInfoWithKey:@"se_un"],
             [self->_defaultCacheManage deviceInfoWithKey:@"extraInfo"]];
    
    url = [NSString stringWithFormat:@"%@?%@", staticURL, param];
    
//    NSLog(@"userInfo == %@", url);
    @weakify(self);
    [self->_HTTPManager managerSendUserInfoWithUrl:url success:^(id response) {
        @strongify(self);
        if (!self) return;
        self.hasSendUID = YES;
    } failure:^(NSError *error) {
        
    }];
}

- (void)browsePageCountAdd{ // 页面浏览次数自增一
    // 处理页面总访问次数
    NSInteger PageVisitTotalCount = [self->_defaultCacheManage PageVisitTotalCount];
    PageVisitTotalCount += 1;
    [self->_defaultCacheManage updatePageVisitTotalCountWithCount:PageVisitTotalCount];
}
- (void)launchCountAdd{ // 启动次数自增一
    // 更新APP总的启动次数
    NSInteger LaunchTotalCount = [_defaultCacheManage LaunchTotalCount];
    LaunchTotalCount += 1;
    [_defaultCacheManage updateLaunchTotalCountWithCount:LaunchTotalCount];
}
- (void)sendDebugStateDeviceMessage{
    NSString *staticURL = [NSString stringWithFormat:@"%@", [self->_defaultCacheManage deviceInfoWithKey:@"staticURL"]];
    NSArray *staticURLArr = [staticURL componentsSeparatedByString:@"/"];
    NSString *hostUrlStr = [NSString stringWithFormat:@"%@//%@/bas/tadebug/appShakeData",staticURLArr[0],staticURLArr[2]];
    
//    hostUrlStr = @"http://192.168.106.83:8081/bas/tadebug/appShakeData";
//    NSLog(@"host Url = %@", hostUrlStr);
    
    
    NSString *param = [NSString stringWithFormat:@"mpId=%@&wmDeviceId=%@&deviceModel=%@&deviceName=%@",
                     [self->_defaultCacheManage deviceInfoWithKey:@"mpId"],
                     [self->_defaultCacheManage deviceInfoWithKey:@"UUID"],
                     [self->_defaultCacheManage deviceInfoWithKey:@"dm"],
                     [TRSSystemInfo phoneName]];
    NSString *url = [NSString stringWithFormat:@"%@?%@", hostUrlStr, param];
    [self.HTTPManager manageDebugSendDeviceMessageWithURL:url success:^(id response) {
        self.debugSuccess = YES;
        return;
    } failure:^(NSError *error) {
        return;
    }];
    
    
}

@end
