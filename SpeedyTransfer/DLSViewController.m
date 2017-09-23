//
//  DLSViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/9/23.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "DLSViewController.h"
#import "MBProgressHUD.h"
@import AdSupport;
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+HT.h"

@interface DLSViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DLSViewController

- (NSString *)url {
    NSString *url = @"http://139.224.232.144/api/device-portrait";
    
    NSString *appid = @"MRD6FAqoxpAJjpc3";
    NSString *didtype = @"idfa";

    NSString *idfv = @"";
    if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
        idfv = [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
    }
    
    NSString *didvalue = idfv;
    NSString *os = @"ios";
    NSString *appkey = @"R69RMkf1h3u9z8p6";
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@", appkey ,didtype , didvalue] sha256];
    NSString *osver = [UIDevice currentDevice].systemVersion;
    
    return [url stringByAppendingFormat:@"?appid=%@&didtype=%@&didvalue=%@&os=%@&sign=%@&osver=%@", appid, didtype, didvalue, os, sign, osver];
}

- (IBAction)click:(UIButton *)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在分析";
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:[self url] parameters:nil error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary *  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"responseObject: %@", responseObject);

        [MBProgressHUD hideHUDForView:self.view animated:NO];

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (!error && httpResponse.statusCode == 200) {
            int code = [responseObject intForKey:@"code"];
            if (code == 200) {
                _textView.text = @"sfsdfsdf";
                _textView.hidden = NO;
            } else {
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = [responseObject stringForKey:@"msg"];
                HUD.removeFromSuperViewOnHide = YES;
                [self.view addSubview:HUD];
                [HUD show:YES];
                [HUD hide:YES afterDelay:2.f];
            }
        } else {
            NSLog(@"error: %@", error);
        }
        
    }];
    [dataTask resume];
    
    
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
