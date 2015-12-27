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

typedef NS_ENUM(NSInteger, STFileTransferType) {
    STFileTransferTypePicture        = 0,
    STFileTransferTypeMusic          = 1,
    STFileTransferTypeVideo          = 2,
    STFileTransferTypeContact        = 3,
};

typedef NS_ENUM(NSInteger, STFileTransferStatus) {
    STFileTransferStatusSending      = 0,
    STFileTransferStatusFailed       = 1,
    STFileTransferStatusSucceed      = 2,
};

@interface STFileTransferInfo : NSObject

HT_AS_SINGLETON(STFileTransferInfo, shareInstant)

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic) STFileTransferType type;
@property (nonatomic) NSInteger status;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *vcardString;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic) double fileSize;
@property (nonatomic) double sizePerSecond;
@property (nonatomic) float progress;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *fileSizeString;
@property (nonatomic, strong) NSString *rateString;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@property(nonatomic,readonly)NSString *_tableName;
@property(nonatomic,readonly)NSString *_id;
@property(nonatomic,readonly)NSString *_identifier;
@property(nonatomic,readonly)NSString *_type;
@property(nonatomic,readonly)NSString *_status;
@property(nonatomic,readonly)NSString *_url;
@property(nonatomic,readonly)NSString *_vcard;
@property(nonatomic,readonly)NSString *_fileName;
@property(nonatomic,readonly)NSString *_date;
@property(nonatomic,readonly)NSString *_fileSize;
@property(nonatomic,readonly)NSString *_sizePerSencond;

@end
