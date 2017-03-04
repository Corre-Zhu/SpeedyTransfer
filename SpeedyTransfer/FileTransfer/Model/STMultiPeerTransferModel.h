//
//  STMultiPeerTransferModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/26.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"

typedef NS_ENUM (NSInteger, STMultiPeerState) {
    STMultiPeerStateBrowsing = -1,
    STMultiPeerStateNotConnected,
    STMultiPeerStateConnecting,
    STMultiPeerStateConnected
};

@interface STMultiPeerTransferModel : NSObject

HT_AS_SINGLETON(STMultiPeerTransferModel, shareInstant);

@property (nonatomic) STMultiPeerState state; // 连接状态

- (void)startAdvertising; // 开始广播
- (void)startBrowsingForName:(NSString *)name; // 开始监听扫描到的设备
- (void)reset; // 停止广播和监听

- (void)sendData:(NSData *)data;
- (void)sendImage:(NSURL *)imageUrl;


@end
