//
//  STFeedbackCell.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STFeedbackCell : UITableViewCell

@property (nonatomic, strong) STFeedbackInfo *info;

- (void)configCell;

@end
