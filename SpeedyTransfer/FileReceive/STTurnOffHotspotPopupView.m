//
//  STTurnOffHotspotPopupView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/6/18.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STTurnOffHotspotPopupView.h"
#import "ZZFunction.h"

@interface STTurnOffHotspotPopupView ()
{
    HTDrawView *whiteView;
}

@property (nonatomic, copy) CompletionBlock block;

@end

@implementation STTurnOffHotspotPopupView

- (instancetype)init {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGes];
        
        whiteView = [[HTDrawView alloc] initWithFrame:CGRectMake(44, 180, IPHONE_WIDTH - 88, 208)];
        whiteView.backgroundColor = [UIColor whiteColor];
        whiteView.layer.masksToBounds = YES;
        whiteView.layer.cornerRadius = 5;
        [self addSubview:whiteView];
        
        UILabel *label9 = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, whiteView.width, 17)];
        label9.text = @"请按以下步骤关闭个人热点";
        label9.font = [UIFont systemFontOfSize:15.0f];
        label9.textAlignment = NSTextAlignmentCenter;
        [whiteView addSubview:label9];

        UIImageView *imag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"number1"]];
        imag.frame = CGRectMake(16, label9.bottom + 16, 22, 22);
        [whiteView addSubview:imag];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imag.right + 16, label9.bottom + 18, whiteView.width - 60, 0)];
        label.text = @"进入 移动蜂窝数据";
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor grayColor];
        [whiteView addSubview:label];
        [label sizeToFit];
        label.left = imag.right + 16;
        label.top = label9.bottom + 18;
        
        UIImageView *imag2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"number2"]];
        imag2.frame = CGRectMake(16, label.bottom + 25, 22, 22);
        [whiteView addSubview:imag2];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(imag2.right + 16, label.bottom + 27, whiteView.width - 60, 0)];
        label2.text = @"个人热点 > 关闭 “个人热点”";
        label2.textColor = [UIColor grayColor];
        label2.font = [UIFont systemFontOfSize:14.0f];
        label2.numberOfLines = 0;
        [whiteView addSubview:label2];
        [label2 sizeToFit];
        label2.left = imag2.right + 16;
        label2.top = label.bottom + 32;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, label2.bottom + 20, whiteView.width, 0.5f)];
        lineView.backgroundColor = RGBFromHex(0xbdbdbd);
        [whiteView addSubview:lineView];
        
        UIButton *hotspotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [hotspotButton addTarget:self action:@selector(hotspotButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [whiteView addSubview:hotspotButton];
        hotspotButton.frame = CGRectMake(0, lineView.bottom, whiteView.width, 40);
        hotspotButton.layer.cornerRadius = 2;
        [hotspotButton setTitle:@"去关闭个人热点" forState:UIControlStateNormal];
        [hotspotButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateNormal];
        hotspotButton.titleLabel.font = [UIFont systemFontOfSize:16];
        
        whiteView.height = hotspotButton.bottom;
        whiteView.top = (IPHONE_HEIGHT - whiteView.height) / 2.0;
        
    }
    
    return self;
}

- (void)hotspotButtonClick {
    [ZZFunction goToHotspotPref];
    
    [self removeFromSuperview];
    if (_block) {
        _block();
    }
}

- (void)showInView:(UIView *)view {
    self.alpha = 0.0f;
    [view addSubview:self];
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showInView:(UIView *)view hiddenBlock:(void (^)(void))block {
    self.block = block;
    [self showInView:view];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if (!CGRectContainsPoint(whiteView.frame, point)) {
        [self removeFromSuperview];
        
        if (_block) {
            _block();
        }
    }
}

@end
