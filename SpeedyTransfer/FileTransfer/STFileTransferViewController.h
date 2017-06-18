//
//  STFileTransferViewController.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STFileTransferViewController : UIViewController

@property (nonatomic) BOOL isFromReceive; // 是否是点击我要接收进入的
@property (nonatomic) BOOL isMultipeerTransfer;
@property (nonatomic) BOOL isBrowser; // 是否是无界传输进入的

@end
