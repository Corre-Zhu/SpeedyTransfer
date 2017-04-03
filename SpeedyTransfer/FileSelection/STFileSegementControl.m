//
//  STFileSegementControl.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/12.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STFileSegementControl.h"

@interface STFileSegementControl () {
    UILabel *titleLabel;
    NSMutableArray *buttons;
    UIButton *lastSelectedButton;
    UIView *botttomLine;
}

@end

@implementation STFileSegementControl

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 109.0f)];
    if (self) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"ic_arrow-left"] forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, 20, 40, 44);
        [self addSubview:backButton];
        [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 32.0f, IPHONE_WIDTH - 160, 20.0f)];
        titleLabel.font = [UIFont systemFontOfSize:19.0f];
        titleLabel.textColor = RGBFromHex(0x333333);
        titleLabel.text = @"选择图片";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        NSArray *imagesOn = @[@"ic_tupian_on", @"ic_video_on", @"ic_tongxunlu_on", @"ic_wenjian_on"];
        NSArray *imagesOff = @[@"ic_tupian_off", @"ic_video_off", @"ic_tongxunlu_off", @"ic_wenjian_off"];
        NSArray *titles = @[@"图片", @"视频", @"通讯录", @"文件"];
        
        buttons = [NSMutableArray arrayWithCapacity:4];
        CGFloat width = IPHONE_WIDTH / 4.0f;
        for (int i = 0; i < 4; i++) {
            UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(i * width, 64.0f, width, 44.0f)];
            sendButton.backgroundColor = [UIColor clearColor];
            [sendButton addTarget:self action:@selector(didSelectIndex:) forControlEvents:UIControlEventTouchUpInside];
            sendButton.tag = i;
            [sendButton setTitle:titles[i] forState:UIControlStateNormal];
            [sendButton setTitleColor:RGBFromHex(0x333333) forState:UIControlStateNormal];
            [sendButton setTitleColor:RGBFromHex(0x333333) forState:UIControlStateHighlighted];

            [sendButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateSelected];
            [sendButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateSelected | UIControlStateHighlighted];
            sendButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [sendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];

            [sendButton setImage:[UIImage imageNamed:imagesOff[i]] forState:UIControlStateNormal];
            [sendButton setImage:[UIImage imageNamed:imagesOff[i]] forState:UIControlStateHighlighted];
            [sendButton setImage:[UIImage imageNamed:imagesOn[i]] forState:UIControlStateSelected];
            [sendButton setImage:[UIImage imageNamed:imagesOn[i]] forState:UIControlStateSelected | UIControlStateHighlighted];
            sendButton.showsTouchWhenHighlighted = NO;
            [self addSubview:sendButton];
            
            [buttons addObject:sendButton];
            
        }
        
        botttomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 106, width, 2)];
        botttomLine.backgroundColor = RGBFromHex(0x01cc99);
        [self addSubview:botttomLine];
        
        UIView *sepratorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 108, IPHONE_WIDTH, 0.5)];
        sepratorLine.backgroundColor = RGBFromHex(0xcacaca);
        [self addSubview:sepratorLine];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    titleLabel.text = title;
}

- (void)backButtonClick {
    [self.delegate didTapBack];
}

- (void)setSelectedIndex:(NSInteger)index {
    [self didSelectIndex:buttons[index]];
}

- (void)didSelectIndex:(UIButton *)sender {
    if (sender == lastSelectedButton) {
        return;
    }
    [UIView animateWithDuration:0.15 animations:^{
        botttomLine.left = sender.left;
    }];
    lastSelectedButton.selected = NO;
    sender.selected = YES;
    lastSelectedButton = sender;
    
    [self.delegate didSelectIndex:sender.tag];
}

@end
