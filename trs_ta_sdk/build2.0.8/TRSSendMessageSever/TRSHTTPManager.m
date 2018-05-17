
//
//  TRSHTTPManager.m
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/28.
//  Copyright © 2017年 牟松. All rights reserved.
//  http://dev4.trs.net.cn/pages/viewpage.action?pageId=462946573

#import "TRSHTTPManager.h"
#import "TRSCommen.h"

@implementation TRSHTTPManager

+ (TRSHTTPManager *)sharedManger{
    static TRSHTTPManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TRSHTTPManager alloc] init];
    });
    return manager;
}

- (void)managerSendHTTPRequestWithUrl:(NSString *)url head1:(NSString *)head1 head2:(NSString *)head2 dataArray:(NSArray *)dataArray success:(void(^)(id response))success failure:(void(^)(NSError *error))failure{
    
    NSString *urlStr = [url stringByAppendingString:@"/ta"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20;
    [request setValue:TRSMD5(head1) forHTTPHeaderField:@"TACODE"];
    [request setValue:head2 forHTTPHeaderField:@"TAAPPKEY"];
    
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dataArray options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = sendData;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            failure(error);
            return;
        }
        
        if (!data){
            NSError *error = [[NSError alloc] init];
            failure(error);
            return;
        }
        
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([str isEqualToString:@"ok"]) {
            success(response);
        } else if ([str isEqualToString:@"-2"]){
            NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:-2 userInfo:nil];
            failure(error);
        } else {
            if (error) {
                failure(error);
            } else {
                NSError *error = [[NSError alloc] init];
                failure(error);
            }
        }
    }];
    [task resume];
    
    
}


- (void)managerSendDeviceIDWithUrl:(NSString *)url success:(void(^)(id response))success failure:(void(^)(NSError *error))failure{
    
    NSString *urlString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20;
    [request setValue:[NSString stringWithFormat:@"%@", TRSCurrentTime()] forHTTPHeaderField:@"x-ta-sdk-ticket"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            failure(error);
            return;
        }
        
        if (!data){
            NSError *error = [[NSError alloc] init];
            failure(error);
            return;
        }
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSNumber *code = dataDic[@"code"];
        if ([[code stringValue] isEqualToString:@"0"]) {
            success(response);
        } else {
            NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:1 userInfo:nil];
            failure(error);
        }
        
        
    }];
    [task resume];
}

- (void)managerSendUserInfoWithUrl:(NSString *)url success:(void(^)(id response))success failure:(void(^)(NSError *error))failure{
    NSString *urlString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20;
    [request setValue:[NSString stringWithFormat:@"%@", TRSCurrentTime()] forHTTPHeaderField:@"x-ta-sdk-ticket"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failure(error);
            return;
        }
        
        if (!data){
            NSError *error = [[NSError alloc] init];
            failure(error);
            return;
        }
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"dataDic == %@", dataDic);
        NSNumber *code = dataDic[@"code"];
        if ([[code stringValue] isEqualToString:@"0"]) {
            success(response);
        } else {
            NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:1 userInfo:nil];
            failure(error);
        }
   
    }];
    [task resume];
    
}

- (void)managerDebugSendHTTPRequestWithUrl:(NSString *)url head1:(NSString *)head1 head2:(NSString *)head2 dataArray:(NSArray *)dataArray success:(void(^)(id response))success failure:(void(^)(NSError *error))failure{
    
    
    NSString *urlStr = [url stringByAppendingString:@"/ta"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20;
    [request setValue:TRSMD5(head1) forHTTPHeaderField:@"TACODE"];
    [request setValue:head2 forHTTPHeaderField:@"TAAPPKEY"];
    
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dataArray options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = sendData;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([str isEqualToString:@"ok"]) {
            success(response);
        } else {
            NSError *error = [[NSError alloc] init];
            failure(error);
        }
    }];
    [task resume];
}

- (void)manageDebugSendDeviceMessageWithURL:(NSString *)url success:(void(^)(id response))success failure:(void(^)(NSError *error))failure{
    NSString *urlString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failure(error);
            return;
        }
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSNumber *code = dataDic[@"code"];
        if ([[code stringValue] isEqualToString:@"0"]) {
            success(response);
        } else {
            NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:1 userInfo:nil];
            failure(error);
        }
        
    }];
    [task resume];
    
}
@end
