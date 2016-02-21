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

@property (nonatomic, strong) NSArray *devicesArray; // 发现的所有设备
@property (nonatomic, strong) NSArray *selectedDevicesArray; // 选择发送的所有设备
@property (nonatomic, strong) NSArray *transferFiles;
@property (nonatomic, strong) NSArray *sectionTransferFiles; // 分好组的
@property (nonatomic, strong) NSArray *curentTransferFiles; // 当前正在传输的文件
- (NSArray *)sortTransferInfo:(NSArray *)infos;

// 接收文件
@property (nonatomic, strong) NSArray *currentReceiveFiles;
- (void)receiveItems:(NSArray *)items;

/**
 开始监听广播
 */
- (void)startListenBroadcast;

// 发送文件
- (void)startSendFile;
@property (nonatomic, strong) NSArray *currentTransferInfos;

//
- (void)removeAllSelectedFiles;
@property (nonatomic) NSInteger selectedFilesCount;
@property (nonatomic) BOOL photosCountChanged;
@property (nonatomic) BOOL musicsCountChanged;
@property (nonatomic) BOOL videosCountChanged;
@property (nonatomic) BOOL contactsCountChanged;

// 图片
@property (nonatomic, strong, readonly) NSMutableArray *selectedAssetsArr;
- (NSInteger)selectedPhotosCountInCollection:(NSString *)collection;

- (void)addAsset:(PHAsset *)asset inCollection:(NSString *)collection;
- (void)addAssets:(NSArray *)assets inCollection:(NSString *)collection;
- (void)removeAsset:(PHAsset *)asset inCollection:(NSString *)collection;
- (void)removeAssets:(NSArray *)assets inCollection:(NSString *)collection;
- (void)removeAllAssetsInCollection:(NSString *)collection;
- (BOOL)isSelectedWithAsset:(PHAsset *)asset inCollection:(NSString *)collection;

@end
