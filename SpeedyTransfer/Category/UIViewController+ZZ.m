//
//  UIViewController+ZZ.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/4/3.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "UIViewController+ZZ.h"

@implementation UIViewController (ZZ)

- (void)setContentInset:(NSValue *)value {
    UIEdgeInsets inset = value.UIEdgeInsetsValue;
    if ([self isKindOfClass:[UITableViewController class]]) {
        UITableViewController *tb = (UITableViewController *)self;
        tb.tableView.contentInset = inset;
        tb.tableView.scrollIndicatorInsets = inset;
    } else if ([self isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController *tb = (UICollectionViewController *)self;
        tb.collectionView.contentInset = inset;
        tb.collectionView.scrollIndicatorInsets = inset;
    }
}

@end
