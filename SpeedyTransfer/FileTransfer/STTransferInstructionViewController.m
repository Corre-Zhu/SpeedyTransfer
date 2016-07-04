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
    UIView *topContainerView;
    UIImageView *wifiBgView;
    UILabel *wifiLabel;
    UIView *bottomContainerView;
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

- (void)setupDeviceView {
    if (!devicesView) {
        devicesView = [[UIView alloc] init];
        devicesView.backgroundColor = [UIColor whiteColor];
        devicesView.clipsToBounds = YES;
        [self.view addSubview:devicesView];
        [devicesView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendButton setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        sendButton.backgroundColor = RGBFromHex(0xeb684b);
        sendButton.frame= CGRectMake((IPHONE_WIDTH - 103.0f) / 2.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 177.0f, 104.0f, 104.0f);
        sendButton.layer.cornerRadius = 52.0f;
        sendButton.layer.masksToBounds = YES;
        [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [devicesView addSubview:sendButton];
        
        sendLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, sendButton.bottom + 13.0f, IPHONE_WIDTH - 40.0f, 16.0f)];
        sendLabel.text = NSLocalizedString(@"点击选择用户发送文件", nil);
        sendLabel.font = [UIFont systemFontOfSize:14.0f];
        sendLabel.textColor = [UIColor grayColor];
        sendLabel.textAlignment = NSTextAlignmentCenter;
        [devicesView addSubview:sendLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"我要发送"]];
        imageView.top = sendButton.top - imageView.height + 170.0f;
        imageView.left = (IPHONE_WIDTH - imageView.width) / 2.0f;
        imageView.contentMode = UIViewContentModeCenter;
        imageView.backgroundColor = [UIColor lightGrayColor];
        [devicesView insertSubview:imageView belowSubview:sendButton];
        
        NSArray *rectsArr = @[NSStringFromCGRect(CGRectMake(88.0f, imageView.bottom - 473.0f, 42.0f, 42.0f)),
                              NSStringFromCGRect(CGRectMake(IPHONE_WIDTH - 130.0f, imageView.bottom - 473.0f, 42.0f, 42.0f)),
                              NSStringFromCGRect(CGRectMake(30.0f, imageView.bottom - 350.0f, 42.0f, 42.0f)),
                              NSStringFromCGRect(CGRectMake(IPHONE_WIDTH / 2.0f - 21.0f, imageView.bottom - 370.0f, 42.0f, 42.0f)),
                              NSStringFromCGRect(CGRectMake(IPHONE_WIDTH - 72.0f, imageView.bottom - 350.0f, 42.0f, 42.0f)),
                              ];
        
        deviceButtons = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            STDeviceButton *deviceButton = [[STDeviceButton alloc] initWithFrame:CGRectFromString([rectsArr objectAtIndex:i])];
            [devicesView addSubview:deviceButton];
            deviceButton.hidden = YES;
            [deviceButtons addObject:deviceButton];
        }
        
        self.navigationItem.title = NSLocalizedString(@"我要发送", nil);
    }
    
    NSArray *tempArr = [STFileTransferModel shareInstant].devicesArray;
    for (int i = 0; i < 5; i++) {
        STDeviceButton *deviceButton = [deviceButtons objectAtIndex:i];
        if (tempArr.count > i) {
            STDeviceInfo *userinfo = [tempArr objectAtIndex:i];
            deviceButton.deviceInfo = userinfo;
            deviceButton.hidden = NO;
        } else {
            deviceButton.hidden = YES;
        }
    }
    
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
	bottomContainerView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:bottomContainerView];
    
    UILabel *descLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 20.0f, 200.0f, 21.0f)];
    descLabel3.text = NSLocalizedString(@"第二步", nil);
    descLabel3.textColor = RGBFromHex(0xeb694a);
    descLabel3.font = [UIFont systemFontOfSize:14.0f];
    [bottomContainerView addSubview:descLabel3];
    
    whiteView2 = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 49.0f, IPHONE_WIDTH - 32.0f, 100.0f)];
    whiteView2.image = [[UIImage imageNamed:@"我要发送_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f)];
	whiteView2.userInteractionEnabled = YES;
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
	
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(10.0f, 55.0f, whiteView2.width - 20.0f, 40.0f);
	button.backgroundColor = [UIColor clearColor];
	[button setImage:[UIImage imageNamed:@"ic_keyboard_arrow_down_grey600"] forState:UIControlStateNormal];
	button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, button.width - 30.0f, 0.0f, 0.0f);
	[button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
	[whiteView2 addSubview:button];
	
	
	qrcodeView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 95.0f, whiteView2.width - 20.0f, 230.0f)];
	[whiteView2 addSubview:qrcodeView];
	qrcodeView.hidden = YES;
	
	UIImageView *lineView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, qrcodeView.width, 0.5f)];
	lineView2.backgroundColor = [UIColor lightGrayColor];
	[qrcodeView addSubview:lineView2];
	
	UILabel *descLabel6 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 12.0f, 200.0f, 20.0f)];
	descLabel6.text = NSLocalizedString(@"请好友扫描二维码接收文件", nil);
	descLabel6.font = [UIFont systemFontOfSize:13.0f];
	descLabel6.textColor = [UIColor grayColor];
	[qrcodeView addSubview:descLabel6];
	
	qrcodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((qrcodeView.width - 100.0f) / 2.0f, descLabel6.bottom + 12.0f, 100.0f, 100.0f)];
	qrcodeImageView.contentMode = UIViewContentModeScaleAspectFit;
	[qrcodeView addSubview:qrcodeImageView];
	
	UIImageView *lineView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, qrcodeImageView.bottom + 12.0f, qrcodeView.width, 0.5f)];
	lineView3.backgroundColor = [UIColor lightGrayColor];
	[qrcodeView addSubview:lineView3];
	
	UILabel *descLabel7 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, lineView3.bottom + 12.0f, qrcodeView.width, 20.0f)];
	descLabel7.text = NSLocalizedString(@"或请好友打开浏览器输入以下网址接收文件", nil);
	descLabel7.font = [UIFont systemFontOfSize:13.0f];
	descLabel7.textColor = [UIColor grayColor];
	[qrcodeView addSubview:descLabel7];
	
	ipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, descLabel7.bottom + 9.0f, qrcodeView.width, 20.0f)];
	ipLabel.font = [UIFont systemFontOfSize:13.0f];
	ipLabel.textAlignment = NSTextAlignmentCenter;
	ipLabel.textColor = [UIColor grayColor];
	[qrcodeView addSubview:ipLabel];
	
    [self reloadWifiName];
    
    if ([STFileTransferModel shareInstant].devicesArray.count > 0) {
        [self setupDeviceView];
    }
    
    [[STFileTransferModel shareInstant] addObserver:self forKeyPath:@"devicesArray" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"devicesArray"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.navigationController.topViewController != self) {
                return;
            }
            
            [self setupDeviceView];
            
            if (viewDidAppear) {
                // 如果只发现一台设备，直接选择这台设备
                if ([STFileTransferModel shareInstant].selectedDevicesArray.count == 0 && [STFileTransferModel shareInstant].devicesArray.count == 1) {
                    STDeviceInfo *deviceInfo = [[STFileTransferModel shareInstant].devicesArray firstObject];
                    [STFileTransferModel shareInstant].selectedDevicesArray = [NSArray arrayWithObject:deviceInfo];
                }
                
                // 已经选择好设备的情况下直接进入发送界面
                if ([STFileTransferModel shareInstant].selectedDevicesArray.count > 0) {
                    [[STFileTransferModel shareInstant] sendItems:[self.fileSelectionTabController allSelectedFiles]];
                    [self.fileSelectionTabController removeAllSelectedFiles];
                    
                    STFileTransferViewController *fileTransferVc = [[STFileTransferViewController alloc] init];
                    [self.navigationController pushViewController:fileTransferVc animated:YES];
                } else {
                    STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
                    [self.navigationController pushViewController:transferIns animated:YES];
                }
            }
        });
    }
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
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    viewDidLoad = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    viewDidAppear = YES;
}

