//
//  TRSBaseModel.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/11.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRSBaseModel : NSObject



@property (nonatomic, strong) NSData *jsonData; // 发送的信息体

@property (nonatomic, copy) NSString *createAt; // 数据的创建时间36进制

@end
