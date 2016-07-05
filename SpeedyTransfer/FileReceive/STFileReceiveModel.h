//
//  STFileReceiveModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"

@interface STFileReceiveModel : NSObject

HT_AS_SINGLETON(STFileReceiveModel, shareInstant)

/**
 开始广播
 */
- (void)startBroadcast;
- (void)stopBroadcast;


@end
