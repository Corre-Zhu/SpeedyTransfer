//
//  STFileReceiveModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"
#import "MCTransceiver.h"

@interface STFileReceiveModel : NSObject

HT_AS_SINGLETON(STFileReceiveModel, shareInstant)

@property (nonatomic, strong) NSArray *receiveFiles; // 接收的文件

/**
 保存到数据库
 */
- (STFileTransferInfo *)saveContactInfo:(NSData *)vcardData;
- (STFileTransferInfo *)savePicture:(NSString *)pictureName size:(double)size;

- (void)updateStatus:(STFileTransferStatus)status rate:(double)rate withIdentifier:(NSString *)identifier;
- (void)updateWithUrl:(NSString *)url identifier:(NSString *)identifier;

@end
