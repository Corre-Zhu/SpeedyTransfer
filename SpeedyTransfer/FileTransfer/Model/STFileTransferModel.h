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

@class STContactInfo;

@interface STFileTransferModel : NSObject

HT_AS_SINGLETON(STFileTransferModel, shareInstant);

@property (nonatomic, strong) NSArray *transferFiles; // 发送的文件

/**
 保存到数据库
 */
- (STFileTransferInfo *)setContactInfo:(STContactInfo *)object forKey:(NSString *)key;
- (STFileTransferInfo *)saveAssetWithIdentifier:(NSString *)identifier fileName:(NSString *)fileName length:(double)length forKey:(NSString *)key;

- (void)updateStatus:(STFileTransferStatus)status rate:(double)rate withIdentifier:(NSString *)identifier;

@end
