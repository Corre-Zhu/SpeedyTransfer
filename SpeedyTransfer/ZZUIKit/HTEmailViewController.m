//
//  HTEmailViewController.m
//  
//
//  Created by zz on 13-5-17.
//
//

#import "HTEmailViewController.h"

@interface HTEmailViewController ()

@end

@implementation HTEmailViewController

- (id)init {
    if (IOS7) {
//        [[UINavigationBar appearance] setTitleTextAttributes:nil];
//        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//        [[UINavigationBar appearance] setTintColor:nil];
//        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    } else {
        UIImage *button = [[UIImage imageNamed:@"nav_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 4, 5, 4)];
        UIImage *buttonPress = [[UIImage imageNamed:@"nav_btn_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 4, 5, 4)];
        [[UIBarButtonItem appearance] setBackgroundImage:button forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:buttonPress forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    }
    
    self = [super init];
    if (self) {
        self.mailComposeDelegate = self;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (IOS7) {
//        UIImage *navBg = [[UIImage imageNamed:@"navBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 4, 0)];
//        [[UINavigationBar appearance] setBackgroundImage:navBg forBarMetrics:UIBarMetricsDefault];
//        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                        [UIColor whiteColor],UITextAttributeTextColor,
//                                        [UIFont boldSystemFontOfSize:17.0f],UITextAttributeFont,nil];
//        [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
//        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    } else {
        [[UIBarButtonItem appearance] setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (self.block) {
        self.block(controller,result,error);
    }
}


@end
