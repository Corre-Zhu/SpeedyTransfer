//
//  STFindViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STFindViewController.h"

@interface STFindViewController ()<UIWebViewDelegate>
{
	UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation STFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"发现", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    
    _webView = [[UIWebView alloc] init];
	_webView.backgroundColor = [UIColor whiteColor];
	_webView.delegate = self;
    [self.view addSubview:_webView];
    [_webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
	
	NSString *urlString = [NSString stringWithFormat:@"http://www.3tkj.cn/jurl/j.php?id=%@", [[UIDevice currentDevice] openUDID]];
	NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
	
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activityIndicatorView startAnimating];
	[self.view addSubview:activityIndicatorView];
	[activityIndicatorView autoCenterInSuperview];
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[activityIndicatorView stopAnimating];
}

@end
