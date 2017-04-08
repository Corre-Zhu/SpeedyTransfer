//
//  STTransferInstructionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/23.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STTransferInstructionViewController.h"
#import "STFileTransferViewController.h"
#import "STDeviceButton.h"
#import "STFileTransferModel.h"
#import <GCDWebServerFunctions.h>
#import "STWebServerModel.h"
#import "ZZFileUtility.h"

@interface STTransferInstructionViewController ()
{
    UIScrollView *scrollView;
    UIImageView *topContainerView;
    UIImageView *wifiBgView;
    UILabel *wifiLabel;
    UIImageView *bottomContainerView;
	UIImageView *whiteView2;
	UIButton *button;
	UIView *qrcodeView;
	UIImageView *qrcodeImageView;
	UILabel *ipLabel;
    
    UIView *devicesView;
    UIButton *sendButton;
    UILabel *sendLabel;
    NSMutableArray *deviceButtons;
    
    BOOL viewDidLoad;
    BOOL viewDidAppear;
}

@end

@implementation STTransferInstructionViewController

- (void)dealloc {
    if (viewDidLoad) {
        [[STFileTransferModel shareInstant] removeObserver:self forKeyPath:@"devicesArray"];
    }
}

- (void)setupUI {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    self.navigationItem.title = NSLocalizedString(@"建立连接", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR)];
    scrollView.contentSize = CGSizeMake(IPHONE_WIDTH, 550.0f);
    [self.view addSubview:scrollView];
    
    UILabel *descLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 16.0f, 200.0f, 21.0f)];
    descLabel1.text = NSLocalizedString(@"第一步", nil);
    descLabel1.textColor = [UIColor blackColor];
    descLabel1.font = [UIFont systemFontOfSize:16.0f];
    [scrollView addSubview:descLabel1];

    topContainerView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, descLabel1.bottom + 16, IPHONE_WIDTH - 40, 333.0f)];
    topContainerView.image = [[UIImage imageNamed:@"我要发送_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f)];
    [scrollView addSubview:topContainerView];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"img_bg_121245"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f)]];
    iconView.top = 33.0f;
    iconView.centerX = topContainerView.width / 2.0f;
    [topContainerView addSubview:iconView];
    
    UILabel *descLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, iconView.bottom + 16.0f, topContainerView.width - 32.0, 21.0f)];
    descLabel2.text = NSLocalizedString(@"请好友也接入此Wi-Fi", nil);
    descLabel2.textColor = [UIColor blackColor];
    descLabel2.font = [UIFont systemFontOfSize:16.0f];
    descLabel2.textAlignment = NSTextAlignmentCenter;
    [topContainerView addSubview:descLabel2];
    
    UIImageView *iconView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_bg1"]];
    iconView2.top = descLabel2.bottom + 16.0f;
    iconView2.centerX = topContainerView.width / 2.0f + 3;
    [topContainerView addSubview:iconView2];
    
    wifiBgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wifi_bg0"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 12.0f, 6.0f, 12.0f)]];
    wifiBgView.top = iconView2.bottom;
    wifiBgView.width = 120.0f;
    wifiBgView.height = 40.0f;
    wifiBgView.centerX = topContainerView.width / 2.0f;
    [topContainerView addSubview:wifiBgView];
    
    wifiLabel = [[UILabel alloc] init];
    wifiLabel.textColor = [UIColor whiteColor];
    wifiLabel.font = [UIFont systemFontOfSize:16.0f];
    wifiLabel.textAlignment = NSTextAlignmentCenter;
    [wifiBgView addSubview:wifiLabel];
    
    UILabel *descLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, topContainerView.bottom + 16, 200.0f, 21.0f)];
    descLabel3.text = NSLocalizedString(@"第二步", nil);
    descLabel3.textColor = [UIColor blackColor];
    descLabel3.font = [UIFont systemFontOfSize:16.0f];
    [scrollView addSubview:descLabel3];
    
    bottomContainerView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, descLabel3.bottom + 16, IPHONE_WIDTH - 40, 230.0f)];
    bottomContainerView.backgroundColor = [UIColor clearColor];
    bottomContainerView.image = [[UIImage imageNamed:@"我要发送_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f)];
    [scrollView addSubview:bottomContainerView];

    UILabel *descLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 12.0f, 250.0f, 20.0f)];
    descLabel5.text = @"请好友扫描二维码接收文件";
    descLabel5.font = [UIFont systemFontOfSize:13.0f];
    descLabel5.textColor = [UIColor lightGrayColor];
    [bottomContainerView addSubview:descLabel5];
	
    qrcodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((bottomContainerView.width - 100) / 2.0, descLabel5.bottom + 16, 100, 100)];
	[bottomContainerView addSubview:qrcodeImageView];
	
	UIImageView *lineView2 = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, qrcodeImageView.bottom + 16, bottomContainerView.width - 24, 0.5f)];
	lineView2.backgroundColor = RGBFromHex(0xcacaca);
	[bottomContainerView addSubview:lineView2];
	
	UILabel *descLabel7 = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, lineView2.bottom + 16.0f, bottomContainerView.width - 24, 17.0f)];
	descLabel7.text = NSLocalizedString(@"或请好友打开浏览器输入以下网址接收文件", nil);
	descLabel7.font = [UIFont systemFontOfSize:13.0f];
	descLabel7.textColor = [UIColor lightGrayColor];
	[bottomContainerView addSubview:descLabel7];
	
	ipLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, descLabel7.bottom + 10.0f, bottomContainerView.width - 24, 17.0f)];
	ipLabel.font = [UIFont systemFontOfSize:13.0f];
	ipLabel.textAlignment = NSTextAlignmentCenter;
	ipLabel.textColor = [UIColor grayColor];
	[bottomContainerView addSubview:ipLabel];
    
    scrollView.contentSize = CGSizeMake(IPHONE_WIDTH, bottomContainerView.bottom + 24);
	
    [self reloadWifiName];
}

