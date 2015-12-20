//
//  STFileSelectionPopupView.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/20.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFileSelectionTabViewController;

@interface STFileSelectionPopupView : UIView

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, weak) STFileSelectionTabViewController *tabViewController;

- (void)showInView:(UIView *)view;

@end
