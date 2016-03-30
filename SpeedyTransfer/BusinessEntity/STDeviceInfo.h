//
//  STDeviceInfo.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"

#define DBDeviceInfo [STDeviceInfo shareInstant]

@interface STDeviceInfo : NSObject

HT_AS_SINGLETON(STDeviceInfo, shareInstant)

@property (nonatomic) BOOL isBrowser; // 是否是浏览器（通过无界连接的）
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) UIImage *headImage;

@property (nonatomic, strong) NSString *ip;
@property (nonatomic) uint16_t port;
@property (nonatomic) NSTimeInterval lastUpdateTimestamp;
@property (nonatomic, strong) NSString *recvUrl;
@property (nonatomic, strong) NSString *cancelUrl;

@property(nonatomic,readonly)NSString *_tableName;
@property(nonatomic,readonly)NSString *_deviceName;

- (BOOL)setup;

@property (nonatomic, strong) NSMutableArray *prepareToSendFiles; // 准备要发送的文件
@property (nonatomic, strong) NSMutableArray *sendingTransferInfos; // 正在发送的文件

- (void)addSendItems:(NSArray *)files; // 添加准备发送的文件
- (void)startSend; // 开始向这个设备发送文件

- (void)cancelSendItemsAndPostCancel:(BOOL)postCancel; // 取消向这个设备发送文件

@end
