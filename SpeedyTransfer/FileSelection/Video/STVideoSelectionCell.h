//
//  STVideoSelectionCell.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/11.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STVideoSelectionCell : UITableViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;

@property (nonatomic) BOOL checked;

@end
