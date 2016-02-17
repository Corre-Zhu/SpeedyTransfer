//
//  STUserInfo.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"

#define DBUserInfo [STUserInfo shareInstant]

@interface STUserInfo : NSObject

HT_AS_SINGLETON(STUserInfo, shareInstant)

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *headUrl;

@property(nonatomic,readonly)NSString *_tableName;
@property(nonatomic,readonly)NSString *_userId;
@property(nonatomic,readonly)NSString *_nickname;
@property(nonatomic,readonly)NSString *_headUrl;

@end
