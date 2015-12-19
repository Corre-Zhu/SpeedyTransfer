//
//  STMusicSelectionCell.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/16.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMusicSelectionCell : UITableViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;

@property (nonatomic) BOOL checked;

@end