- (void)reloadWifiName {
    NSString *wifiname = [UIDevice getWifiName];
    if (wifiname.length == 0 && [UIDevice isPersonalHotspotEnabled]) {
        wifiname = [[UIDevice currentDevice] name];
    }
    if (wifiname.length > 0) {
        wifiLabel.text = wifiname;
        [wifiLabel sizeToFit];
        wifiBgView.width = MIN(IPHONE_WIDTH - 40.0f, wifiLabel.width + 40.0f);
        wifiBgView.centerX = (IPHONE_WIDTH - 32.0f) / 2.0f;
        wifiLabel.frame = CGRectMake(0.0f, 0.0f, wifiBgView.width, wifiBgView.height);
        
        [self setup];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    viewDidLoad = YES;
    [[STFileTransferModel shareInstant] addObserver:self forKeyPath:@"devicesArray" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    viewDidAppear = YES;
}

- (void)leftBarButtonItemClick {
    if ([[STWebServerModel shareInstant] isWebServer2Running]) {
        [[STWebServerModel shareInstant] stopWebServer2];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setup {
    NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
    if (address.length == 0) {
        // 获取个人热点ip
        address = [UIDevice hotspotAddress];
    }
    
    if (address.length == 0) {
        return;
    }
    
    address = [NSString stringWithFormat:@"http://%@:%@", address, @(KSERVERPORT2)];
    
    UIImage *image = [address createRRcode];
    if (image.size.width < 100.0f) {
        image = [image resizeImage:image withQuality:kCGInterpolationNone rate:100.0f / image.size.width];
    }
    qrcodeImageView.image = image;
    ipLabel.text = address;
    
    [self setupVariablesAndStartWebServer:[self.fileSelectionTabController allSelectedFiles]];
}

- (void)setupVariablesAndStartWebServer:(NSArray *)files {
	ZZFileUtility *fileUtility = [[ZZFileUtility alloc] init];
	[fileUtility fileInfoWithItems:files completionBlock:^(NSArray *fileInfos) {
		[[STWebServerModel shareInstant] addTransferFiles:fileInfos];
        
        if (![[STWebServerModel shareInstant] isWebServer2Running]) {
            [[STWebServerModel shareInstant] startWebServer2]; // 启动无界传输
        }
        
    }];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.navigationController.topViewController != self) {
            return;
        }
        
        if ([keyPath isEqualToString:@"devicesArray"]) {
            // 如果只发现一台设备，直接选择这台设备
            if ([STFileTransferModel shareInstant].selectedDevicesArray.count == 0 && [STFileTransferModel shareInstant].devicesArray.count >= 1) {
                STDeviceInfo *deviceInfo = [[STFileTransferModel shareInstant].devicesArray firstObject];
                [STFileTransferModel shareInstant].selectedDevicesArray = [NSArray arrayWithObject:deviceInfo];
            }
            
            // 已经选择好设备的情况下直接进入发送界面
            if ([STFileTransferModel shareInstant].selectedDevicesArray.count > 0) {
                [[STFileTransferModel shareInstant] sendItems:[self.fileSelectionTabController allSelectedFiles]];
                [self.fileSelectionTabController removeAllSelectedFiles];
                
                STFileTransferViewController *fileTransferVc = [[STFileTransferViewController alloc] init];
                [self.navigationController pushViewController:fileTransferVc animated:YES];
            }
        }
        
        
        
    });
}


/*
 <div class="container1">
 <div class="container_wj">
 <div class="apk_container">
 <img src="images/ic_picture_green_12dp.png">
 <div class="apk_text">${category}(${count})</div>
 </div>
 <!-- $BeginBlock files -->
 <a href="${fileType}?fp=${path}"> <div class="apk_68dp">
 <div class="icon"><img src="${icon}"></div>
 <div class="apk_text1">${name}</div>
 <div class="xz"><img src="images/xz.png"></div>
 <div class="apk_text2">${length}</div>
 <div class="line"></div>
 </div>
 </a>
 <a href="${fileType}?fp=${path}"> <div class="apk_68dp">
 <div class="icon"><img src="${icon}"></div>
 <div class="apk_text1">${name}</div>
 <div class="xz"><img src="images/xz.png"></div>
 <div class="apk_text2">${length}</div>
 <div class="line"></div>
 </div>
 </a>
 <!-- $EndBlock files -->
 </div>
 <div class="jiange">
	<div class="line1"></div>
 <div class="jianxi"></div>
 <div class="line1"></div>
 </div>
 </div>
 */

@end
