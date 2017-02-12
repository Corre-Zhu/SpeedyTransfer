//
//  STInviteFriendViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STInviteFriendViewController.h"
#import <MessageUI/MessageUI.h>
#import "HTEmailViewController.h"
#import "MBProgressHUD.h"
#import <Social/Social.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#define KShareContent @"Hi我一直在用@点传，不仅文件传输速度快，而且传输过程完全无需流量、为批量极速传输大文件的利器，快去下载吧！https://appsto.re/cn/isUdcb.i安卓版点击这里：http://3tkj.cn/dl.php"

@interface STInviteFriendViewController ()
{
    UILabel *label;
    UISwitch *switchCon;
    UIImageView *imageView;
    UIImageView *subImageView;

}

@end

@implementation STInviteFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"邀请好友安装", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    
    CGFloat width = 249.0f;
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH / 2.0f, 22.0f, 1.0f, (IPHONE_HEIGHT_WITHOUTTOPBAR - width - 60.0f) / 2.0f)];
    line1.backgroundColor = RGBFromHex(0xc8c7cc);
    [self.view addSubview:line1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake((IPHONE_WIDTH - 183.0f) / 2.0f, line1.bottom + 41.0f, 183.0f, 183.0f)];
    view2.backgroundColor = [UIColor whiteColor];
    view2.layer.borderColor = RGBFromHex(0xd9d9d9).CGColor;
    view2.layer.borderWidth = 1.0f;
    view2.layer.cornerRadius = 10.0f;
    view2.transform = CGAffineTransformMakeRotation(M_PI_4);
    [self.view addSubview:view2];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH / 2.0f, view2.bottom + 8.0f, 1.0f, (IPHONE_HEIGHT_WITHOUTTOPBAR - width - 60.0f) / 2.0f)];
    line2.backgroundColor = RGBFromHex(0xc8c7cc);
    [self.view addSubview:line2];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, view2.centerY, (IPHONE_WIDTH - width - 16.0f) / 2.0f, 1.0f)];
    line3.backgroundColor = RGBFromHex(0xc8c7cc);
    [self.view addSubview:line3];

    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH - line3.width, view2.centerY, line3.width, 1.0f)];
    line4.backgroundColor = RGBFromHex(0xc8c7cc);
    [self.view addSubview:line4];

    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, view2.top - 14.0f, IPHONE_WIDTH / 2.0f, 18.0f)];
    label1.text = NSLocalizedString(@"邮件", nil);
    label1.textColor = RGBFromHex(0x323232);
    label1.font = [UIFont systemFontOfSize:14.0f];
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:[UIImage imageNamed:@"mail"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(emailButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button1.frame = CGRectMake((IPHONE_WIDTH / 2.0f - 72.0f) / 2.0f, label1.top - 81.0f, 72.0f, 72.0f);
    [self.view addSubview:button1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_WIDTH / 2.0f, view2.top - 14.0f, IPHONE_WIDTH / 2.0f, 18.0f)];
    label2.text = NSLocalizedString(@"微博", nil);
    label2.textColor = RGBFromHex(0x323232);
    label2.font = [UIFont systemFontOfSize:14.0f];
    label2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label2];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setImage:[UIImage imageNamed:@"weibo"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(weiboButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button2.frame = CGRectMake(IPHONE_WIDTH / 2.0f + (IPHONE_WIDTH / 2.0f - 72.0f) / 2.0f, label1.top - 81.0f, 72.0f, 72.0f);
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(weixinButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button3.frame = CGRectMake((IPHONE_WIDTH / 2.0f - 72.0f) / 2.0f, view2.bottom, 72.0f, 72.0f);
    [self.view addSubview:button3];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, button3.bottom + 9.0f, IPHONE_WIDTH / 2.0f, 18.0f)];
    label3.text = NSLocalizedString(@"微信", nil);
    label3.textColor = RGBFromHex(0x323232);
    label3.font = [UIFont systemFontOfSize:14.0f];
    label3.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button4 setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(qqButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button4.frame = CGRectMake(IPHONE_WIDTH / 2.0f + (IPHONE_WIDTH / 2.0f - 72.0f) / 2.0f, view2.bottom, 72.0f, 72.0f);
    [self.view addSubview:button4];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_WIDTH / 2.0f, button4.bottom + 9.0f, IPHONE_WIDTH / 2.0f, 18.0f)];
    label4.text = NSLocalizedString(@"腾讯QQ", nil);
    label4.textColor = RGBFromHex(0x323232);
    label4.font = [UIFont systemFontOfSize:14.0f];
    label4.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4];

    switchCon = [[UISwitch alloc] init];
    switchCon.top = view2.bottom - 60.0f;
    switchCon.left = IPHONE_WIDTH / 2.0f - switchCon.width / 2.0f;
    [switchCon addTarget:self action:@selector(switchConClick) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchCon];
    switchCon.on = YES;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake((IPHONE_WIDTH - 110.0f) / 2.0f, line1.bottom + 60.0f, 110.0f, 110.0f)];
    UIImage *image = [KIOSDownloadUrl createRRcode];
    if (image.size.width < 110.0f) {
        image = [image resizeImage:image withQuality:kCGInterpolationNone rate:110.0f / image.size.width];
    }
    imageView.image = image;
    [self.view addSubview:imageView];
    
    subImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apple-0"]];
    [imageView addSubview:subImageView];
    [subImageView autoCenterInSuperview];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.left - 5.0f, imageView.bottom + 8.0f, imageView.width + 10.0f, 18.0f)];
    label.text = NSLocalizedString(@"点击切换至安卓版", nil);
    label.font = [UIFont systemFontOfSize:15.0f];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSuccessHUD {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:keyWindow];
    
    [keyWindow addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
    HUD.minSize = CGSizeMake(100, 100);
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"OK", @"OK");
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];
}

