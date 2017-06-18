//
//  STTurnOffHotspotPopupView.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/6/18.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(void);

@interface STTurnOffHotspotPopupView : UIView

- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view hiddenBlock:(CompletionBlock)block;

@end
