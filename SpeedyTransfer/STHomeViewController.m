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
#import "STFileReceivingViewController.h"
#import "STFileTransferViewController.h"

@interface STHomeViewController ()

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
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 36.0f)];
    customView.backgroundColor = [UIColor clearColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_overflow_light"]];
    dotImageView.top = 10.0f;
    [customView addSubview:dotImageView];
    
    UIImageView *headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"head2"]];
    headImageView.left = 9.0f;
    headImageView.top = 4.0f;
    headImageView.width = 28.0f;
    headImageView.height = 28.0f;
    headImageView.layer.cornerRadius = 14.0f;
    headImageView.layer.borderWidth = 1.5f;
    headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
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
    button.frame = CGRectMake(16.0f, 40.0f, IPHONE_WIDTH - 32.0f, 80.0f);
    [button addTarget:self action:@selector(transferButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:button];
    
    UILabel *descLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 20.0f, 200.0f, 21.0f)];
    descLabel1.text = NSLocalizedString(@"无界传送", nil);
    descLabel1.textColor = [UIColor whiteColor];
    descLabel1.font = [UIFont systemFontOfSize:18.0f];
    [button addSubview:descLabel1];
    
    UILabel *descLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 45.0f, 200.0f, 15.0f)];
    descLabel2.text = NSLocalizedString(@"好友无需安装点传，零流量互传文件", nil);
    descLabel2.textColor = [UIColor whiteColor];
    descLabel2.font = [UIFont systemFontOfSize:12.0f];
    [button addSubview:descLabel2];
    
    UIImageView *transferImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transfer"]];
    transferImageView.frame = CGRectMake(button.width - 80.0f, 9.0f, 63.0f, 63.0f);
    [button addSubview:transferImageView];
    
    CGFloat inset = IPHONE_WIDTH / 375.0f * 65.0f;
    
    [self addButtonWithImage:@"home3" title:NSLocalizedString(@"我要接收", nil) frame:CGRectMake(IPHONE_WIDTH / 2.0f - 30.0f, backView.bottom, 60.0f, 90.0f) selector:@selector(receiveButtonClick)];
    [self addButtonWithImage:@"home1" title:NSLocalizedString(@"无界传送", nil) frame:CGRectMake(IPHONE_WIDTH / 2.0f - 90.0f - inset, backView.bottom, 60.0f, 90.0f) selector:@selector(transferButtonClick)];
    [self addButtonWithImage:@"home2" title:NSLocalizedString(@"邀请好友", nil) frame:CGRectMake(IPHONE_WIDTH / 2.0f + 30.0f + inset, backView.bottom, 60.0f, 90.0f) selector:@selector(inviteFriendButtonClick)];
    [self addButtonWithImage:@"home5" title:NSLocalizedString(@"设置", nil) frame:CGRectMake(IPHONE_WIDTH / 2.0f - 30.0f, backView.bottom + 123.0f, 60.0f, 90.0f) selector:@selector(settingButtonClick)];
    [self addButtonWithImage:@"home4" title:NSLocalizedString(@"发现", nil) frame:CGRectMake(IPHONE_WIDTH / 2.0f - 90.0f - inset, backView.bottom + 123.0f, 60.0f, 90.0f) selector:@selector(discoverButtonClick)];
    [self addButtonWithImage:@"home6" title:NSLocalizedString(@"反馈", nil) frame:CGRectMake(IPHONE_WIDTH / 2.0f + 30.0f + inset, backView.bottom + 123.0f, 60.0f, 90.0f) selector:@selector(feedbackButtonClick)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@", NSStringFromCGSize([[UIScreen mainScreen] currentMode].size));
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
    STFileReceivingViewController *receiveVc = [[STFileReceivingViewController alloc] init];
    [self.navigationController pushViewController:receiveVc animated:YES];
}

- (void)inviteFriendButtonClick {
    
}

- (void)discoverButtonClick {
    
}

- (void)settingButtonClick {
    
}

- (void)feedbackButtonClick {
    STFileTransferViewController *sdf = [[STFileTransferViewController alloc] init];
    [self.navigationController pushViewController:sdf animated:YES];
}

@end
