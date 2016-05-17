//
//  UIAlertController+HT.m
//  
//
//  Created by zhuzhi on 15/6/3.
//  Copyright © 2015年 HT. All rights reserved.
//

#import "UIAlertController+HT.h"

@implementation UIAlertController (HT)

+ (void)showMessage:(NSString *)message inViewController:(UIViewController *)controller {
	UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL];
	[alertView addAction:action];
	[controller presentViewController:alertView animated:YES completion:NULL];
}

+ (void)showTitle:(NSString *)title message:(NSString *)message inViewController:(UIViewController *)controller {
	UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL];
	[alertView addAction:action];
	[controller presentViewController:alertView animated:YES completion:NULL];
}

@end
