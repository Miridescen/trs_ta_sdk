//
//  TRSGetUUID2.m
//  TRS_SDK
//
//  Created by 824810056 on 2018/1/17.
//  Copyright © 2018年 牟松. All rights reserved.
//

#import "TRSGetUUID2.h"
#import "TRSKeyChainStore2.h"

#define  TRS_KEY_USERNAME_PASSWORD @"com.company.app.usernamepassword"
#define  TRS_KEY_USERNAME @"com.company.app.username"
#define  TRS_KEY_PASSWORD @"com.company.app.password"
@implementation TRSGetUUID2
+(NSString *)getUUID
{
    
    NSString * strUUID = (NSString *)[TRSKeyChainStore2 load:@"com.company.app.usernamepassword"];
    
    //首次执行该方法时，uuid为空
    
    if ([strUUID isEqualToString:@""] || !strUUID)
    {
        
        //生成一个uuid的方法
        
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain  但是这一句根本不执行
        
        [TRSKeyChainStore2 save:TRS_KEY_USERNAME_PASSWORD data:strUUID];
        
    }
    return strUUID;
}
@end
