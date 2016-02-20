//
//  STFileTransferModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFileTransferInfo.h"
#import "HTSingleton.h"
#import "MCTransceiver.h"

@class STContactInfo;

@interface STFileTransferModel : NSObject

HT_AS_SINGLETON(STFileTransferModel, shareInstant);

@property (nonatomic, strong) NSArray *friendsInfoArray;

/**
 开始监听广播
 */
- (void)startListenBroadcast;

@end
