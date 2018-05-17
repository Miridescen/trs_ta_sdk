//
//  TRSSystemEventConfig.h
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/27.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRSBaseModel;

typedef NS_ENUM(NSUInteger, TRSSystemEventType) {
    TRSSystemEventTypeBas_startup,
    TRSSystemEventTypeBas_suspend,
    TRSSystemEventTypeBas_resume,
    TRSSystemEventTypeBas_activedOnly,
};

@interface TRSSystemEventConfig : NSObject
@property (nonatomic, strong) NSNumber *beginTime;
@property (nonatomic, strong) NSNumber *endTime;

@property (nonatomic, assign) NSInteger browsePageCount;

@property (nonatomic, copy) NSString *beginTime36;


- (TRSBaseModel *)configSystemEventModelWithEventType:(TRSSystemEventType)eventType;
@end
