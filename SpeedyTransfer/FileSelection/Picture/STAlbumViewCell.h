//
//  STAlbumViewCell.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHFetchResult;
@class STFileSelectionTabViewController;

@interface STAlbumViewCell : UITableViewCell

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) STFileSelectionTabViewController *tabViewController;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *placeholdImage;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic) BOOL expand; // 是否展开
@property (nonatomic) BOOL isCameraRoll; // 是否是相机胶卷

- (CGFloat)cellHeight;

@end
