//
//  TRSEventModelConfig.h
//  TRSAnalytics
//
//  Created by 824810056 on 2018/3/8.
//  Copyright © 2018年 Miridescent. All rights reserved.
//

#import <Foundation/Foundation.h>


@class TRSBaseModel;
@interface TRSEventModelConfig : NSObject

@property (nonatomic, assign) int se_no; // 事件在页面中的序数

@property (nonatomic, copy) NSString *vt; // 访问时间
@property (nonatomic, copy) NSString *pv;

@property (nonatomic, copy) NSString *eventCode; // 标准事件用

- (TRSBaseModel *)configPageModelWith:(NSDictionary *)properties;


@end
