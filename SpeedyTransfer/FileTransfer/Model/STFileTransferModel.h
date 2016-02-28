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
@class STDeviceInfo;

extern NSString *const KDeviceNotConnectedNotification;

@interface STFileTransferModel : NSObject

HT_AS_SINGLETON(STFileTransferModel, shareInstant);

/**
 开始监听广播
 */
- (void)startListenBroadcast;

@property (nonatomic, strong) NSArray *devicesArray; // 发现的所有设备
@property (nonatomic, strong) NSArray *selectedDevicesArray; // 选择发送的所有设备

// 所有文件传输记录
@property (nonatomic, strong) NSArray *transferFiles;
@property (nonatomic, strong) NSArray *sectionTransferFiles; // 分好组的
- (NSArray *)sortTransferInfo:(NSArray *)infos;

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
@end
