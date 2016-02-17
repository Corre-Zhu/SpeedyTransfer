//
//  STTransferInstructionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/23.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STTransferInstructionViewController.h"
#import "STFileTransferViewController.h"
#import "MCTransceiver.h"
#import "STFileTransferModel.h"

@interface STTransferInstructionViewController ()
{
    UIScrollView *scrollView;
    UIView *topContainerView;
    UIImageView *wifiBgView;
    UILabel *wifiLabel;
    UIView *bottomContainerView;
    
    UIView *devicesView;
    UIButton *sendButton;
}

@end

@implementation STTransferInstructionViewController

- (void)dealloc {
	
}

- (void)setupDeviceView {
    devicesView = [[UIView alloc] init];
    devicesView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:devicesView];
    [devicesView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"我要发送"]];
    imageView.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 460.0f);
    [devicesView addSubview:imageView];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    sendButton.backgroundColor = RGBFromHex(0xeb684b);
    sendButton.frame= CGRectMake((IPHONE_WIDTH - 103.0f) / 2.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 177.0f, 104.0f, 104.0f);
    sendButton.layer.cornerRadius = 52.0f;
    sendButton.layer.masksToBounds = YES;
    [devicesView addSubview:sendButton];
    
    
    
    
    
}

- (void)setupUI {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    self.navigationItem.title = NSLocalizedString(@"建立连接", nil);
    self.view.backgroundColor = RGBFromHex(0xf0f0f0);
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR)];
    scrollView.contentSize = CGSizeMake(IPHONE_WIDTH, 550.0f);
    [self.view addSubview:scrollView];
    
    topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 373.0f)];
    UILabel *descLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 20.0f, 200.0f, 21.0f)];
    descLabel1.text = NSLocalizedString(@"第一步", nil);
    descLabel1.textColor = RGBFromHex(0xeb694a);
    descLabel1.font = [UIFont systemFontOfSize:14.0f];
    [scrollView addSubview:descLabel1];
    
    UIImageView *whiteView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 49.0f, IPHONE_WIDTH - 32.0f, 326.0f)];
    whiteView.image = [[UIImage imageNamed:@"我要发送_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f)];
    [scrollView addSubview:whiteView];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"one-image"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f)]];
    iconView.top = 33.0f;
    iconView.centerX = whiteView.width / 2.0f;
    [whiteView addSubview:iconView];
    
    UILabel *descLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, iconView.bottom + 32.0f, whiteView.width - 32.0, 21.0f)];
    descLabel2.text = NSLocalizedString(@"请好友也接入此Wi-Fi", nil);
    descLabel2.textColor = [UIColor blackColor];
    descLabel2.font = [UIFont systemFontOfSize:16.0f];
    descLabel2.textAlignment = NSTextAlignmentCenter;
    [whiteView addSubview:descLabel2];
    
    UIImageView *iconView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_bg1"]];
    iconView2.top = descLabel2.bottom + 10.0f;
    iconView2.centerX = whiteView.width / 2.0f;
    [whiteView addSubview:iconView2];
    
    wifiBgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wifi_bg0"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 12.0f, 6.0f, 12.0f)]];
    wifiBgView.top = iconView2.bottom;
    wifiBgView.width = 120.0f;
    wifiBgView.height = 40.0f;
    wifiBgView.centerX = whiteView.width / 2.0f;
    [whiteView addSubview:wifiBgView];
    
    wifiLabel = [[UILabel alloc] init];
    wifiLabel.textColor = [UIColor whiteColor];
    wifiLabel.font = [UIFont systemFontOfSize:17.0f];
    wifiLabel.textAlignment = NSTextAlignmentCenter;
    [wifiBgView addSubview:wifiLabel];
    
    bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, topContainerView.bottom, IPHONE_WIDTH, 180.0f)];
    [scrollView addSubview:bottomContainerView];
    
    UILabel *descLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 20.0f, 200.0f, 21.0f)];
    descLabel3.text = NSLocalizedString(@"第二步", nil);
    descLabel3.textColor = RGBFromHex(0xeb694a);
    descLabel3.font = [UIFont systemFontOfSize:14.0f];
    [bottomContainerView addSubview:descLabel3];
    
    UIImageView *whiteView2 = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 49.0f, IPHONE_WIDTH - 32.0f, 100.0f)];
    whiteView2.image = [[UIImage imageNamed:@"我要发送_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f)];
    [bottomContainerView addSubview:whiteView2];
    
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, whiteView2.height / 2.0f, whiteView2.width - 20.0f, 0.5f)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [whiteView2 addSubview:lineView];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"请好友打开点传 > 我要接收", nil)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, string.length)];
    [string addAttribute:NSForegroundColorAttributeName value:RGBFromHex(0xeb694a) range:NSMakeRange(10, 4)];
    
    UILabel *descLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 19.0f, 200.0f, 20.0f)];
    descLabel4.attributedText = string;
    descLabel4.font = [UIFont systemFontOfSize:13.0f];
    [whiteView2 addSubview:descLabel4];
    
    NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"若好友没有点传，请点击这里", nil)];
    [string2 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, string2.length)];
    [string2 addAttribute:NSForegroundColorAttributeName value:RGBFromHex(0xeb694a) range:NSMakeRange(3, 2)];

    UILabel *descLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 65.0f, 200.0f, 20.0f)];
    descLabel5.attributedText = string2;
    descLabel5.font = [UIFont systemFontOfSize:13.0f];
    [whiteView2 addSubview:descLabel5];
    
    [self reloadWifiName];
    
    [self setupDeviceView];
}

- (void)reloadWifiName {
    NSString *wifiname = [UIDevice getWifiName];
    if (wifiname.length > 0) {
        wifiLabel.text = wifiname;
        [wifiLabel sizeToFit];
        wifiBgView.width = MIN(IPHONE_WIDTH - 40.0f, wifiLabel.width + 40.0f);
        wifiBgView.centerX = (IPHONE_WIDTH - 32.0f) / 2.0f;
        wifiLabel.frame = CGRectMake(0.0f, 0.0f, wifiBgView.width, wifiBgView.height);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[STFileTransferModel shareInstant] removeObserver:self forKeyPath:@"connectStatus"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[[STFileTransferModel shareInstant] addObserver:self forKeyPath:@"connectStatus" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
