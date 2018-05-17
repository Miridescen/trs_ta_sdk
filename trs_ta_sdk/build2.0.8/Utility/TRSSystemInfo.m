//
//  TRSSystemInfo.m
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/8.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import "TRSSystemInfo.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <mach/mach.h>
#include <arpa/inet.h>
#include <ifaddrs.h>

#define TRS_IOS_CELLULAR    @"pdp_ip0"
#define TRS_IOS_WIFI        @"en0"
#define TRS_IOS_VPN         @"utun0"
#define TRS_IP_ADDR_IPv4    @"ipv4"
#define TRS_IP_ADDR_IPv6    @"ipv6"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "TRSReachability2.h"

#import <AdSupport/ASIdentifierManager.h>

@implementation TRSSystemInfo
/** APP名称 */
+ (NSString *)appName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]?[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]:@"";
}

/** APP版本 */
+ (NSString *)appVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]?[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]:@"";
}

/** bundleID */
+ (NSString *)bundleID{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]?[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]:@"";
}

/** 运营商 */
+ (NSString *)carrier{
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    
    NSString *currentCountryCode = [carrier mobileCountryCode];
    NSString *mobileNetWorkCode = [carrier mobileNetworkCode];
    
    if (mobileNetWorkCode == nil || mobileNetWorkCode.length <1 || [mobileNetWorkCode isEqualToString:@"SIM Not Inserted"] ) {
        return @"无运营商";
    }
    
    if ([currentCountryCode isEqualToString:@"460"]) {
        
        if ([mobileNetWorkCode isEqualToString:@"00"] ||
            [mobileNetWorkCode isEqualToString:@"02"] ||
            [mobileNetWorkCode isEqualToString:@"07"] ||
            [mobileNetWorkCode isEqualToString:@"08"]) {
            
            // 中国移动
            return @"中国移动";
        }
        
        if ([mobileNetWorkCode isEqualToString:@"01"] ||
            [mobileNetWorkCode isEqualToString:@"06"] ||
            [mobileNetWorkCode isEqualToString:@"09"]) {
            
            // 中国联通
            return @"中国联通";
        }
        
        if ([mobileNetWorkCode isEqualToString:@"03"] ||
            [mobileNetWorkCode isEqualToString:@"05"] ||
            [mobileNetWorkCode isEqualToString:@"11"]) {
            
            // 中国电信
            return @"中国电信";
        }
        
        if ([mobileNetWorkCode isEqualToString:@"20"]) {
            
            // 中国铁通
            return @"中国铁通";
        }
        
    }
    
    return @"境外运营商";
}

/** 内网IP */
+ (NSString *)clientIP{
    return [self.class getIPAddress:YES];
}

/** 地区设置（国家） */
+ (NSString *)country{
    return  [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]?[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]:@"";
}

/** 设备型号 */
+ (NSString *)deviceModel{
    return [self.class machineModelName];
}

/** 设备屏幕高度 */
+ (NSString *)screenHeight{
    return [NSString stringWithFormat:@"%f",[UIScreen mainScreen].bounds.size.height];
}

/** 设备屏幕宽度 */
+ (NSString *)screenWidth{
    return [NSString stringWithFormat:@"%f", [UIScreen mainScreen].bounds.size.width];
}


/**
 是否越狱
 
 @return 0 == 没有越狱， 1 == 已经越狱
 */
+ (NSString *)jailbroken{
    if ([self.class isSimulator]) return @"0"; // 不考虑模拟器
    
    NSArray *paths = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt/",
                       @"/private/var/lib/cydia",
                       @"/private/var/stash"];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return @"1";
    }
    
    FILE *bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return @"1";
    }
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    NSString *path = [NSString stringWithFormat:@"/private/%@", (__bridge_transfer NSString *)string];
    if ([@"test" writeToFile : path atomically : YES encoding : NSUTF8StringEncoding error : NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return @"1";
    }
    
    return @"0";
}

/** 语言设置 */
+ (NSString *)language{
    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]?[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]:@"";
}

/**
 网络类型
 
 @return 手机上网方式，如Wifi、4G、3G、2G、无网络等
 */
+ (NSString *)networkType{
    
    TRSReachability2 *reachability = [TRSReachability2 reachability];
    switch (reachability.status) {
        case TRSReachabilityStatusNone:
            return @"无网络";
            break;
        case TRSReachabilityStatusWWAN:
        {
            switch (reachability.WWANStatus) {
                case TRSReachabilityWWANStatusNone:
                    return @"无网络";
                    break;
                case TRSReachabilityWWANStatus2G:
                    return @"2G";
                    break;
                case TRSReachabilityWWANStatus3G:
                    return @"3G";
                    break;
                case TRSReachabilityWWANStatus4G:
                    return @"4G";
                    break;
                default:
                    break;
            }
        }
            break;
        case TRSReachabilityStatusWiFi:
            return @"Wifi";
            break;
        default:
            break;
    }
    return @"";
}

/**
 操作系统
 
 @return 固定返回iOS
 */
+ (NSString *)os{
    return @"iOS";
}

/** 操作系统版本 */
+ (NSString *)osVersion{
    return [[UIDevice currentDevice] systemVersion]?[[UIDevice currentDevice] systemVersion]:@"";
}

/** sdk版本 */
+ (NSString *)sdkVersion{
    return @"2.0.0";
}

/** 设置时区 */
+ (NSString *)timeZone{
    return [NSTimeZone systemTimeZone]?[NSString stringWithFormat:@"%@", [NSTimeZone systemTimeZone]]:@"";
}
/** IDFA */
+ (NSString *)IDFA{
    ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
    NSString *IDFA = manager.advertisingIdentifier.UUIDString;
    return IDFA?IDFA:@"";
}

