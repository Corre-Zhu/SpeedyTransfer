//
//  ZZNavigationController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/29.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "ZZNavigationController.h"

@interface ZZNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@end

@implementation ZZNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
    
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        return;
    }
    
    self.navigationBar.userInteractionEnabled = NO;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        return;
    }
    
    self.navigationBar.userInteractionEnabled = YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (!self.navigationBar.userInteractionEnabled) {
        return NO;
    }
    
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return self.viewControllers.count > 1 ? YES : NO;
    }
    
    if (self.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        return NO;
    }
    
    return YES;
}

@end
