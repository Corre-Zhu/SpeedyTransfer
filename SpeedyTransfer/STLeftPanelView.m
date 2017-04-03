//
//  STLeftPanelView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/12.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STLeftPanelView.h"
#import "STHomeViewController.h"

@interface STLeftPanelView () {
    UILabel *nameLabel;
    UIButton *editButton;
}

@end

@implementation STLeftPanelView

- (instancetype)init {
    CGFloat width = 300.0f * (IPHONE_WIDTH / 375);
    self = [super initWithFrame:CGRectMake(-width, 0.0f, width, IPHONE_HEIGHT)];
    if (self) {
        self.backgroundColor = RGBFromHex(0xfdfdfe);
        self.clipsToBounds = YES;
        
        UIImageView *backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_img_111"]];
        [self addSubview:backView];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0f, 70.0f, 80.0f, 80.0f)];
        _headImageView.layer.cornerRadius = 40.0f;
        _headImageView.layer.borderWidth = 1.5f;
        _headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        [self addSubview:_headImageView];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewTap)];
        [_headImageView addGestureRecognizer:tapGes];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:14.0f];
        nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:nameLabel];
        
        editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setImage:[UIImage imageNamed:@"ic_bianji"] forState:UIControlStateNormal];
        [self addSubview:editButton];
        [editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *images = @[@"ic_mywenjian", @"ic_yaoqing", @"ic_fankui", @"ic_banben"];
        NSArray *titles = @[@"我的文件", @"邀请安装", @"意见反馈", @"版本"];
        
        for (int i = 0; i < 4; i++) {
            UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, backView.bottom + 80.0f + i * 60.0f, IPHONE_WIDTH, 44.0f)];
            sendButton.backgroundColor = [UIColor clearColor];
            [sendButton addTarget:self action:@selector(actionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            sendButton.tag = i;
            [self addSubview:sendButton];
            
            UIImageView *sendIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:images[i]]];
            [sendButton addSubview:sendIcon];
            sendIcon.top = 22.0;
            sendIcon.left = 48.0f;
            
            UILabel *sendLabel = [[UILabel alloc] initWithFrame:CGRectMake(sendIcon.right + 12.0f, 23.0f, backView.width, 20.0f)];
            sendLabel.font = [UIFont systemFontOfSize:14.0f];
            sendLabel.textColor = RGBFromHex(0x333333);
            sendLabel.text = titles[i];
            [sendButton addSubview:sendLabel];
            
            if (i == 3) {
                UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 130.0f, 24.0f, 100.0f, 18.0f)];
                version.font = [UIFont systemFontOfSize:14.0f];
                version.textColor = RGBFromHex(0x333333);
                version.text = [[[NSBundle mainBundle] infoDictionary] stringForKey:@"CFBundleShortVersionString"];
                version.textAlignment = NSTextAlignmentRight;
                [sendButton addSubview:version];
            }
        }
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
    if (name.length == 0) {
        name = [[UIDevice currentDevice] name];
    }
    nameLabel.text = name;
    [nameLabel sizeToFit];
    nameLabel.left = 30.0f;
    nameLabel.top = _headImageView.bottom + 28.0f;
    nameLabel.width = MIN(nameLabel.width, 100.0f);
    
    editButton.frame = CGRectMake(nameLabel.right + 11.0f, nameLabel.top - 16.0f, 40.0f, 40.0f);
}

- (void)headImageViewTap {
    [(STHomeViewController *)self.parentViewController setHeadImageButtonClick];
}

- (void)editButtonClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"更改名称", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = [alertController.textFields firstObject].text;
        if (text.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"name"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    }];
    [alertController addAction:action1];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:NULL];
    [alertController addAction:action3];
    [self.parentViewController presentViewController:alertController animated:YES completion:NULL];
}

- (void)actionBtnClick:(UIButton *)button {
    if (button.tag == 0) {
        [(STHomeViewController *)self.parentViewController mineFilesButtonClick];
    } else if (button.tag == 1) {
        [(STHomeViewController *)self.parentViewController inviteFriendButtonClick];
    } else if (button.tag == 2) {
        [(STHomeViewController *)self.parentViewController feedbackButtonClick];
    }
}

@end
