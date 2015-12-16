//
//  HZAssetCollectionViewCell.h
//  AssetsPickerViewController
//
//  Created by zhuzhi on 15/8/19.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface HZAssetCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;

- (void)setup;

@end
