//
//  STScanQRCodeViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/25.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STScanQRCodeViewController.h"
#import "STWifiNotConnectedPopupView2.h"
#import "ZZReachability.h"
#import "STFileTransferViewController.h"
#import "STConnectWifiAlertView.h"
#import "STWebServerModel.h"

@interface STScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate> {
    UIImageView *scanBackgroundView;
    UILabel *tipLabel;
    UIView *alertView;
    
    UIView *connectingView;
    UILabel *connectingLabel;
    
    STWifiNotConnectedPopupView2 *popupView;
    STConnectWifiAlertView *wifiAlertView;
}

@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation STScanQRCodeViewController

- (void)dealloc {
    [_session stopRunning];
    [[STMultiPeerTransferModel shareInstant] removeObserver:self forKeyPath:@"state"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"我要接收";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    
    scanBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 248.0f, 248.0f)];
    scanBackgroundView.clipsToBounds = YES;
    scanBackgroundView.image = [UIImage imageNamed:@"img_saoma"];
    [self.view addSubview:scanBackgroundView];
    [scanBackgroundView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [scanBackgroundView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.view withOffset:-32.0f];
    [scanBackgroundView autoSetDimensionsToSize:CGSizeMake(248.0f, 248.0f)];
    
    // 设置四周黑背景
    UIView *topBlackView = [[UIView alloc] init];
    topBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:topBlackView];
    [topBlackView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
    [topBlackView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [topBlackView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [topBlackView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:scanBackgroundView];
    
    UIView *bottomBlackView = [[UIView alloc] init];
    bottomBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:bottomBlackView];
    [bottomBlackView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:scanBackgroundView];
    [bottomBlackView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [bottomBlackView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [bottomBlackView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
    
    UIView *leftBlackView = [[UIView alloc] init];
    leftBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:leftBlackView];
    [leftBlackView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:scanBackgroundView];
    [leftBlackView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
    [leftBlackView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:scanBackgroundView];
    [leftBlackView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:scanBackgroundView];
    
    UIView *rightBlackView = [[UIView alloc] init];
    rightBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:rightBlackView];
    [rightBlackView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:scanBackgroundView];
    [rightBlackView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
    [rightBlackView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:scanBackgroundView];
    [rightBlackView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:scanBackgroundView];
    
    tipLabel = [[UILabel alloc] init];
    tipLabel.font = [UIFont systemFontOfSize:12.0f];
    tipLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 0;
    [self.view addSubview:tipLabel];
    tipLabel.text = NSLocalizedString(@"将二维码放入框内，即可扫描", nil);
    [tipLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:scanBackgroundView withOffset:15.0f];
    [tipLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8.0f];
    [tipLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8.0f];
    [tipLabel autoSetDimension:ALDimensionHeight toSize:15.0f];
    
    alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT)];
    UIImageView *qrcodeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_code"]];
    qrcodeView.left = (IPHONE_WIDTH - 88) / 2.0;
    qrcodeView.top = 200;
    [alertView addSubview:qrcodeView];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16.0f];
    label.textColor = [UIColor whiteColor];
    label.text = @"扫一扫点传的二维码，快速接收文件";
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, qrcodeView.bottom + 60, IPHONE_WIDTH, 19);
    [alertView addSubview:label];
    
    UIButton *knowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [knowButton addTarget:self action:@selector(knowButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:knowButton];
    knowButton.frame = CGRectMake((IPHONE_WIDTH - 120) / 2.0, label.bottom + 60, 120, 32);
    knowButton.backgroundColor = RGB(181,185,249);
    [knowButton setTitle:@"我知道了" forState:UIControlStateNormal];
    [knowButton setTitleColor:RGBFromHex(0x2a16c1) forState:UIControlStateNormal];
    
    [[STMultiPeerTransferModel shareInstant] addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFileNotification) name:KReceiveFileNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)noti {
    if ([UIDevice isWiFiEnabled]) {
        if (popupView.superview) {
            [popupView removeFromSuperview];
            popupView = nil;
            
            [self beginScanning];
        }
    }
}

- (void)knowButtonClick {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ScanQrAlert"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [alertView removeFromSuperview];
    alertView = nil;
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
    [[STMultiPeerTransferModel shareInstant] reset];
}

-(void)viewWillAppear:(BOOL)animated{
    [self beginScanning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ScanQrAlert"]) {
        if (alertView) {
            [self.navigationController.view addSubview:alertView];
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                alertView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
            } completion:^(BOOL finished) {
                
            }];
            
        }
    }
    
