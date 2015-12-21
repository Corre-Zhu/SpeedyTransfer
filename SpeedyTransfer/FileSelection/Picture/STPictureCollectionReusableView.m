//
//  STPictureCollectionReusableView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STPictureCollectionReusableView.h"
#import "STPictureCollectionHeaderModel.h"
#import <Photos/Photos.h>

@interface STPictureCollectionReusableView () {
    UIImageView *placeholdImageView;
    UILabel *titleLabel;
    UILabel *countLabel;
    UIButton *selectAllButton;
    UIView *lineView;
}

@property (nonatomic)CGFloat cellHeight;

@end

@implementation STPictureCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        placeholdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 12.0f, 72.0f, 72.0f)];
        placeholdImageView.layer.cornerRadius = 4.0f;
        placeholdImageView.layer.masksToBounds = YES;
        [self addSubview:placeholdImageView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [self addSubview:titleLabel];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(98.0f, 58.0f, IPHONE_WIDTH - 148.0f, 18.0f)];
        countLabel.font = [UIFont systemFontOfSize:14.0f];
        countLabel.textColor = RGBFromHex(0x929292);
        [self addSubview:countLabel];
        
        selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [selectAllButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateSelected];
        [selectAllButton setTitleColor:RGBFromHex(0xeb694a) forState:UIControlStateNormal];
        [selectAllButton setTitleColor:RGBFromHex(0xeb694a) forState:UIControlStateSelected];
        [selectAllButton addTarget:self action:@selector(selectAllButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:selectAllButton];
        
        _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_expandButton];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 95.5f, IPHONE_WIDTH, 0.5f)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineView];
    }
    
    return self;
}

- (void)reloadData {
    if (!_model.expand) {
        self.backgroundColor = [UIColor whiteColor];
        placeholdImageView.hidden = NO;
        placeholdImageView.image = _model.placeholdImage;
        titleLabel.frame = CGRectMake(98.0f, 22.0f, IPHONE_WIDTH - 148.0f, 20.0f);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = _model.title;
        countLabel.hidden = NO;
        countLabel.text = [NSString stringWithFormat:@"(%@)", @(_model.fetchResult.count).stringValue];
        selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 60.0f, 0.0f, 60.0f, 96.0f);
        _expandButton.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH - 60.0f, 96.0f);
        lineView.hidden = NO;
    } else {
        self.backgroundColor = RGB(240, 240, 240);
        placeholdImageView.hidden = YES;
        titleLabel.frame = CGRectMake(16.0f, 10.0f, IPHONE_WIDTH - 66.0f, 24.0f);
        titleLabel.textColor = RGBFromHex(0x646464);
        titleLabel.text = [NSString stringWithFormat:@"%@ ( %@ )", _model.title, @(_model.fetchResult.count)];
        countLabel.hidden = YES;
        selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 60.0f, 0.0f, 60.0f, 44.0f);
        _expandButton.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH - 60.0f, 44.0f);
        lineView.hidden = YES;
    }
    selectAllButton.selected = _model.selectedAll;
}

- (void)selectAllButtonClick {
    if (!_model.selectedAll) {
        for (PHAsset *asset in _model.fetchResult) {
            [self.tabViewController addAsset:asset];
        }
        _model.selectedAll = YES;
    } else {
        for (PHAsset *asset in _model.fetchResult) {
            [self.tabViewController removeAsset:asset];
        }
        _model.selectedAll = NO;
    }
    
    selectAllButton.selected = _model.selectedAll;
    [self.collectionView reloadData];
}

@end
