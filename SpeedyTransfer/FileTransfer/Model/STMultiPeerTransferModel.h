//
//  STMultiPeerTransferModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/26.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STFileTransferBaseModel.h"

typedef NS_ENUM (NSInteger, STMultiPeerState) {
    STMultiPeerStateBrowsing = -1,
    STMultiPeerStateNotConnected,
    STMultiPeerStateConnecting,
    STMultiPeerStateConnected
};

@interface STMultiPeerTransferModel : STFileTransferBaseModel

HT_AS_SINGLETON(STMultiPeerTransferModel, shareInstant);

@property (nonatomic) STMultiPeerState state; // 连接状态
@property (strong, nonatomic) STDeviceInfo *deviceInfo; // 当前连接的设备

- (void)startAdvertising; // 发送方开始广播
- (void)startBrowsingForName:(NSString *)name; // 接收方开始监听扫描到的设备
- (void)reset; // 停止广播和监听

// 添加待发送文件
- (void)addSendItems:(NSArray *)items;

// 取消所有文件传输(发送和接收)
- (void)cancelAllTransferFile;


@end
