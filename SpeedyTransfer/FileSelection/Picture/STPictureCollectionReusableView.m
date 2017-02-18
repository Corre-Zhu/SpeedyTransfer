//
//  STPictureCollectionReusableView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STPictureCollectionReusableView.h"
#import "STPictureCollectionHeaderInfo.h"
#import <Photos/Photos.h>

@interface STPictureCollectionReusableView () {
    UIImageView *placeholdImageView;
    UILabel *titleLabel;
    UILabel *countLabel;
    UIButton *selectAllButton;
}

@end

@implementation STPictureCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, 40)];
    if (self) {
        placeholdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 12.0f, 88.0f, 88.0f)];
        placeholdImageView.layer.cornerRadius = 4.0f;
        placeholdImageView.layer.masksToBounds = YES;
        [self addSubview:placeholdImageView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16.0f];
        titleLabel.textColor = RGBFromHex(0x333333);
        [self addSubview:titleLabel];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(108.0f, placeholdImageView.top + 57, IPHONE_WIDTH - 148.0f, 19.0f)];
        countLabel.font = [UIFont systemFontOfSize:16.0f];
        countLabel.textColor = RGBFromHex(0x333333);
        [self addSubview:countLabel];
        
        selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [selectAllButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateSelected];
        [selectAllButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateNormal];
        [selectAllButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateSelected];
        [selectAllButton addTarget:self action:@selector(selectAllButtonClick) forControlEvents:UIControlEventTouchUpInside];
        selectAllButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:selectAllButton];
        
        _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_expandButton];
    }
    
    return self;
}

- (void)reloadData {
    if (!_model.expand) {
        self.backgroundColor = [UIColor whiteColor];
        placeholdImageView.hidden = NO;
        placeholdImageView.image = _model.placeholdImage;
        titleLabel.frame = CGRectMake(108.0f, placeholdImageView.top + 18.0f, IPHONE_WIDTH - 148.0f, 19.0f);
        titleLabel.text = _model.title;
        countLabel.hidden = NO;
        countLabel.text = [NSString stringWithFormat:@"(%@)", @(_model.fetchResult.count).stringValue];
        selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 60.0f, 0.0f, 60.0f, 108.0f);
        _expandButton.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH - 60.0f, 108.0f);
    } else {
        self.backgroundColor = RGBFromHex(0xf4f4f4);
        placeholdImageView.hidden = YES;
        titleLabel.frame = CGRectMake(16.0f, 10.0f, IPHONE_WIDTH - 66.0f, 19.0f);
        titleLabel.text = [NSString stringWithFormat:@"%@ ( %@ )", _model.title, @(_model.fetchResult.count)];
        countLabel.hidden = YES;
        selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 60.0f, 0.0f, 60.0f, 40.0f);
        _expandButton.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH - 60.0f, 40.0f);
    }
    selectAllButton.selected = _model.selectedAll;
}

- (void)selectAllButtonClick {
    if (!_model.selectedAll) {
        [self.tabViewController removeAllAssetsInCollection:self.model.localIdentifier];
        [self.tabViewController addAssets:[_model.fetchResult objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _model.fetchResult.count)]] inCollection:self.model.localIdentifier];
        _model.selectedAll = YES;
    } else {
        [self.tabViewController removeAssets:[_model.fetchResult objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _model.fetchResult.count)]] inCollection:self.model.localIdentifier];
        _model.selectedAll = NO;
    }
    
    selectAllButton.selected = _model.selectedAll;
    [self.collectionView reloadData];
}

@end
