//
//  STConnectWifiAlertView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/3/19.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STConnectWifiAlertView.h"
#import "ZZFunction.h"

@interface STConnectWifiAlertView ()
{
    HTDrawView *whiteView;
    NSTimer *timer;
}

@property (nonatomic, copy) CompletionBlock block;

@end

@implementation STConnectWifiAlertView

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
        
        UILabel *label10 = [[UILabel alloc] initWithFrame:CGRectMake(16, label9.bottom + 12, whiteView.width - 32, 17)];
        label10.text = @"1.连接以下样式的WIFI";
        label10.textColor = RGBFromHex(0x333333);
        label10.font = [UIFont systemFontOfSize:14.0f];
        [whiteView addSubview:label10];
        
        UIView *borderView = [[HTDrawView alloc] initWithFrame:CGRectMake(16, label10.bottom + 5, whiteView.width - 32, 46)];
        borderView.backgroundColor = [UIColor whiteColor];
        borderView.layer.borderWidth = 2;
        borderView.layer.borderColor = RGBFromHex(0xff7428).CGColor;
        [whiteView addSubview:borderView];
        
        UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, borderView.width - 58, 17)];
        label11.text = @"FreeShare-********";
        label11.textColor = RGBFromHex(0x333333);
        label11.font = [UIFont systemFontOfSize:14.0f];
        label11.textAlignment = NSTextAlignmentLeft;
        [borderView addSubview:label11];
        
        UILabel *label111 = [[UILabel alloc] initWithFrame:CGRectMake(16, borderView.bottom + 12, whiteView.width - 32, 17)];
        label111.text = @"2.连接之后，返回 点传，稍等片刻即可传输";
        label111.textColor = RGBFromHex(0x333333);
        label111.font = [UIFont systemFontOfSize:14.0f];
        label111.numberOfLines = 0;
        [whiteView addSubview:label111];
        [label111 sizeToFit];
        label111.top = borderView.bottom + 12;
        label111.left = 16;
        
//        UILabel *label12 = [[UILabel alloc] initWithFrame:CGRectMake(12, label11.bottom + 5, borderView.width - 58, 15)];
//        label12.text = @"🚀 点传免费流量传输文件，点击这里一键连接";
//        label12.textColor = RGBFromHex(0x333333);
//        label12.font = [UIFont systemFontOfSize:12.0f];
//        [borderView addSubview:label12];
//        label12.numberOfLines = 0;
//        [label12 sizeToFit];
//        label12.left = 12;
//        label12.top = label11.bottom + 5;
//        borderView.height = label12.bottom + 4;
        
        UIImageView *imag2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_wifi"]];
        imag2.frame = CGRectMake(borderView.width - 34, 11, 22, 22);
        [borderView addSubview:imag2];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, label111.bottom + 16, whiteView.width, 0.5f)];
        lineView.backgroundColor = RGBFromHex(0xbdbdbd);
        [whiteView addSubview:lineView];

        
        UIButton *hotspotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [hotspotButton addTarget:self action:@selector(hotspotButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [whiteView addSubview:hotspotButton];

        hotspotButton.frame = CGRectMake(0, lineView.bottom, whiteView.width, 40);
        hotspotButton.layer.cornerRadius = 2;
        [hotspotButton setTitle:@"去连接指定WIFI" forState:UIControlStateNormal];
        [hotspotButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateNormal];
        hotspotButton.titleLabel.font = [UIFont systemFontOfSize:16];
        
        whiteView.height = hotspotButton.bottom;
        
       // timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hotspotButtonClick) userInfo:nil repeats:NO];
        
    }
    
    return self;
}

- (void)hotspotButtonClick {
    [timer invalidate];
    [ZZFunction goToWifiPref];
    if (_block) {
        _block();
    }
    
    // 1.创建一个本地通知
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    
    // 1.1.设置通知发出的时间
    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.6];
    
    // 1.2.设置通知内容
    localNote.alertBody = @"请连接带有FreeShare字样的Wi-Fi";
    
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

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [timer invalidate];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if (!CGRectContainsPoint(whiteView.frame, point)) {
        [self removeFromSuperview];
        [timer invalidate];
        
        if (_block) {
            _block();
        }
    }
}

@end
