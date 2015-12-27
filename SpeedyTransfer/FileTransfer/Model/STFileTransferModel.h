//
//  STFileTransferModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFileTransferInfo.h"

@class STContactInfo;

@interface STFileTransferModel : NSObject

@property (nonatomic, strong) NSArray *transferFiles; // 发送的文件

/**
 保存到数据库
 */
- (STFileTransferInfo *)setContactInfo:(STContactInfo *)object forKey:(NSString *)key;
- (void)updateStatus:(STFileTransferStatus)status rate:(double)rate withIdentifier:(NSString *)identifier;

@end
