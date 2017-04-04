//
//  STWifiNotConnectedPopupView2.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STWifiNotConnectedPopupView2.h"
#import "ZZFunction.h"

@interface STWifiNotConnectedPopupView2 ()
{
    HTDrawView *whiteView;
}

@property (nonatomic, copy) CompletionBlock block;

@end

@implementation STWifiNotConnectedPopupView2

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
        
        UIImageView *imag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_wifi"]];
        imag.frame = CGRectMake((whiteView.width - 32) / 2.0, 28, 32, 32);
        [whiteView addSubview:imag];
        
        UILabel *label9 = [[UILabel alloc] initWithFrame:CGRectMake(0, imag.bottom + 12, whiteView.width, 17)];
        label9.text = @"请按提示连接";
        label9.textColor = RGBFromHex(0xff6600);
        label9.font = [UIFont systemFontOfSize:14.0f];
        label9.textAlignment = NSTextAlignmentCenter;
        [whiteView addSubview:label9];
        
        NSMutableAttributedString *df = [[NSMutableAttributedString alloc] initWithString:@"1.请双方打开WiFi即可"];
        [df addAttribute:NSForegroundColorAttributeName value:RGBFromHex(0x333333) range:NSMakeRange(0, df.string.length)];
        [df addAttribute:NSForegroundColorAttributeName value:RGBFromHex(0xff3333) range:NSMakeRange(7, 4)];
        [df addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, df.string.length)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, label9.bottom + 12, whiteView.width - 60, 0)];
        label.attributedText = df;
        label.numberOfLines = 0;
        [whiteView addSubview:label];
        [label sizeToFit];
        label.left = 30;
        label.top = label9.bottom + 12;
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(30, imag.bottom + 12, whiteView.width - 60, 0)];
        label2.text = @"2.返回点传，再次扫码即可接收文件";
        label2.textColor = RGBFromHex(0x333333);
        label2.font = [UIFont systemFontOfSize:14.0f];
        label2.numberOfLines = 0;
        [whiteView addSubview:label2];
        [label2 sizeToFit];
        label2.left = 30;
        label2.top = label.bottom + 12;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, label2.bottom + 28, whiteView.width, 0.5f)];
        lineView.backgroundColor = RGBFromHex(0xbdbdbd);
        [whiteView addSubview:lineView];
        
        UIButton *hotspotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [hotspotButton addTarget:self action:@selector(hotspotButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [whiteView addSubview:hotspotButton];
        hotspotButton.frame = CGRectMake(0, lineView.bottom, whiteView.width, 40);
        hotspotButton.layer.cornerRadius = 2;
        [hotspotButton setTitle:@"去打开WIFI" forState:UIControlStateNormal];
        [hotspotButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateNormal];
        hotspotButton.titleLabel.font = [UIFont systemFontOfSize:16];
        
        whiteView.height = hotspotButton.bottom;
        
    }
    
    return self;
}

- (void)hotspotButtonClick {
    [ZZFunction goToWifiPref];
    _block();
    
    // 1.创建一个本地通知
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    
    // 1.1.设置通知发出的时间
    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.6];
    
    // 1.2.设置通知内容
    localNote.alertBody = @"双方只需要把Wi-Fi打开即可，是否已连接Wi-Fi没有关系";
    
    // 2.执行通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
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
        
        _block();
    }
}

@end
