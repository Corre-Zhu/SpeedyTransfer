//
//  STFileCell.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/4/4.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STFileCell : UITableViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;

@property (nonatomic) BOOL checked;

@end
