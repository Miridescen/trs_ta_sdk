//
//  TRSPageConfig.h
//  TRSAnalytics
//
//  Created by 824810056 on 2018/2/7.
//  Copyright © 2018年 Miridescent. All rights reserved.
// 配置页面发送信息

#import <Foundation/Foundation.h>

@class TRSBaseModel;

@interface TRSPageConfig : NSObject

@property (nonatomic, copy) NSString *vt; // 访问时间
@property (nonatomic, copy) NSString *pv;

@property (nonatomic, strong) NSNumber *pageBeginTime;
@property (nonatomic, strong) NSNumber *pageEndTime;

@property (nonatomic, copy) NSString *pageName;

@property (nonatomic, assign) NSInteger browsePageCount;

@property (nonatomic, copy) NSString *refer;

- (TRSBaseModel *)configPageModelWith:(NSDictionary *)properties;

@end
