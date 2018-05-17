//
//  TRSBaseModel.m
//  TRS_SDK
//
//  Created by 824810056 on 2017/12/11.
//  Copyright © 2017年 牟松. All rights reserved.
//

#import "TRSBaseModel.h"
#import "TRSCommen.h"

@implementation TRSBaseModel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.createAt = TRSCurrentTime36radix(TRSCurrentTime());
    }
    return self;
}
@end
