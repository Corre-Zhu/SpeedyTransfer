//
//  STFileReceiveModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFileReceiveInfo.h"
#import "HTSingleton.h"
#import "MCTransceiver.h"
#import "Reachability.h"

@interface STFileReceiveModel : NSObject

HT_AS_SINGLETON(STFileReceiveModel, shareInstant)

@property (nonatomic, strong) NSArray *receiveFiles; // 接收的文件
@property (strong, nonatomic) MCTransceiver *transceiver;
@property (nonatomic, strong) Reachability *reachability;


/**
 保存到数据库
 */
- (STFileReceiveInfo *)saveContactInfo:(NSData *)vcardData;
- (STFileReceiveInfo *)savePicture:(NSString *)pictureName size:(double)size;

- (void)updateStatus:(STFileReceiveStatus)status rate:(double)rate withIdentifier:(NSString *)identifier;
- (void)updateWithUrl:(NSString *)url identifier:(NSString *)identifier;

@end
