//
//  STFileTransferModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferInfo.h"

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
        self.type = [dic integerForKey:DBFileTransfer._type];
        self.status = [dic integerForKey:DBFileTransfer._status];
        self.url = [dic stringForKey:DBFileTransfer._url];
        self.vcardString = [dic stringForKey:DBFileTransfer._vcard];
        self.fileName = [dic stringForKey:DBFileTransfer._fileName];
        self.fileSize = [dic doubleForKey:DBFileTransfer._fileSize];
        self.dateString = [dic stringForKey:DBFileTransfer._date];
        self.sizePerSecond = [dic doubleForKey:DBFileTransfer._sizePerSencond];
        
        if (self.status == STFileTransferStatusSucceed) {
            self.progress = 1.0f;
        }
    }
    
    return self;
}

-(NSString *)_tableName{return @"FileTransfer";}
-(NSString *)_id{return @"ID";}
-(NSString *)_identifier{return @"FileID";}
-(NSString *)_type{return @"Type";}
-(NSString *)_status{return @"Status";}
-(NSString *)_url{return @"Url";}
-(NSString *)_vcard{return @"Vcard";}
-(NSString *)_fileName{return @"FileName";}
-(NSString *)_fileSize{return @"FileSize";}
-(NSString *)_date{return @"FileDate";}
-(NSString *)_sizePerSencond{return @"SizePerSecond";}

- (NSString *)fileSizeString {
    return [NSString formatSize:self.fileSize];
}

- (NSString *)rateString {
    return [NSString stringWithFormat:@"%@/s", [NSString formatSize:self.sizePerSecond]];
}

@end
