//
//  STEstablishConnectViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/25.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STEstablishConnectViewController.h"
#import "ZZFunction.h"

@interface STEstablishConnectViewController () {
    UIScrollView *scrollView;
    UIImageView *qrcodeView;
    UIView *bottomContainerView;
    UIImageView *arrowIcon;
    UIView *hotspotView;
    UILabel *tipsLabel;
}

@end

@implementation STEstablishConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"建立连接";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR)];
    [self.view addSubview:scrollView];
    
    UIView *topContainerView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, IPHONE_WIDTH - 40, 400)];
    topContainerView.layer.borderWidth = 1;
    topContainerView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7].CGColor;
    topContainerView.layer.cornerRadius = 5;
    [scrollView addSubview:topContainerView];
    
    qrcodeView = [[UIImageView alloc] initWithFrame:CGRectMake((topContainerView.width - 180) / 2.0, 80, 180, 180)];
    [topContainerView addSubview:qrcodeView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, qrcodeView.bottom + 60, topContainerView.width, 24)];
    label1.text = NSLocalizedString(@"点传扫一扫快速接收", nil);
    label1.textColor = RGBFromHex(0x01cc99);
    label1.font = [UIFont systemFontOfSize:19.0f];
    label1.textAlignment = NSTextAlignmentCenter;
    [topContainerView addSubview:label1];

    bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(20, topContainerView.bottom + 20, IPHONE_WIDTH - 40, 100)];
    bottomContainerView.layer.borderWidth = 1;
    bottomContainerView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7].CGColor;
    bottomContainerView.layer.cornerRadius = 5;
    [scrollView addSubview:bottomContainerView];
    
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowButton addTarget:self action:@selector(arrowButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomContainerView addSubview:arrowButton];
    arrowButton.frame = CGRectMake(0, 0, bottomContainerView.width, 100);
    
    UIImageView *sendIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_zhifeiji"]];
    [bottomContainerView addSubview:sendIcon];
    sendIcon.left = 16;
    sendIcon.top = 30;
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(sendIcon.right + 16, 30, 150, 19)];
    label2.text = NSLocalizedString(@"无界传送", nil);
    label2.textColor = RGBFromHex(0x333333);
    label2.font = [UIFont systemFontOfSize:16.0f];
    label2.textAlignment = NSTextAlignmentLeft;
    [bottomContainerView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(sendIcon.right + 16, label2.bottom + 9.0f, 250, 15)];
    label3.text = NSLocalizedString(@"接收方没有点传？请点击这里", nil);
    label3.textColor = RGBFromHex(0x333333);
    label3.font = [UIFont systemFontOfSize:12.0f];
    label3.textAlignment = NSTextAlignmentLeft;
    [bottomContainerView addSubview:label3];

    arrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_arrow-down"] highlightedImage:[UIImage imageNamed:@"ic_arrow-up"]];
    [bottomContainerView addSubview:arrowIcon];
    arrowIcon.left = bottomContainerView.width - 38;
    arrowIcon.top = 39;
    
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bottomContainerView.bottom + 34, IPHONE_WIDTH, 15)];
    tipsLabel.text = NSLocalizedString(@"Tips:两手机距离小于10米时，传输速度飞快", nil);
    tipsLabel.textColor = RGBFromHex(0x666666);
    tipsLabel.font = [UIFont systemFontOfSize:12.0f];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:tipsLabel];
    
    scrollView.contentSize = CGSizeMake(IPHONE_WIDTH, tipsLabel.bottom + 5);
    
    hotspotView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, bottomContainerView.width, 0)];
    [bottomContainerView addSubview:hotspotView];
    
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(16, 0, hotspotView.width - 32, 0.5)];
    sep.backgroundColor = RGBFromHex(0xcacaca);
    [hotspotView addSubview:sep];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, hotspotView.width, 19)];
    label5.text = NSLocalizedString(@"请按以下步骤操作", nil);
    label5.textColor = RGBFromHex(0x333333);
    label5.font = [UIFont systemFontOfSize:16.0f];
    label5.textAlignment = NSTextAlignmentCenter;
    [hotspotView addSubview:label5];
    
    UIImageView *imageV1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_redian"]];
    [hotspotView addSubview:imageV1];
    imageV1.left = 24;
    imageV1.top = label5.bottom + 20;
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(imageV1.right + 20, imageV1.top, hotspotView.width - 97, 29)];
    label6.text = NSLocalizedString(@"1.本机进入蜂窝移动网络，开启蜂窝数据", nil);
    label6.textColor = RGBFromHex(0x333333);
    label6.font = [UIFont systemFontOfSize:12.0f];
    label6.textAlignment = NSTextAlignmentLeft;
    label6.numberOfLines = 0;
    [hotspotView addSubview:label6];
    [label6 sizeToFit];
    label6.left = imageV1.right + 20;
    label6.top = imageV1.top;
    label6.height = MAX(29, label6.height);
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, hotspotView.width - 97, 0)];
    label7.text = NSLocalizedString(@"(注：因IOS自身的限制，必须先开启此功能，才能继续，但点传传输文件时不会消耗流量，请放心开启)", nil);
    label7.textColor = RGBFromHex(0xff6633);
    label7.font = [UIFont systemFontOfSize:12.0f];
    label7.textAlignment = NSTextAlignmentLeft;
    label7.numberOfLines = 0;
    [hotspotView addSubview:label7];
    [label7 sizeToFit];
    label7.left = imageV1.right + 20;
    label7.top = MAX(imageV1.bottom, label6.bottom) + 3.0;
    
    UIImageView *imageV2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_lianjie"]];
    [hotspotView addSubview:imageV2];
    imageV2.left = 24;
    imageV2.top = label7.bottom + 13;
    
    UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(imageV1.right + 20, imageV2.top, hotspotView.width - 97, 29)];
    label8.text = NSLocalizedString(@"2.打开“个人热点”，并将热点密码告知接收方", nil);
    label8.textColor = RGBFromHex(0x333333);
    label8.font = [UIFont systemFontOfSize:12.0f];
    label8.textAlignment = NSTextAlignmentLeft;
    [hotspotView addSubview:label8];
    label8.numberOfLines = 0;
    [label8 sizeToFit];
    label8.left = imageV1.right + 20;
    label8.top = imageV2.top;
    label8.height = MAX(29, label8.height);
    
    UIImageView *imageV3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_logo_58"]];
    [hotspotView addSubview:imageV3];
    imageV3.left = 24;
    imageV3.top = MAX(label8.bottom, imageV2.bottom) + 24;
    
    UILabel *label9 = [[UILabel alloc] initWithFrame:CGRectMake(imageV3.right + 20, imageV3.top, hotspotView.width - 97, 29)];
    label9.text = NSLocalizedString(@"3.本机返回 点传，请接收方按提示操作", nil);
    label9.textColor = RGBFromHex(0x333333);
    label9.font = [UIFont systemFontOfSize:12.0f];
    label9.textAlignment = NSTextAlignmentLeft;
    [hotspotView addSubview:label9];
    label9.numberOfLines = 0;
    [label9 sizeToFit];
    label9.left = imageV1.right + 20;
    label9.top = imageV3.top;
    label9.height = MAX(29, label9.height);
    
    UIButton *hotspotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hotspotButton addTarget:self action:@selector(hotspotButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [hotspotView addSubview:hotspotButton];
    hotspotButton.frame = CGRectMake((hotspotView.width - 160) / 2.0, MAX( imageV3.bottom, label9.bottom) + 15, 160, 38);
    hotspotButton.backgroundColor = RGBFromHex(0x01cc99);
    hotspotButton.layer.cornerRadius = 2;
    [hotspotButton setTitle:@"去开启个人热点" forState:UIControlStateNormal];
    
    hotspotView.height = hotspotButton.bottom + 10;
    hotspotView.hidden = YES;
    
    [self generateQrcode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)generateQrcode {
    qrcodeView.image = [ZZFunction qrCodeImageWithStr:@"Hello World" withSize:180 topImage:nil];
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)arrowButtonClick {
    if (!arrowIcon.highlighted) {
        arrowIcon.highlighted = YES;
        hotspotView.hidden = NO;
        bottomContainerView.height = hotspotView.bottom;
        tipsLabel.top = bottomContainerView.bottom + 10;
        scrollView.contentSize = CGSizeMake(IPHONE_WIDTH, tipsLabel.bottom + 10);
        [scrollView setContentOffset:CGPointMake(0, scrollView.contentSize.height - scrollView.height) animated:YES];
        
    } else {
        arrowIcon.highlighted = NO;
        hotspotView.hidden = YES;
        bottomContainerView.height = 100;
        tipsLabel.top = bottomContainerView.bottom + 34;
        scrollView.contentSize = CGSizeMake(IPHONE_WIDTH, tipsLabel.bottom + 5);
    }
}

- (void)hotspotButtonClick {
    
}

@end
