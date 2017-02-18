//
//  STFileSelectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/18.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STFileSelectionViewController.h"
#import "STFileSegementControl.h"
#import "STPictureCollectionViewController.h"
#import "STMusicSelectionViewController.h"
#import "STVideoSelectionViewController.h"
#import "STContactsSelectionViewController.h"
#import "STFilesViewController.h"

@interface STFileSelectionViewController ()<STFileSegementControlDelegate> {
    STFileSegementControl *segementControl;
    
    NSArray *childViewControllers;
    UIViewController *lastSelectedViewC;
    NSArray *titles;
}

@end

@implementation STFileSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    segementControl = [[STFileSegementControl alloc] init];
    segementControl.delegate = self;
    [self.view addSubview:segementControl];
    
    STPictureCollectionViewController *picVC = [[STPictureCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    STVideoSelectionViewController *videoVC = [[STVideoSelectionViewController alloc] init];
    STContactsSelectionViewController *contactVC = [[STContactsSelectionViewController alloc] init];
    STFilesViewController *fileVC = [[STFilesViewController alloc] init];

    childViewControllers = @[picVC, videoVC, contactVC,fileVC];
    titles = @[@"选择图片", @"选择视频", @"选择联系人", @"选择文件"];
    
    lastSelectedViewC = [childViewControllers firstObject];
    [self addChildViewController:lastSelectedViewC];
    [self.view addSubview:lastSelectedViewC.view];
    [lastSelectedViewC didMoveToParentViewController:self];
    [self autoLayoutChildViewController:lastSelectedViewC];
}

- (void)didTapBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectIndex:(NSInteger)index {
    UIViewController *viewController = [childViewControllers objectAtIndex:index];

    [self addChildViewController:viewController];
    [lastSelectedViewC willMoveToParentViewController:nil];
    [self transitionFromViewController:lastSelectedViewC toViewController:viewController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        [self autoLayoutChildViewController:viewController];
    } completion:^(BOOL finished) {
        [viewController didMoveToParentViewController:self];
        [lastSelectedViewC removeFromParentViewController];
        lastSelectedViewC = viewController;
    }];
    [segementControl setTitle:titles[index]];
}

- (void)autoLayoutChildViewController:(UIViewController *)childViewController {
    [childViewController.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:segementControl withOffset:0.0f];
    [childViewController.view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [childViewController.view autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [childViewController.view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:NSClassFromString(@"STHomeViewController")]) {
        return;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
