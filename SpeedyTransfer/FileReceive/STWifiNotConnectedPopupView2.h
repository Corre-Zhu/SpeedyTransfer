//
//  STWifiNotConnectedPopupView2.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(void);

@interface STWifiNotConnectedPopupView2 : UIView

- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view hiddenBlock:(CompletionBlock)block;

@end
