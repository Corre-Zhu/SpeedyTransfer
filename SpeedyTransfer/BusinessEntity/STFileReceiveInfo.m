//
//  STFileReceiveInfo.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileReceiveInfo.h"

@implementation STFileReceiveInfo

HT_DEF_SINGLETON(STFileReceiveInfo, shareInstant);

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super initWithDictionary:dic];
    if (self) {
        if (self.status == STFileReceiveStatusReceived) {
            self.progress = 1.0f;
        }
    }
    
    return self;
}

-(NSString *)_tableName{return @"FileReceive";}

@end
