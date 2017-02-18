//
//  ViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/11/28.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STHomeViewController.h"
#import "STPictureCollectionViewController.h"
#import "STVideoSelectionViewController.h"
#import "STContactsSelectionViewController.h"
#import "STFileTransferViewController.h"
#import "STSettingViewController.h"
#import "STInviteFriendViewController.h"
#import "STFindViewController.h"
#import "STFeedBackViewController.h"
#import "STPersonalSettingViewController.h"
#import "STWebServerModel.h"
#import <SVWebViewController.h>
#import "ZZReachability.h"
#import "STLeftPanelView.h"
#import "STFileSelectionViewController.h"

@interface STHomeViewController ()
{
    UIImageView *headImageView;
    UIButton *wifiButton;
    UIImageView *wifiPromptView;
    STLeftPanelView *leftView;
    UIView *maskView;
}
@end

@implementation STHomeViewController

- (void)addButtonWithImage:(NSString *)name
                     title:(NSString *)title
                     frame:(CGRect)frame
                  selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = frame;
    [button setTitleColor:RGBFromHex(0x333333) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button setNeedsLayout];
    [button layoutIfNeeded];
    [button centerImageAndTitle:10.0f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 392.0f)];
    backView.backgroundColor = [UIColor whiteColor];//RGB(233, 105, 79)
    [self.view addSubview:backView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_img000"]];
    imageView.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 392.0f);
    [backView addSubview:imageView];
    
    UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, 23.0f, 100.0f, 80.0f)];
    customView.backgroundColor = [UIColor clearColor];
    [customView addTarget:self action:@selector(personalSettingClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customView];
    
    UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_overflow_light"]];
    dotImageView.top = 12.0f;
    [customView addSubview:dotImageView];
    
    headImageView = [[UIImageView alloc] init];
    headImageView.left = 10.0f;
    headImageView.top = 0.0f;
    headImageView.width = 40.0f;
    headImageView.height = 40.0f;
    headImageView.layer.cornerRadius = 20.0f;
    headImageView.contentMode = UIViewContentModeScaleAspectFill;
    headImageView.layer.masksToBounds = YES;
    headImageView.clipsToBounds = YES;
    [customView addSubview:headImageView];
    
    wifiButton = [[UIButton alloc] initWithFrame:CGRectMake(IPHONE_WIDTH - 49.0f, 20.0f, 44, 44)];
    wifiButton.backgroundColor = [UIColor clearColor];
    [wifiButton addTarget:self action:@selector(wifiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wifiButton];
    if ([ZZReachability shareInstance].currentReachabilityStatus != ReachableViaWiFi) {
        [wifiButton setImage:[UIImage imageNamed:@"img_wifi"] forState:UIControlStateNormal];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wifiPrompt"]) {
            wifiPromptView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dianjikaiqi"]];
            [self.view addSubview:wifiPromptView];
            wifiPromptView.top = wifiButton.bottom - 3.0f;
            wifiPromptView.left = IPHONE_WIDTH - wifiPromptView.width - 18.0f;
            
            UILabel *wifiPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 13.0f, wifiPromptView.width, 15.0f)];
            wifiPromptLabel.textAlignment = NSTextAlignmentCenter;
            wifiPromptLabel.font = [UIFont systemFontOfSize:12.0f];
            wifiPromptLabel.textColor = RGBFromHex(0x333333);
            wifiPromptLabel.text = NSLocalizedString(@"点击开启Wi-Fi", nil);
            [wifiPromptView addSubview:wifiPromptLabel];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifiPrompt"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else {
        [wifiButton setImage:[UIImage imageNamed:@"ic_wifi_on"] forState:UIControlStateNormal];
    }
    
    UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(wifiButton.left - 46.0f, 20.0f, 44, 44)];
    inviteButton.backgroundColor = [UIColor clearColor];
    [inviteButton setImage:[UIImage imageNamed:@"ic_yaoqing_white"] forState:UIControlStateNormal];
    [inviteButton addTarget:self action:@selector(inviteFriendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inviteButton];
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, backView.height - 70.0f, backView.width, 20.0f)];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont systemFontOfSize:16.0f];
    promptLabel.textColor = [UIColor whiteColor];
    promptLabel.text = NSLocalizedString(@"面对面极速互传", nil);
    [backView addSubview:promptLabel];
    
    NSArray *images = @[@"ic_fsend", @"ic_freceive", @"ic_faxian"];
    NSArray *titles = @[@"我要发送", @"我要接收", @"发现"];

    for (int i = 0; i < 3; i++) {
        UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, backView.bottom + i * 80.0f, IPHONE_WIDTH, 80.0f)];
        sendButton.backgroundColor = [UIColor clearColor];
        [sendButton addTarget:self action:@selector(actionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        sendButton.tag = i;
        [self.view addSubview:sendButton];
        
        UIImageView *sendIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:images[i]]];
        [sendButton addSubview:sendIcon];
        sendIcon.top = 16.0;
        sendIcon.left = 20.0f;
        
        UILabel *sendLabel = [[UILabel alloc] initWithFrame:CGRectMake(sendIcon.right + 20.0f, 30.0f, backView.width, 20.0f)];
        sendLabel.font = [UIFont systemFontOfSize:16.0f];
        sendLabel.textColor = RGBFromHex(0x333333);
        sendLabel.text = titles[i];
        [sendButton addSubview:sendLabel];

        if (i < 2) {
            UIImageView *seprate = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, sendButton.height - 0.5f, IPHONE_WIDTH, 0.5f)];
            seprate.backgroundColor = RGBFromHex(0xcacaca);
            [sendButton addSubview:seprate];
        }
    }
    
    maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.hidden = YES;
    [self.view addSubview:maskView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTap)];
    [maskView addGestureRecognizer:tapGes];
    
    leftView = [[STLeftPanelView alloc] init];
    leftView.hidden = YES;
    leftView.parentViewController = self;
    [self.view addSubview:leftView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:kHTReachabilityChangedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFileNotification) name:KReceiveFileNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *headImage = [[NSUserDefaults standardUserDefaults] stringForKey:HeadImage];
    if ([headImage isEqualToString:CustomHeadImage]) {
        headImageView.image = [[UIImage alloc] initWithContentsOfFile:[[ZZPath documentPath] stringByAppendingPathComponent:CustomHeadImage]];
    } else {
        headImageView.image = [UIImage imageNamed:headImage];
    }
    leftView.headImageView.image = headImageView.image;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:NSClassFromString(@"STFileSelectionViewController")]) {
        return;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reachabilityStatusChange:(NSNotification *)notification {
    NetworkStatus status = [ZZReachability shareInstance].currentReachabilityStatus;
    switch (status) {
        case ReachableViaWiFi: {
            [wifiButton setImage:[UIImage imageNamed:@"ic_wifi_on"] forState:UIControlStateNormal];
            [wifiPromptView removeFromSuperview];
        }
            break;
            
        default:
            return;
    }
}

- (void)maskViewTap {
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        leftView.left = -leftView.width;
        maskView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        leftView.hidden = YES;
        maskView.hidden = YES;
    }];
}

