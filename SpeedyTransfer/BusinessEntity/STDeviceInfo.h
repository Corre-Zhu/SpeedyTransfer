//
//  STDeviceInfo.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"

#define DBUserInfo [STDeviceInfo shareInstant]

@interface STDeviceInfo : NSObject

HT_AS_SINGLETON(STDeviceInfo, shareInstant)

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) UIImage *headImage;

@property (nonatomic, strong) NSString *ip;
@property (nonatomic) uint16_t port;
@property (nonatomic) NSTimeInterval lastUpdateTimestamp;

@property(nonatomic,readonly)NSString *_tableName;
@property(nonatomic,readonly)NSString *_deviceId;
@property(nonatomic,readonly)NSString *_deviceName;

- (void)setup;

@end
