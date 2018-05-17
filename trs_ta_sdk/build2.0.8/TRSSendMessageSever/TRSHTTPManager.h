//
//  TRSHTTPManager.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/28.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRSHTTPManager : NSObject

+ (TRSHTTPManager *)sharedManger;
- (void)managerSendHTTPRequestWithUrl:(NSString *)url head1:(NSString *)head1 head2:(NSString *)head2 dataArray:(NSArray *)dataArray success:(void(^)(id response))success failure:(void(^)(NSError *error))failure;

- (void)managerSendDeviceIDWithUrl:(NSString *)url success:(void(^)(id response))success failure:(void(^)(NSError *error))failure;


- (void)managerSendUserInfoWithUrl:(NSString *)url success:(void(^)(id response))success failure:(void(^)(NSError *error))failure;



- (void)managerDebugSendHTTPRequestWithUrl:(NSString *)url head1:(NSString *)head1 head2:(NSString *)head2 dataArray:(NSArray *)dataArray success:(void(^)(id response))success failure:(void(^)(NSError *error))failure; //debug模式下调用，数据单条发送
- (void)manageDebugSendDeviceMessageWithURL:(NSString *)url success:(void(^)(id response))success failure:(void(^)(NSError *error))failure; // debug模式下给后台发送设备信息
@end