- (void)sendButtonClick {
    NSMutableArray *tempArr = [NSMutableArray array];
    for (STDeviceButton *button in deviceButtons) {
        if ([button isSelected] && !button.hidden) {
            [tempArr addObject:button.deviceInfo];
        }
    }
    
    if (tempArr.count > 0) {
        [STFileTransferModel shareInstant].selectedDevicesArray = [NSArray arrayWithArray:tempArr];
        
        [[STFileTransferModel shareInstant] sendItems:[self.fileSelectionTabController allSelectedFiles]];
        [self.fileSelectionTabController removeAllSelectedFiles];
        
        STFileTransferViewController *fileTransferVc = [[STFileTransferViewController alloc] init];
        [self.navigationController pushViewController:fileTransferVc animated:YES];
    }
    
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonClick {
	if (qrcodeView.hidden) {
		NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
		if (address.length == 0) {
			// 获取个人热点ip
			address = [UIDevice hotspotAddress];
		}
		
		if (address.length == 0) {
			return;
		}
		
		address = [NSString stringWithFormat:@"http://%@:%@", address, @(KSERVERPORT2)];
		[button setImage:[UIImage imageNamed:@"ic_keyboard_arrow_up_grey600"] forState:UIControlStateNormal];
		qrcodeView.hidden = NO;
		whiteView2.frame = CGRectMake(16.0f, 49.0f, IPHONE_WIDTH - 32.0f, 328.0f);
		scrollView.contentSize = CGSizeMake(IPHONE_WIDTH, 778.0f);
		
		UIImage *image = [address createRRcode];
		if (image.size.width < 100.0f) {
			image = [image resizeImage:image withQuality:kCGInterpolationNone rate:100.0f / image.size.width];
		}
		qrcodeImageView.image = image;
		ipLabel.text = address;
		[scrollView setContentOffset:CGPointMake(0.0f, scrollView.contentSize.height - scrollView.height) animated:YES];
		
        [self setupVariablesAndStartWebServer:[self.fileSelectionTabController allSelectedFiles]];
	} else {
		[button setImage:[UIImage imageNamed:@"ic_keyboard_arrow_down_grey600"] forState:UIControlStateNormal];
		qrcodeView.hidden = YES;
		whiteView2.frame = CGRectMake(16.0f, 49.0f, IPHONE_WIDTH - 32.0f, 100.0f);
		scrollView.contentSize = CGSizeMake(IPHONE_WIDTH, 550.0f);
		
		[[STWebServerModel shareInstant] stopWebServer2]; // 停止无界传输
		[[STFileTransferModel shareInstant] removeAllBrowser];
	}
}

// 设置无界传输变量值
- (NSString *)htmlForFileInfo:(NSArray *)fileInfos category:(NSString *)category image:(NSString *)imageName icon:(NSString *)iconName {
	NSMutableString *htmlString = [NSMutableString string];

	[htmlString appendFormat:@"<div class=\"container1\"> \
	 <div class=\"container_wj\"> \
	 <div class=\"apk_container\"> \
	 <img src=\"%@\"> \
	 <div class=\"apk_text\">%@(%@)</div> \
	 </div>", imageName, category, @(fileInfos.count)];
	
	for (NSDictionary *fileInfo in fileInfos) {
		NSString *url = [fileInfo stringForKey:FILE_URL];
		NSString *iconUrl = [fileInfo stringForKey:ICON_URL];
		if (!iconUrl) {
			iconUrl = iconName;
		}
		NSString *fileName = [fileInfo stringForKey:FILE_NAME];
		double fileSize = [fileInfo doubleForKey:FILE_SIZE];
		NSString *fileSizeString = [NSString formatSize:fileSize];
		[htmlString appendFormat:@"<a href=\"%@\"> <div class=\"apk_68dp\"> \
		 <div class=\"icon\"><img src=\"%@\"></div> \
		 <div class=\"apk_text1\">%@</div> \
		 <div class=\"xz\"><img src=\"images/xz.png\"></div> \
		 <div class=\"apk_text2\">%@</div> \
		 <div class=\"line\"></div> \
		 </div> \
		 </a>", url, iconUrl, fileName, fileSizeString];
	}
	
	[htmlString appendFormat:@" </div> \
	 <div class=\"jiange\"> \
	 <div class=\"line1\"></div> \
	 <div class=\"jianxi\"></div> \
	 <div class=\"line1\"></div> \
	 </div> \
	 </div>"];
	
	return htmlString;
}

- (void)setupVariablesAndStartWebServer:(NSArray *)files {
	ZZFileUtility *fileUtility = [[ZZFileUtility alloc] init];
	[fileUtility fileInfoWithItems:files completionBlock:^(NSArray *fileInfos) {
		NSMutableArray *picArray = [NSMutableArray arrayWithCapacity:fileInfos.count];
		NSMutableArray *musicArray = [NSMutableArray arrayWithCapacity:fileInfos.count];
		NSMutableArray *videoArray = [NSMutableArray arrayWithCapacity:fileInfos.count];
		NSMutableArray *contactArray = [NSMutableArray arrayWithCapacity:fileInfos.count];
		for (NSDictionary *fileInfo in fileInfos) {
			NSString *url = [fileInfo stringForKey:FILE_URL];
			NSString *fileType = [fileInfo stringForKey:FILE_TYPE];
			if ([url containsString:@"/image/"]) {
				if ([fileType.lowercaseString isEqualToString:@"mov"] ||
					[fileType.lowercaseString isEqualToString:@"3gp"] ||
					[fileType.lowercaseString isEqualToString:@"mp4"]) {
					[videoArray addObject:fileInfo];
				} else {
					[picArray addObject:fileInfo];
				}
			} else if ([url containsString:@"/contact/"]) {
				[contactArray addObject:fileInfo];
			} else if ([url containsString:@"/music/"]) {
				[musicArray addObject:fileInfo];
			}
		}
		
		NSMutableString *htmlString = [NSMutableString string];

		if (picArray.count > 0) {
			[htmlString appendString:[self htmlForFileInfo:picArray category:@"图片" image:@"images/ic_picture_red_24dp.png" icon:nil]];
		}
		
		if (musicArray.count > 0) {
			[htmlString appendString:[self htmlForFileInfo:musicArray category:@"音乐" image:@"images/ic_picture_green_12dp.png" icon:@"images/ic_music_purple_40dp.png"]];
		}
		
		if (videoArray.count > 0) {
			[htmlString appendString:[self htmlForFileInfo:videoArray category:@"视频" image:@"images/ic_picture_green_12dp.png" icon:nil]];
		}
		
		if (contactArray.count > 0) {
			[htmlString appendString:[self htmlForFileInfo:contactArray category:@"联系人" image:@"images/ic_picture_green_12dp.png" icon:@"images/wendang.png"]];
		}

		NSString *summary = [NSString stringWithFormat:@"%@给您发送了%@个文件", [UIDevice currentDevice].name, @([self.fileSelectionTabController allSelectedFiles].count)];
		[[STWebServerModel shareInstant] setVariables:@{@"summary": summary,
														@"fileInfo": htmlString}];
        
        if (![[STWebServerModel shareInstant] isWebServer2Running]) {
            [[STWebServerModel shareInstant] startWebServer2]; // 启动无界传输
            [[STWebServerModel shareInstant] startWebServer]; // 启动文件传输服务

        }
        
    }];

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
