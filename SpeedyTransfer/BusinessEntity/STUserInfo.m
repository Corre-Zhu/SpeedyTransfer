//
//  STUserInfo.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STUserInfo.h"

@implementation STUserInfo

HT_DEF_SINGLETON(STUserInfo, shareInstant);

- (NSString *)_tableName {
	return @"STUserInfo";
}

- (NSString *)_userId {
	return @"UserId";
}

- (NSString *)_nickname {
	return @"Nickname";
}

- (NSString *)_headUrl {
	return @"HeadUrl";
}

@end
