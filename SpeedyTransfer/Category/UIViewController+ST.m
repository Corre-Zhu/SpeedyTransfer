//
//  UIViewController+ST.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/17.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "UIViewController+ST.h"

@implementation UIViewController (ST)

- (STFileSelectionViewController *)fileSelectionTabController {
    if ([self.parentViewController isKindOfClass:[STFileSelectionViewController class]]) {
        return (STFileSelectionViewController *)self.parentViewController;
    }
    
    for (UIViewController *viewC in self.navigationController.viewControllers) {
        if ([viewC isKindOfClass:[STFileSelectionViewController class]]) {
            return (STFileSelectionViewController *)viewC;
        }
    }
    
    return nil;
}

@end
