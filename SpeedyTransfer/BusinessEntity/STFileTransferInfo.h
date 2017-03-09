//
//  STFileTransferModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"

#define DBFileTransfer [STFileTransferInfo shareInstant]

// KVO path strings for observing changes to properties of NSProgress
static NSString * const kProgressCancelledKeyPath          = @"cancelled";
static NSString * const kProgressCompletedUnitCountKeyPath = @"completedUnitCount";

typedef NS_ENUM(NSInteger, STFileType) {
    STFileTypePicture        = 0,
    STFileTypeMusic          = 1,
    STFileTypeVideo          = 2,
    STFileTypeContact        = 3,
    STFileTypeOther          = 4,
};

typedef NS_ENUM(NSInteger, STFileTransferType) {
	STFileTransferTypeSend   = 0,
	STFileTransferTypeReceive
};

typedef NS_ENUM(NSInteger, STFileTransferStatus) {
	STFileTransferStatusSending                       = 0,
	STFileTransferStatusSent,
	STFileTransferStatusSendFailed,
	STFileTransferStatusReceiving,
	STFileTransferStatusReceived,
	STFileTransferStatusReceiveFailed,
};

@interface STFileTransferInfo : NSObject

HT_AS_SINGLETON(STFileTransferInfo, shareInstant)

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) UIImage *headImage;
@property (nonatomic) STFileType fileType;
@property (nonatomic) STFileTransferType transferType;
@property (nonatomic) STFileTransferStatus transferStatus;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *vcardString;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *pathExtension;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic) double fileSize;
@property (nonatomic) double downloadSpeed;
@property (nonatomic) float progress; // 原图下载进度
@property (nonatomic) float thumbnailProgress; // 缩略图下载进度
@property (nonatomic) double lastProgressTimeStamp; // 用于计算瞬时速度
@property (nonatomic) double lastProgress; // 用于计算瞬时速度
@property (nonatomic) BOOL isCanceled; // 是否被取消传输
@property (nonatomic, strong) NSString *cancelUrl; // 取消发送

@property (nonatomic, strong) NSProgress *nsprogress; // 监听文件发送和接收进度

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *fileSizeString;
@property (nonatomic, strong) NSString *rateString;
@property (nonatomic) NSInteger tag;
@property (nonatomic) BOOL showDeviceInfo;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (instancetype)initWithReceiveFileInfo:(NSDictionary *)fileInfo deviceInfo:(STDeviceInfo *)deviceInfo;

@property(nonatomic,readonly)NSString *_tableName;
@property(nonatomic,readonly)NSString *_id;
@property(nonatomic,readonly)NSString *_identifier;
@property(nonatomic,readonly)NSString *_deviceName;
@property(nonatomic,readonly)NSString *_fileType;
@property(nonatomic,readonly)NSString *_transferType;
@property(nonatomic,readonly)NSString *_transferStatus;
@property(nonatomic,readonly)NSString *_url;
@property(nonatomic,readonly)NSString *_vcard;
@property(nonatomic,readonly)NSString *_fileName;
@property(nonatomic,readonly)NSString *_date;
@property(nonatomic,readonly)NSString *_fileSize;
@property(nonatomic,readonly)NSString *_downloadSpeed;

@end
