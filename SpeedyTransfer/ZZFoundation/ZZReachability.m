//
//  ZZ Reachability.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/9.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "ZZReachability.h"

@implementation ZZReachability

+ (ZZReachability *)shareInstance {
	static ZZReachability *shareInstance = nil;
	if (!shareInstance) {
		shareInstance = [ZZReachability reachabilityForLocalWiFi];
		[shareInstance startNotifier];
	}
	
	return shareInstance;
}

@end
