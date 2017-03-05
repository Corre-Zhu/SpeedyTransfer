//
//  STFileTransferModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferBaseModel.h"

extern NSString *const KDeviceNotConnectedNotification;

@interface STFileTransferModel : STFileTransferBaseModel

HT_AS_SINGLETON(STFileTransferModel, shareInstant);

/**
 开始监听广播
 */
- (void)startListenBroadcast;
- (void)stopListenBroadcast;

@property (nonatomic, strong) NSArray *devicesArray; // 发现的所有设备
@property (nonatomic, strong) NSArray *selectedDevicesArray; // 选择发送的所有设备
- (void)removeAllDevices; // 移除所有发现的设备
- (void)removeDevicesWithIp:(NSString *)ip; // 收到cancel时移除该设备

// 文件接收
@property (nonatomic, strong) NSMutableArray *prepareToReceiveFiles; // 收到的的所有文件
@property (nonatomic, strong) STFileTransferInfo *currentReceivingInfo; // 当前正在下载的文件
- (void)receiveItems:(NSArray *)items;

// 文件发送
- (NSArray *)insertItemsToDbWithDeviceInfo:(STDeviceInfo *)deviceInfo fileInfos:(NSArray *)fileInfos;
- (void)updateTransferStatus:(STFileTransferStatus)status withIdentifier:(NSString *)identifier;
- (void)updateDownloadSpeed:(float)downloadSpeed withIdentifier:(NSString *)identifier;
- (void)updateAssetIdentifier:(NSString *)assetIdentifier withIdentifier:(NSString *)identifier;
- (void)addTransferFile:(STFileTransferInfo *)info;
- (void)sendItems:(NSArray *)items;
- (void)writeToSavedPhotosAlbum:(NSString *)path isImage:(BOOL)isImage;

// 取消传输
- (void)cancelAllTransferFile; // 取消所有文件传输(发送和接收)
- (void)cancelSendItemsTo:(NSString *)ip; // 取消发送给。。
- (void)cancelReceiveItemsFrom:(NSString *)ip; // 取消接收自。。

// 发现无界设备
- (void)addNewBrowser:(NSString *)host;
- (void)removeAllBrowser; // 移除所有无界设备

// 通过接收文件发现的设备
- (void)addDevice:(STDeviceInfo *)deviceInfo;

@end