- (void)personalSettingClick {
    leftView.hidden = NO;
    leftView.left = -leftView.width;
    maskView.backgroundColor = [UIColor clearColor];
    maskView.hidden = NO;
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        leftView.left = 0.0f;
        maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setHeadImageButtonClick {
    STPersonalSettingViewController *personalSettingVc = [[STPersonalSettingViewController alloc] init];
    [self.navigationController pushViewController:personalSettingVc animated:YES];
}

- (void)wifiButtonClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
}

- (void)actionBtnClick:(UIButton *)button {
    if (button.tag == 0) {
        [self transferButtonClick];
    } else if (button.tag == 1) {
        [self receiveButtonClick];
    } else if (button.tag == 2) {
        [self discoverButtonClick];
    }
}

- (void)transferButtonClick {
    STFileSelectionViewController *vc = [[STFileSelectionViewController alloc] init];
    if (self.navigationController.topViewController != self) {
        [self.navigationController setViewControllers:@[self, vc] animated:YES];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    /*
    STFileSelectionTabViewController *fileSelectionVc = [[STFileSelectionTabViewController alloc] init];
    
    STPictureCollectionViewController *picVC = [[STPictureCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];

    STMusicSelectionViewController *musicVC = [[STMusicSelectionViewController alloc] init];
    STVideoSelectionViewController *videoVC = [[STVideoSelectionViewController alloc] init];
    STContactsSelectionViewController *contactVC = [[STContactsSelectionViewController alloc] init];
    
    [picVC.tabBarItem setTitle:NSLocalizedString(@"图片", nil)];
    [picVC.tabBarItem setImage:[UIImage imageNamed:@"picture_line"]];
    [picVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"picture_block"]];
    
    [musicVC.tabBarItem setTitle:NSLocalizedString(@"音乐", nil)];
    [musicVC.tabBarItem setImage:[UIImage imageNamed:@"music_line"]];
    [musicVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"music_block"]];
    
    [videoVC.tabBarItem setTitle:NSLocalizedString(@"视频", nil)];
    [videoVC.tabBarItem setImage:[UIImage imageNamed:@"video_line"]];
    [videoVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"video_block"]];
    
    [contactVC.tabBarItem setTitle:NSLocalizedString(@"联系人", nil)];
    [contactVC.tabBarItem setImage:[UIImage imageNamed:@"contact_line"]];
    [contactVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"contact_block"]];
    
    fileSelectionVc.viewControllers = @[picVC,musicVC,videoVC,contactVC];
    */

}

- (void)receiveButtonClick {
    STFileTransferViewController *fileTransferVc = [[STFileTransferViewController alloc] init];
    fileTransferVc.isFromReceive = YES;
    [self.navigationController pushViewController:fileTransferVc animated:YES];
}

- (void)receiveFileNotification {
    // 当开始接收到文件并且在主界面时跳转至接收界面
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.navigationController.topViewController == self) {
            [self receiveButtonClick];
        }
    });
}

- (void)inviteFriendButtonClick {
    STInviteFriendViewController *inviteVc = [[STInviteFriendViewController alloc] init];
    [self.navigationController pushViewController:inviteVc animated:YES];
}

- (void)discoverButtonClick {
	NSString *urlString = [NSString stringWithFormat:@"http://www.3tkj.cn/jurl/j.php?id=%@", [[UIDevice currentDevice] openUDID]];
	NSURL *url = [NSURL URLWithString:urlString];
	self.navigationController.view.backgroundColor = [UIColor whiteColor];
	SVWebViewController *webVC = [[SVWebViewController alloc] initWithURL:url];
	[self.navigationController pushViewController:webVC animated:YES];
	
//    STFindViewController *findViewc = [[STFindViewController alloc] init];
//    [self.navigationController pushViewController:findViewc animated:YES];
}

- (void)settingButtonClick {
    STSettingViewController *settingVc = [[STSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVc animated:YES];
}

- (void)feedbackButtonClick {
    STFeedBackViewController *feedBackVc = [[STFeedBackViewController alloc] init];
    [self.navigationController pushViewController:feedBackVc animated:YES];
}

- (void)mineFilesButtonClick {
    
}

@end