- (void)switchConClick {
    if (switchCon.on) {
        UIImage *image = [KIOSDownloadUrl createRRcode];
        if (image.size.width < 110.0f) {
            image = [image resizeImage:image withQuality:kCGInterpolationNone rate:110.0f / image.size.width];
        }
        imageView.image = image;
        subImageView.image = [UIImage imageNamed:@"apple-0"];
        label.text = NSLocalizedString(@"点击切换至安卓版", nil);
    } else {
        UIImage *image = [KAndroidDownloadUrl createRRcode];
        if (image.size.width < 110.0f) {
            image = [image resizeImage:image withQuality:kCGInterpolationNone rate:110.0f / image.size.width];
        }
        imageView.image = image;
        subImageView.image = [UIImage imageNamed:@"android"];
        label.text = NSLocalizedString(@"点击切换至IOS版", nil);
    }
}

- (void)emailButtonClick {
    if (![MFMailComposeViewController canSendMail]) {
        [UIAlertController showMessage:NSLocalizedString(@"您还没有设置电子邮件帐户", nil) inViewController:self];
        return;
    }
    
    HTEmailViewController *emailVC = [[HTEmailViewController alloc] init];
    [emailVC setSubject:NSLocalizedString(@"点传", nil)];
    [emailVC setMessageBody:KShareContent isHTML:NO];
    emailVC.block = ^(MFMailComposeViewController *controller,MFMailComposeResult result,NSError *error) {
        if (result == MFMailComposeResultSent) {
            [self showSuccessHUD];
        }
        [controller dismissViewControllerAnimated:YES completion:NULL];
    };
    
    [self presentViewController:emailVC animated:YES completion:NULL];
}

- (void)weiboButtonClick {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        SLComposeViewController *sinaweiboSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        [sinaweiboSheet setInitialText:KShareContent];
        sinaweiboSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        };
        [self presentViewController:sinaweiboSheet animated:YES completion:NULL];
    }
    else
        if ([WeiboSDK isWeiboAppInstalled]) {
        WBMessageObject *object = [WBMessageObject message];
        object.text = KShareContent;
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:object];
        [WeiboSDK sendRequest:request];
    } else {
        [UIAlertController showMessage:NSLocalizedString(@"您还没有安装新浪微博", nil) inViewController:self];
    }
}

- (void)weixinButtonClick {
    if ([WXApi isWXAppInstalled]) {
        WXMediaMessage *mediaMessage = [WXMediaMessage message];
        mediaMessage.description = KShareContent;
//        
//        WXImageObject *imageObject = [WXImageObject object];
//        imageObject.imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"dcshare"], 0.8);
		
//        mediaMessage.mediaObject = imageObject;
		
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
		req.text = KShareContent;
        req.bText = YES;
//        req.message = mediaMessage;
        req.scene = WXSceneSession;
        
        [WXApi sendReq:req];

    } else {
        [UIAlertController showMessage:NSLocalizedString(@"您还没有安装微信", nil) inViewController:self];
    }
}

- (void)qqButtonClick {
    if ([TencentOAuth iphoneQQInstalled]) {
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:KShareContent];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        //将内容分享到qq
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    } else {
        [UIAlertController showMessage:NSLocalizedString(@"您还没有安装QQ", nil) inViewController:self];
    }
    
}

@end
