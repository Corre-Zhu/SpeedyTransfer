//
//  STPersonalSettingCell.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STPersonalSettingCell.h"

@interface STPersonalSettingCell ()
{
    UIImageView *imageView;
    UILabel *titleLabel;
}

@end
@implementation STPersonalSettingCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.width, 60.0f)];
        imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:imageView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, imageView.bottom + 8.0f, self.width, 17.0f)];
        titleLabel.textColor = RGBFromHex(0x333333);
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image {
    imageView.image = image;
}

- (void)setTitle:(NSString *)title {
    titleLabel.text = title;
}

@end
