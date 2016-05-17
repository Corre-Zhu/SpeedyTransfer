//
//  UIAlertController+HT.h
//  
//
//  Created by zhuzhi on 15/6/3.
//  Copyright © 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (HT)

+ (void)showMessage:(NSString *)message inViewController:(UIViewController *)controller;
+ (void)showTitle:(NSString *)title message:(NSString *)message inViewController:(UIViewController *)controller;

@end
