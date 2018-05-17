//
//  TRSReachability2.m
//  TRS_SDK
//
//  Created by 824810056 on 2018/1/17.
//  Copyright © 2018年 牟松. All rights reserved.
//

#import "TRSReachability2.h"
#import <objc/message.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

static TRSReachabilityStatus TRSReachabilityStateWithFlags(SCNetworkReachabilityFlags flags, BOOL allowWWAN){
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return TRSReachabilityStatusNone;
    }
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
        (flags & kSCNetworkReachabilityFlagsTransientConnection)) {
        return TRSReachabilityStatusNone;
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) && allowWWAN) {
        return TRSReachabilityStatusWWAN;
    }
    return TRSReachabilityStatusWiFi;
}
static void TRSReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    TRSReachability2 *self = ((__bridge TRSReachability2 *)info);
    if (self.notifyBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.notifyBlock(self);
        });
    }
}

@interface  TRSReachability2()
@property (nonatomic, assign) SCNetworkReachabilityRef ref;
@property (nonatomic, assign) BOOL scheduled;
@property (nonatomic, assign) BOOL allowWWAN;
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;
@end
@implementation TRSReachability2
+ (dispatch_queue_t)sharedQueue{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.TRS.TRSReachability", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}
- (instancetype)init{
    struct sockaddr_in zero_addr;
    bzero(&zero_addr, sizeof(zero_addr));
    zero_addr.sin_len = sizeof(zero_addr);
    zero_addr.sin_family = AF_INET;
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zero_addr);
    return [self initWithRef:ref];
}
- (instancetype)initWithRef:(SCNetworkReachabilityRef)ref {
    
    if (!ref) return nil;
    self = super.init;
    if (!self) return nil;
    _ref = ref;
    _allowWWAN = YES;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        _networkInfo = [CTTelephonyNetworkInfo new];
    }
    return self;
}
- (void)dealloc {
    self.notifyBlock = nil;
    self.scheduled = NO;
    CFRelease(self.ref);
}
- (void)setScheduled:(BOOL)scheduled {
    if (_scheduled == scheduled) return;
    _scheduled = scheduled;
    if (scheduled) {
        SCNetworkReachabilityContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
        SCNetworkReachabilitySetCallback(self.ref, TRSReachabilityCallback, &context);
        SCNetworkReachabilitySetDispatchQueue(self.ref, [self.class sharedQueue]);
    } else {
        SCNetworkReachabilitySetDispatchQueue(self.ref, NULL);
    }
}
- (SCNetworkReachabilityFlags)flags {
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(self.ref, &flags);
    return flags;
}
- (TRSReachabilityStatus)status {
    return TRSReachabilityStateWithFlags(self.flags, self.allowWWAN);
}
- (TRSReachabilityWWANStatus)WWANStatus {
    if (!self.networkInfo) return TRSReachabilityWWANStatusNone;
    NSString *status = self.networkInfo.currentRadioAccessTechnology;
    if (!status) return TRSReachabilityWWANStatusNone;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{CTRadioAccessTechnologyGPRS : @(TRSReachabilityWWANStatus2G),  // 2.5G   171Kbps
                CTRadioAccessTechnologyEdge : @(TRSReachabilityWWANStatus2G),  // 2.75G  384Kbps
                CTRadioAccessTechnologyWCDMA : @(TRSReachabilityWWANStatus3G), // 3G     3.6Mbps/384Kbps
                CTRadioAccessTechnologyHSDPA : @(TRSReachabilityWWANStatus3G), // 3.5G   14.4Mbps/384Kbps
                CTRadioAccessTechnologyHSUPA : @(TRSReachabilityWWANStatus3G), // 3.75G  14.4Mbps/5.76Mbps
                CTRadioAccessTechnologyCDMA1x : @(TRSReachabilityWWANStatus3G), // 2.5G
                CTRadioAccessTechnologyCDMAEVDORev0 : @(TRSReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORevA : @(TRSReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORevB : @(TRSReachabilityWWANStatus3G),
                CTRadioAccessTechnologyeHRPD : @(TRSReachabilityWWANStatus3G),
                CTRadioAccessTechnologyLTE : @(TRSReachabilityWWANStatus4G)}; // LTE:3.9G 150M/75M  LTE-Advanced:4G 300M/150M
    });
    NSNumber *num = dic[status];
    if (num) return num.unsignedIntegerValue;
    else return TRSReachabilityWWANStatusNone;
}
- (BOOL)isReachable {
    return self.status != TRSReachabilityStatusNone;
}
/// 创建一个reachability.
+ (instancetype)reachability {
    return self.new;
}

/// 根据当地的wifi创建一个reachability
+ (instancetype)reachabilityForLocalWifi{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    TRSReachability2 *one = [self reachabilityWithAddress:(const struct sockaddr *)&localWifiAddress];
    one.allowWWAN = NO;
    return one;
}

/// 通过传入的网址创建一个reachability
+ (nullable instancetype)reachabilityWithHostname:(NSString *)hostname{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    return [[self alloc] initWithRef:ref];
}

/// 根据IP创建一个reachability
+ (nullable instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    return [[self alloc] initWithRef:ref];
}

- (void)setNotifyBlock:(void (^)(TRSReachability2 *reachability))notifyBlock {
    _notifyBlock = [notifyBlock copy];
    self.scheduled = (self.notifyBlock != nil);
}

@end
