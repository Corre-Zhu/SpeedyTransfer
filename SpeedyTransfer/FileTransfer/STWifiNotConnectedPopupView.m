//
//  STWifiNotConnectedPopupView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/22.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STWifiNotConnectedPopupView.h"

@interface STWifiNotConnectedPopupView ()
{
    UIImageView *backView;
    UILabel *titleLabel;
    HTDrawView *whiteView;
}

@end

@implementation STWifiNotConnectedPopupView

- (instancetype)init {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGes];
        
        UIView *blackView = [[UIView alloc] init];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.layer.cornerRadius = 4.0f;
        blackView.frame = CGRectMake((IPHONE_WIDTH - 270.0f) / 2.0f + 2.0f, (IPHONE_HEIGHT - 273.0f) / 2.0f, 266.0f, 273.0f);
        [self addSubview:blackView];
        
        UIImage *backImage = [[UIImage imageNamed:@"xuanze_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0f, 7.0f, 7.0f, 7.0f)];
        backView = [[UIImageView alloc] initWithImage:backImage];
        backView.frame = CGRectMake((IPHONE_WIDTH - 270.0f) / 2.0f, (IPHONE_HEIGHT - 273.0f) / 2.0f - 1.0f, 270.0f, 275.0f);
        backView.userInteractionEnabled = YES;
        [self addSubview:backView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, backView.width, 37.0f)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = NSLocalizedString(@"当前无WI-FI连接", nil);
        [backView addSubview:titleLabel];
        
        whiteView = [[HTDrawView alloc] initWithFrame:CGRectMake(1.0f, 37.0f, backView.width - 3.0f, backView.height - 37.0f)];
        whiteView.backgroundColor = [UIColor whiteColor];
        whiteView.layer.masksToBounds = YES;
        [backView addSubview:whiteView];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:whiteView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4.0f, 4.0f)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = whiteView.bounds;
        maskLayer.path = maskPath.CGPath;
        whiteView.layer.mask = maskLayer;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 87.0f, whiteView.width - 16.0f, 0.5f)];
        lineView.backgroundColor = RGBFromHex(0xc8c7cc);
        [whiteView addSubview:lineView];
        
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 180.0f, whiteView.width - 16.0f, 0.5f)];
        lineView2.backgroundColor = RGBFromHex(0xc8c7cc);
        [whiteView addSubview:lineView2];
        
        whiteView.drawBlock = ^(void) {
            [NSLocalizedString(@"请按照以下步骤打开本机的个人热点", nil) drawAtPoint:CGPointMake(16.0f, 17.0f) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f], NSForegroundColorAttributeName: RGBFromHex(0x323232)}];
            [[UIImage imageNamed:@"number1"] drawAtPoint:CGPointMake(16.0f, 50.0f)];
            [NSLocalizedString(@"打开  系统设置", nil) drawAtPoint:CGPointMake(58.0f, 53.0f) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f], NSForegroundColorAttributeName: RGBFromHex(0x323232)}];
            
            [[UIImage imageNamed:@"number2"] drawAtPoint:CGPointMake(16.0f, 102.0f)];
            [NSLocalizedString(@"进入  移动蜂窝网络", nil) drawAtPoint:CGPointMake(58.0f, 105.0f) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f], NSForegroundColorAttributeName: RGBFromHex(0x323232)}];
            [NSLocalizedString(@"（1）开启蜂窝网络", nil) drawAtPoint:CGPointMake(86.0f, 132.0f) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName: RGBFromHex(0x323232)}];
            [NSLocalizedString(@"（2）打开“个人热点”", nil) drawAtPoint:CGPointMake(86.0f, 152.5f) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName: RGBFromHex(0x323232)}];
            
            [[UIImage imageNamed:@"number3"] drawAtPoint:CGPointMake(16.0f, 195.0f)];
            [NSLocalizedString(@"返回  点传 > 我要接收", nil) drawAtPoint:CGPointMake(58.0f, 198.0f) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f], NSForegroundColorAttributeName: RGBFromHex(0x323232)}];
        };
        
    }
    
    return self;
}

- (void)showInView:(UIView *)view {
    self.alpha = 0.0f;
    [view addSubview:self];
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if (!CGRectContainsPoint(backView.frame, point)) {
        [self removeFromSuperview];
    }
}

@end
