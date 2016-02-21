//
//  STDeviceButton.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/20.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STDeviceInfo;

@interface STDeviceButton : UIView

@property (nonatomic, strong) STDeviceInfo *deviceInfo;

- (BOOL)isSelected;

@end
