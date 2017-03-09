//
//  STFileTransferModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferInfo.h"
#import "STDeviceInfo.h"
#import "ZZFunction.h"

@interface STFileTransferInfo ()
{
    NSDateFormatter *formatter;
}

@end

@implementation STFileTransferInfo

HT_DEF_SINGLETON(STFileTransferInfo, shareInstant);

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.identifier = [dic stringForKey:DBFileTransfer._identifier];
        self.fileType = [dic integerForKey:DBFileTransfer._fileType];
        self.transferType = [dic integerForKey:DBFileTransfer._transferType];
        self.transferStatus = [dic integerForKey:DBFileTransfer._transferStatus];
        self.url = [dic stringForKey:DBFileTransfer._url];
        self.vcardString = [dic stringForKey:DBFileTransfer._vcard];
        self.fileName = [dic stringForKey:DBFileTransfer._fileName];
        self.fileSize = [dic doubleForKey:DBFileTransfer._fileSize];
        self.dateString = [dic stringForKey:DBFileTransfer._date];
        self.downloadSpeed = [dic doubleForKey:DBFileTransfer._downloadSpeed];
        
        if (self.transferStatus == STFileTransferStatusReceived ||
			self.transferStatus == STFileTransferStatusSent) {
            self.progress = 1.0f;
        }
		
        self.deviceName = [dic stringForKey:DBDeviceInfo._deviceName];
    }
    
    return self;
}

- (instancetype)initWithReceiveFileInfo:(NSDictionary *)fileInfo deviceInfo:(STDeviceInfo *)deviceInfo {
    self = [super init];
    if (self) {
        self.identifier = [fileInfo stringForKey:FILE_IDENTIFIER];
        self.transferType = STFileTransferTypeReceive;
        self.transferStatus = STFileTransferStatusReceiving;
        self.fileName = [fileInfo stringForKey:FILE_NAME];
        self.fileSize = [fileInfo doubleForKey:FILE_SIZE];
        if (self.fileName.pathExtension.length > 0) {
            self.pathExtension = self.fileName.pathExtension;
        } else {
            self.pathExtension = [fileInfo stringForKey:FILE_TYPE];
        }
        self.dateString = [[NSDate date] dateString];
        self.deviceName = deviceInfo.deviceName;
        self.headImage = deviceInfo.headImage;
        
        STFileType fileType = [ZZFunction fileTypeWithPathExtension:[fileInfo stringForKey:FILE_TYPE]];
        self.fileType = fileType;
    }
    
    return self;

    
}

-(NSString *)_tableName{return @"FileTransfer";}
-(NSString *)_id{return @"ID";}
-(NSString *)_identifier{return @"Identifier";}
-(NSString *)_deviceName{return @"DeviceName";}
-(NSString *)_fileType{return @"FileType";}
-(NSString *)_transferType{return @"TransferType";}
-(NSString *)_transferStatus{return @"TransferStatus";}
-(NSString *)_url{return @"Url";}
-(NSString *)_vcard{return @"Vcard";}
-(NSString *)_fileName{return @"FileName";}
-(NSString *)_fileSize{return @"FileSize";}
-(NSString *)_date{return @"FileDate";}
-(NSString *)_downloadSpeed{return @"DownloadSpeed";}

- (NSString *)fileSizeString {
    return [NSString formatSize:self.fileSize];
}

- (NSString *)rateString {
    return [NSString stringWithFormat:@"%@/s", [NSString formatSize:self.downloadSpeed]];
}

- (NSString *)cancelUrl {
    NSString *host = [[NSURL URLWithString:self.url] host];
    NSNumber *port = [[NSURL URLWithString:self.url] port];
    return [NSString stringWithFormat:@"http://%@:%@/cancel", host, port];
}

- (void)dealloc {
    if (_nsprogress) {
        [_nsprogress removeObserver:self forKeyPath:kProgressCancelledKeyPath];
        [_nsprogress removeObserver:self forKeyPath:kProgressCompletedUnitCountKeyPath];
        _nsprogress = nil;
    }
}

- (void)setNsprogress:(NSProgress *)nsprogress {
    if (_nsprogress) {
        return;
    }
    
    _nsprogress = nsprogress;
    [_nsprogress addObserver:self forKeyPath:kProgressCancelledKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    [_nsprogress addObserver:self forKeyPath:kProgressCompletedUnitCountKeyPath options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSProgress *progress = object;
    if ([keyPath isEqualToString:kProgressCompletedUnitCountKeyPath]) {
        // Notify the delegate of our progress change
        self.progress = progress.fractionCompleted;
        if (progress.completedUnitCount == progress.totalUnitCount) {
            self.progress = 1.0;
        }
    }
}

@end