#pragma private method -------------
+ (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}
+ (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

+ (NSString *)machineModelName {  // https://www.theiphonewiki.com/wiki/Models
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self.class machineModel];
        if (!model) return;
        NSDictionary *dic = @{
                              @"Watch1,1" : @"Apple Watch 38mm",
                              @"Watch1,2" : @"Apple Watch 42mm",
                              @"Watch2,3" : @"Apple Watch Series 2 38mm",
                              @"Watch2,4" : @"Apple Watch Series 2 42mm",
                              @"Watch2,6" : @"Apple Watch Series 1 38mm",
                              @"Watch1,7" : @"Apple Watch Series 1 42mm",
                              
                              @"iPod1,1" : @"iPod touch 1",
                              @"iPod2,1" : @"iPod touch 2",
                              @"iPod3,1" : @"iPod touch 3",
                              @"iPod4,1" : @"iPod touch 4",
                              @"iPod5,1" : @"iPod touch 5",
                              @"iPod7,1" : @"iPod touch 6",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              @"iPhone9,1" : @"iPhone 7",
                              @"iPhone9,2" : @"iPhone 7 Plus",
                              @"iPhone9,3" : @"iPhone 7",
                              @"iPhone9,4" : @"iPhone 7 Plus",
                              @"iPhone10,1" : @"iPhone 8",
                              @"iPhone10,2" : @"iPhone 8 Plus",
                              @"iPhone10,3" : @"iPhone X",
                              @"iPhone10,4" : @"iPhone 8",
                              @"iPhone10,5" : @"iPhone 8 Plus",
                              @"iPhone10,6" : @"iPhone X",
                              
                              @"iPad1,1" : @"iPad 1",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2",
                              @"iPad2,5" : @"iPad mini 1",
                              @"iPad2,6" : @"iPad mini 1",
                              @"iPad2,7" : @"iPad mini 1",
                              @"iPad3,1" : @"iPad 3 (WiFi)",
                              @"iPad3,2" : @"iPad 3 (4G)",
                              @"iPad3,3" : @"iPad 3 (4G)",
                              @"iPad3,4" : @"iPad 4",
                              @"iPad3,5" : @"iPad 4",
                              @"iPad3,6" : @"iPad 4",
                              @"iPad4,1" : @"iPad Air",
                              @"iPad4,2" : @"iPad Air",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" : @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" : @"iPad mini 4",
                              @"iPad5,2" : @"iPad mini 4",
                              @"iPad5,3" : @"iPad Air 2",
                              @"iPad5,4" : @"iPad Air 2",
                              @"iPad6,3" : @"iPad Pro (9.7 inch)",
                              @"iPad6,4" : @"iPad Pro (9.7 inch)",
                              @"iPad6,7" : @"iPad Pro (12.9 inch)",
                              @"iPad6,8" : @"iPad Pro (12.9 inch)",
                              @"iPad6,11" : @"iPad 5",
                              @"iPad6,12" : @"iPad 5",
                              @"iPad7,1" : @"iPad Pro 2 (12.9 inch)",
                              @"iPad7,2" : @"iPad Pro 2 (12.9 inch)",
                              @"iPad7,3" : @"iPad Pro (10.5 inch)",
                              @"iPad7,4" : @"iPad Pro (10.5 inch)",
                              
                              @"AppleTV2,1" : @"Apple TV 2",
                              @"AppleTV3,1" : @"Apple TV 3",
                              @"AppleTV3,2" : @"Apple TV 3",
                              @"AppleTV5,3" : @"Apple TV 4",
                              @"AppleTV6,2" : @"Apple TV 4k",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[model];
        if (!name) name = model;
        
        name = model; // 不用转换手机型号，发送原始信息
    });
    return name;
}


+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ TRS_IOS_VPN @"/" TRS_IP_ADDR_IPv4, TRS_IOS_VPN @"/" TRS_IP_ADDR_IPv6, TRS_IOS_WIFI @"/" TRS_IP_ADDR_IPv4, TRS_IOS_WIFI @"/" TRS_IP_ADDR_IPv6, TRS_IOS_CELLULAR @"/" TRS_IP_ADDR_IPv4, TRS_IOS_CELLULAR @"/" TRS_IP_ADDR_IPv6 ] :
    @[ TRS_IOS_VPN @"/" TRS_IP_ADDR_IPv6, TRS_IOS_VPN @"/" TRS_IP_ADDR_IPv4, TRS_IOS_WIFI @"/" TRS_IP_ADDR_IPv6, TRS_IOS_WIFI @"/" TRS_IP_ADDR_IPv4, TRS_IOS_CELLULAR @"/" TRS_IP_ADDR_IPv6, TRS_IOS_CELLULAR @"/" TRS_IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
//            NSRange resultRange = [firstMatch rangeAtIndex:0];
//            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
//            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = TRS_IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = TRS_IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+(NSString *)phoneName{
    return [[UIDevice currentDevice] name];
}

/**
 获取当前viewController的类名
 */
+ (NSString *)currentVC
{
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (viewController.presentedViewController) {
        
        // Return presented view controller
        return NSStringFromClass(viewController.class);
        
    } else if ([viewController isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) viewController;
        if (svc.viewControllers.count > 0)
            return NSStringFromClass(svc.viewControllers.lastObject.class);
        else
            return NSStringFromClass(viewController.class);
        
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* svc = (UINavigationController*) viewController;
        if (svc.viewControllers.count > 0)
            return NSStringFromClass(svc.topViewController.class);
        else
            return NSStringFromClass(viewController.class);
        
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) viewController;
        if (svc.viewControllers.count > 0)
            return NSStringFromClass(svc.selectedViewController.class);
        else
            return NSStringFromClass(viewController.class);
        
    } else {
        return NSStringFromClass(viewController.class);
        
    }
}

@end