//    [[STMultiPeerTransferModel shareInstant] startBrowsingForName:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopScanning];
}

#pragma mark-> 获取扫描区域的比例关系
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds {
    CGFloat x,y,width,height;
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    return CGRectMake(x, y, width, height);
}

- (void)beginScanning {
    if (!_session) {
        //获取摄像设备
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //创建输入流
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (!input) return;
        //创建输出流
        AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置有效扫描区域
        CGRect scanCrop=[self getScanCrop:scanBackgroundView.bounds readerViewBounds:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR)];
        output.rectOfInterest = scanCrop;
        //初始化链接对象
        _session = [[AVCaptureSession alloc]init];
        //高质量采集率
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        [_session addInput:input];
        [_session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
        layer.frame=CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR);
        [self.view.layer insertSublayer:layer atIndex:0];
    }
    
    //开始捕获
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

- (void)stopScanning {
    [_session stopRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *result = metadataObject.stringValue;
        if (result.length > 0) {
            NSURL *url = [NSURL URLWithString:result];
            if (!url) {
                return;
            }
            
            NSString *devicename = nil;
            NSArray *queryItems = [url.query componentsSeparatedByString:@"&"];
            for (NSString *str in queryItems) {
                NSArray *arr = [str componentsSeparatedByString:@"="];
                if (arr.count == 2 && [arr.firstObject isEqualToString:@"devicename"]) {
                    devicename = [arr.lastObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
            }
            
            // url中含有设备名称，认为扫描的是iPhone的二维码
            if (devicename.length > 0) {
                if (![UIDevice isWiFiEnabled]) {
                    popupView = [[STWifiNotConnectedPopupView2 alloc] init];
                    __weak typeof(self) weakSelf = self;
                    [popupView showInView:self.navigationController.view hiddenBlock:^{
                        [weakSelf beginScanning];
                    }];
                } else {
                    [[STMultiPeerTransferModel shareInstant] startBrowsingForName:devicename];
                }
            } else {
                wifiAlertView = [[STConnectWifiAlertView alloc] init];
                [wifiAlertView showInView:self.view];
                
                [[STWebServerModel shareInstant] startWebServer];
                [[STFileTransferModel shareInstant] startListenBroadcast];
                [[STFileReceiveModel shareInstant] startBroadcast];
            }
            
            [self stopScanning];
        }
        
    } else {
        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.navigationController.topViewController != self) {
            return;
        }
        
        if (!connectingView) {
            connectingView = [[UIView alloc] initWithFrame:self.view.bounds];
            connectingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
            [self.view addSubview:connectingView];
                                               
            connectingLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
            connectingLabel.textColor = [UIColor whiteColor];
            connectingLabel.font = [UIFont systemFontOfSize:17.0f];
            connectingLabel.textAlignment = NSTextAlignmentCenter;
            [connectingView addSubview:connectingLabel];
            
            UIActivityIndicatorView *ind = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [connectingView addSubview:ind];
            ind.left = (self.view.width - ind.width) / 2.;
            ind.top = self.view.height / 2. - 38;
            [ind startAnimating];
        }
        
        connectingView.hidden = NO;
        switch ([STMultiPeerTransferModel shareInstant].state) {
            case STMultiPeerStateNotConnected:
                connectingLabel.text = @"连接失败";
                break;
            case STMultiPeerStateBrowsing:
            case STMultiPeerStateConnecting:
                connectingLabel.text = @"连接中...";
                break;
            case STMultiPeerStateConnected:{
                connectingLabel.text = @"连接成功";
                
                STFileTransferViewController *vc = [[STFileTransferViewController alloc] init];
                vc.isMultipeerTransfer = YES;
                vc.isFromReceive = YES;
                
                NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [controllers removeLastObject];
                [controllers addObject:vc];
                
                [self.navigationController setViewControllers:controllers animated:YES];
                
            }

                break;
            default:
                break;
        }
    });
}

- (void)receiveFileNotification {
    // 当开始接收到文件并且在主界面时跳转至接收界面
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.navigationController.topViewController == self) {
            STFileTransferViewController *fileTransferVc = [[STFileTransferViewController alloc] init];
            fileTransferVc.isFromReceive = YES;
            [self.navigationController pushViewController:fileTransferVc animated:YES];
            
            [wifiAlertView removeFromSuperview];
            wifiAlertView = nil;
        }
    });
}

@end
