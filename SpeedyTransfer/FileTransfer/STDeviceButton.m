//
//  STDeviceButton.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/20.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STDeviceButton.h"
#import "STDeviceInfo.h"

@interface STDeviceButton ()
{
    UIButton *button;
    UILabel *label;
}

@end

@implementation STDeviceButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0f, 0.0f, 42.0f, 42.0f);
        button.layer.cornerRadius = 21.0f;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor clearColor];
        [button setImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateSelected];
        button.adjustsImageWhenHighlighted = NO;
        [button addTarget:self action:@selector(deviceButtonClick) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:button];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - 100.0f) / 2.0f, button.bottom + 3.0f, 100.0f, 16.0f)];
        label.text = NSLocalizedString(@"点击选择用户发送文件", nil);
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
    }
    
    return self;
}

- (void)deviceButtonClick {
    button.selected = !button.selected;
}

- (void)setDeviceInfo:(STDeviceInfo *)deviceInfo {
    _deviceInfo = deviceInfo;
    label.text = deviceInfo.deviceName;
    [button setImage:deviceInfo.headImage forState:UIControlStateNormal];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden) {
        label.text = nil;
        button.selected = NO;
        [button setImage:nil forState:UIControlStateNormal];
    }
}

- (BOOL)isSelected {
    return button.selected;
}

@end
