//
//  STFileReceiveInfo.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferInfo.h"
#import "HTSingleton.h"

#define DBFileReceive [STFileReceiveInfo shareInstant]

typedef NS_ENUM(NSInteger, STFileReceiveStatus) {
    STFileReceiveStatusReceiving       = 0,
    STFileReceiveStatusReceiveFailed   = 1,
    STFileReceiveStatusReceived        = 2,
};

@interface STFileReceiveInfo : STFileTransferInfo

HT_AS_SINGLETON(STFileReceiveInfo, shareInstant)

@end
