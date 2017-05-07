//
//  STFileTransferBaseModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/3/5.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTFMDatabase.h"
#import "AppDelegate.h"
#import "HTSQLBuffer.h"
#import "STDeviceInfo.h"
#import "STFileTransferInfo.h"
#import "HTSingleton.h"
#import "AppDelegate.h"
#import "ZZFileUtility.h"
#import <Photos/Photos.h>

@class STContactInfo;

@protocol STFileTransferBaseModelDelegate <NSObject>

- (void)shouldReceiveFile:(BOOL)flag;

@end

@interface STFileTransferBaseModel : NSObject {
    HTFMDatabase *database;
    __block PHAssetCollection *toSaveCollection;
}

// 所有文件传输记录
@property (nonatomic, strong) NSArray *transferFiles;
@property (nonatomic, strong) NSArray *sectionTransferFiles; // 分好组的
- (NSArray *)sortTransferInfo:(NSArray *)infos;
- (void)addTransferFile:(STFileTransferInfo *)info;
- (void)updateTransferStatus:(STFileTransferStatus)status withIdentifier:(NSString *)identifier;
- (void)insertTransferInfo:(STFileTransferInfo *)info;
- (void)updateAssetIdentifier:(NSString *)assetIdentifier withIdentifier:(NSString *)identifier;
- (void)createToSaveCollectionIfNeeded:(void(^)(PHAssetCollection *assetCollection))completionHandler;

- (BOOL)shouldReceiveFile; // 是否可以接收文件，当磁盘剩余容量少于300M时，不接收文件

- (NSString *)fileNameWithIdentifier:(NSString *)identifier;

@property (nonatomic, weak) id<STFileTransferBaseModelDelegate> delegate;

@end
