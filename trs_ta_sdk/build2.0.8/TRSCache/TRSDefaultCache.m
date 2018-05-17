//
//  TRSDefaultCache.m
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/27.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import "TRSDefaultCache.h"
#import "TRSCommen.h"

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)


@interface TRSDefaultCache(){
    dispatch_semaphore_t _lock;
}
@end
@implementation TRSDefaultCache
+ (TRSDefaultCache *)sharedManage{
    static TRSDefaultCache *sharedManage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManage = [[TRSDefaultCache alloc] init];
    });
    return sharedManage;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        
        NSString *documentDicPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        self.cachePath = [documentDicPath stringByAppendingString:@"/TRSFile/TRSCache/"];
        _lock = dispatch_semaphore_create(1);
        _ioQueue = dispatch_queue_create("com.TRS.DeviceInfoCache", DISPATCH_QUEUE_SERIAL);
        TRSNSLog(@"cachePath == %@",self.cachePath);
        if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:self.cachePath] )
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@TRSDeviceInfo.plist", self.cachePath]];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            _deviceInfoDic = [dic mutableCopy];
        }else{
            _deviceInfoDic = [[NSMutableDictionary alloc] init];
            [_deviceInfoDic setObject:@0 forKey:@"LaunchTotalCount"]; // 这两个key是独立出来的，因为要累加
            [_deviceInfoDic setObject:@0 forKey:@"PageVisitTotalCount"];
        }
        [_deviceInfoDic writeToFile:[NSString stringWithFormat:@"%@TRSDeviceInfo.plist", self.cachePath] atomically:YES];
    }
    return self;
}
- (void)memoryDeviceInfoWithKey:(NSString *)key value:(id)value{
    if (key == nil || value == nil) {
        TRSNSLog(@"DeviceInfoCache  存储信息失败：key和value不可为nil");
        return;
    }
    
    Lock();
    [_deviceInfoDic setObject:value forKey:key];
    [_deviceInfoDic writeToFile:[NSString stringWithFormat:@"%@TRSDeviceInfo.plist", _cachePath] atomically:YES];
    Unlock();
    
}
- (void)deleteDeviceInfoWithKey:(NSString *)key{
    if (key == nil) {
        TRSNSLog(@"DeviceInfoCache  删除信息失败：key不可为nil");
        return;
    }
    Lock();
    [_deviceInfoDic removeObjectForKey:key];
    [_deviceInfoDic writeToFile:[NSString stringWithFormat:@"%@TRSDeviceInfo.plist", _cachePath] atomically:YES];
    Unlock();
}
- (id)deviceInfoValueWithKey:(NSString *)key{
    if (key == nil) {
        TRSNSLog(@"DeviceInfoCache  存储信息失败：缺失key");
        return @"";
    }
    Lock();
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@TRSDeviceInfo.plist", self.cachePath]];
    Unlock();
    return [dic objectForKey:key];
}

- (void)memoryDeviceInfoWitDictionary:(NSDictionary *)dic{
    if (dic == nil){
        TRSNSLog(@"DeviceInfoCache  要存储的字典为空");
        return;
    }
    
    Lock();
    for (NSString *key in dic.allKeys) {
        [_deviceInfoDic setObject:dic[key] forKey:key];
    }
    [_deviceInfoDic writeToFile:[NSString stringWithFormat:@"%@TRSDeviceInfo.plist", self.cachePath] atomically:YES];
    Unlock();
}
@end
