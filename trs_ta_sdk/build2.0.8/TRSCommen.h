//
//  TRSCommen.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/12.
//  Copyright © 2017年 牟松. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CommonCrypto/CommonDigest.h"

#ifndef TRSCommen_h
#define TRSCommen_h

#define TRSAnalyticsBuild   2.0.0
#define TRSAnalyticsVersion 2.0.0

// environment
#ifdef __cplusplus
#define TRS_EXTERN_C_BEGIN  extern "C" {
#define TRS_EXTERN_C_END  }
#else
#define TRS_EXTERN_C_BEGIN
#define TRS_EXTERN_C_END
#endif

TRS_EXTERN_C_BEGIN

/**
 是否打印
 */
#ifdef DEBUG
//#define TRSNSLog(FORMAT, ...) fprintf(stderr,"file__%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define TRSNSLog(...)
#else
#define TRSNSLog(...)
#endif
/**
 弱引用
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif
/**
 强引用
 */
#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

/**
 DB
 */
#if ! __has_feature(objc_arc)
#define TRSDBAutorelease(__v) ([__v autorelease]);
#define TRSDBReturnAutoreleased TRSDBAutorelease

#define TRSDBRetain(__v) ([__v retain]);
#define TRSDBReturnRetained TRSDBRetain

#define TRSDBRelease(__v) ([__v release]);

#define TRSDBDispatchQueueRelease(__v) (dispatch_release(__v));
#else
// -fobjc-arc
#define TRSDBAutorelease(__v)
#define TRSDBReturnAutoreleased(__v) (__v)

#define TRSDBRetain(__v)
#define TRSDBReturnRetained(__v) (__v)

#define TRSDBRelease(__v)

// If OS_OBJECT_USE_OBJC=1, then the dispatch objects will be treated like ObjC objects
// and will participate in ARC.
// See the section on "Dispatch Queues and Automatic Reference Counting" in "Grand Central Dispatch (GCD) Reference" for details.
#if OS_OBJECT_USE_OBJC
#define TRSDBDispatchQueueRelease(__v)
#else
#define TRSDBDispatchQueueRelease(__v) (dispatch_release(__v));
#endif
#endif

/**
 验证一个字符串是否为nil

 @param string 传入的字符串
 @return bool值
 */
static inline bool TRSBlankStr(NSString *string){
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

/**
 返回当前时间戳（毫秒级）

 @return 时间戳
 */
static inline NSNumber* TRSCurrentTime(){
    return [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
}
static inline NSString* TRSCurrentTime36radix(NSNumber *currentTime){
    long long value = [currentTime longLongValue];
    if (value == 0)
        return @"0";
    int radix = 36;
    
    const unsigned buffsize = 64;
    unichar buffer[buffsize];
    unsigned offset = buffsize;
    static const char digits[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    
    long long absValue = llabs(value);
    while (absValue > 0) {
        buffer[--offset] = (unichar)digits[absValue % radix];
        absValue /= radix;
    }
    
    if (value < 0)
        buffer[--offset] = '-';
    
    return [[NSString alloc] initWithCharacters:buffer + offset
                                         length:buffsize - offset];
}

/**
 MD5加密
 */
static inline NSString* TRSMD5(NSString *inputStr){
    const char *cStr = [inputStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), result);
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


/**
 model转字典
 */
static inline NSDictionary* TRSModelToDictionary(NSObject *model){
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [model valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];

    }
    free(properties);
    return [props copy];
}

/**
 字典转json
 */
static inline NSString* TRSDirectoryToJson(NSDictionary *dic){
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] copy];
    
}

/**
 json转字典
 */
static inline NSDictionary* TRSJsonToDirectory(NSString *json){
    if (TRSBlankStr(json)) return nil;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) return nil;
    return [dic copy];
}

static inline NSData* TRSDirectoryToData(NSDictionary *dic){
    
    if (dic == nil) return nil;
    
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    if (err) return nil;
    return [data copy];
}

static inline NSDictionary* TRSDataToDirectory(NSData *data){
    
    if (data == nil) return nil;
    
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) return nil;
    return [dic copy];
}

static inline NSString* TRSDirectoryToString(NSDictionary *dic){
    if (dic == nil || [dic allKeys].count == 0) return nil;
    NSString *jsonString = [[NSString alloc] init];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData) {
//        NSLog(@"error: %@", error);
        return nil;
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" "withString:@""options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n"withString:@""options:NSLiteralSearch range:range2];
    
    return [mutStr copy];
}



TRS_EXTERN_C_END


#endif /* TRSCommen_h */
