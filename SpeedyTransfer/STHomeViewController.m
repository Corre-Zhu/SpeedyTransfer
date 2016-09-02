//
//  ViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/11/28.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STHomeViewController.h"
#import "STFileSelectionTabViewController.h"
#import "STPictureCollectionViewController.h"
#import "STMusicSelectionViewController.h"
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

@interface STHomeViewController ()
{
    UIImageView *headImageView;
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
    [button setTitleColor:RGBFromHex(0x323232) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button setNeedsLayout];
    [button layoutIfNeeded];
    [button centerImageAndTitle:10.0f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"点传", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 36.0f)];
    customView.backgroundColor = [UIColor clearColor];
    [customView addTarget:self action:@selector(personalSettingClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_overflow_light"]];
    dotImageView.top = 10.0f;
    [customView addSubview:dotImageView];
    
    headImageView = [[UIImageView alloc] init];
    headImageView.left = 9.0f;
    headImageView.top = 4.0f;
    headImageView.width = 28.0f;
    headImageView.height = 28.0f;
    headImageView.layer.cornerRadius = 14.0f;
    headImageView.layer.borderWidth = 1.5f;
    headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    headImageView.contentMode = UIViewContentModeScaleAspectFill;
    headImageView.layer.masksToBounds = YES;
    headImageView.clipsToBounds = YES;
    [customView addSubview:headImageView];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 240.0f)];
    backView.backgroundColor = RGBFromHex(0xeb694a);//RGB(233, 105, 79)
    [self.view addSubview:backView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dc_bg"]];
    imageView.frame = CGRectMake(0.0f, 160.0f, IPHONE_WIDTH, 80.0f);
    [backView addSubview:imageView];
    
    UIImage *image = [[UIImage imageNamed:@"webshare_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 13, 9, 13)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(16.0f, 40.0f, IPHONE_WIDTH - 30.0f, 80.0f);
    [button addTarget:self action:@selector(transferButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:button];
    
    UILabel *descLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 18.0f, 200.0f, 21.0f)];
    descLabel1.text = NSLocalizedString(@"无界发送", nil);
    descLabel1.textColor = [UIColor whiteColor];
    descLabel1.font = [UIFont systemFontOfSize:18.0f];
    [button addSubview:descLabel1];
    
    UILabel *descLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 43.0f, 200.0f, 15.0f)];
    descLabel2.text = NSLocalizedString(@"好友无需安装点传，零流量互传文件", nil);
    descLabel2.textColor = [UIColor whiteColor];
    descLabel2.font = [UIFont systemFontOfSize:12.0f];
    [button addSubview:descLabel2];
    
    UIImageView *transferImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transfer"]];
    transferImageView.frame = CGRectMake(button.width - 80.0f, 7.5f, 63.0f, 63.0f);
    [button addSubview:transferImageView];
    
    [self addButtonWithImage:@"home3" title:NSLocalizedString(@"我要接收", nil) frame:CGRectMake(IPHONE_WIDTH / 2.0f - 30.0f, backView.bottom, 60.0f, 90.0f) selector:@selector(receiveButtonClick)];
    [self addButtonWithImage:@"home1" title:NSLocalizedString(@"无界发送", nil) frame:CGRectMake(16.0f, backView.bottom, 60.0f, 90.0f) selector:@selector(transferButtonClick)];
    [self addButtonWithImage:@"home2" title:NSLocalizedString(@"邀请好友", nil) frame:CGRectMake(IPHONE_WIDTH - 76.0f, backView.bottom, 60.0f, 90.0f) selector:@selector(inviteFriendButtonClick)];
    [self addButtonWithImage:@"home5" title:NSLocalizedString(@"设置", nil) frame:CGRectMake(IPHONE_WIDTH / 2.0f - 30.0f, backView.bottom + 123.0f, 60.0f, 90.0f) selector:@selector(settingButtonClick)];
    [self addButtonWithImage:@"home4" title:NSLocalizedString(@"发现", nil) frame:CGRectMake(16.0f, backView.bottom + 123.0f, 60.0f, 90.0f) selector:@selector(discoverButtonClick)];
    [self addButtonWithImage:@"home6" title:NSLocalizedString(@"反馈", nil) frame:CGRectMake(IPHONE_WIDTH - 76.0f, backView.bottom + 123.0f, 60.0f, 90.0f) selector:@selector(feedbackButtonClick)];
	
    // 开始监听udp广播
    [[STFileTransferModel shareInstant] startListenBroadcast];
    
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
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)personalSettingClick {
    STPersonalSettingViewController *personalSettingVc = [[STPersonalSettingViewController alloc] init];
    [self.navigationController pushViewController:personalSettingVc animated:YES];
}

- (void)transferButtonClick {
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
    
    if (self.navigationController.topViewController != self) {
        [self.navigationController setViewControllers:@[self, fileSelectionVc] animated:YES];
    } else {
        [self.navigationController pushViewController:fileSelectionVc animated:YES];
    }
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

@end
