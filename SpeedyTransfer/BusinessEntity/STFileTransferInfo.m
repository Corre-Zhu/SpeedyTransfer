//
//  STFileTransferModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferInfo.h"
#import "STDeviceInfo.h"

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
        
        self.deviceId = [dic stringForKey:DBDeviceInfo._deviceId];
        self.deviceName = [dic stringForKey:DBDeviceInfo._deviceName];
    }
    
    return self;
}

-(NSString *)_tableName{return @"FileTransfer";}
-(NSString *)_id{return @"ID";}
-(NSString *)_identifier{return @"Identifier";}
-(NSString *)_deviceId{return @"DeviceId";}
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

@end
