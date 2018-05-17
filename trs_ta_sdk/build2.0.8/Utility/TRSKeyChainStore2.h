//
//  TRSKeyChainStore2.h
//  TRS_SDK
//
//  Created by 824810056 on 2018/1/17.
//  Copyright © 2018年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRSKeyChainStore2 : NSObject
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;
@end
