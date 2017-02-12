//
//  STWalkThroughView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/12.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STWalkThroughView.h"

@interface STWalkThroughView ()

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageControl;

@end

@implementation STWalkThroughView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.scrollView.bounces = NO;
        self.scrollView.contentSize = CGSizeMake(IPHONE_WIDTH * 2, IPHONE_HEIGHT);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        
        [self addSubview:self.scrollView];
        [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self addImageViews];
       
    }
    
    return self;
}

- (void)addImageViews {
    UIImageView * img1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT)];
    img1.image = [UIImage imageNamed:@"bg_img0001"];
    [self.scrollView addSubview:img1];
    
    UIImageView * img2 = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH, 0, IPHONE_WIDTH, IPHONE_HEIGHT)];
    img2.image = [UIImage imageNamed:@"bg_img0002"];
    [self.scrollView addSubview:img2];
    img2.userInteractionEnabled = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    button.layer.cornerRadius = 5.0f;
    [button setTitle:NSLocalizedString(@"立即体验", nil) forState:UIControlStateNormal];
    [button setTitleColor:RGBFromHex(0xe48b17) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [img2 addSubview:button];
    
    [button autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [button autoSetDimensionsToSize:CGSizeMake(105.0f, 28.0f)];
    [button autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:36.0f];
}

- (void)btnClick {
    [self removeFromSuperview];
}

@end
