//
//  STFileSelectionTabViewController.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class PHFetchResult;

@interface STFileSelectionTabViewController : UITabBarController

@property (nonatomic, strong, readonly) NSDictionary *selectedAssetsDic;
@property (nonatomic, strong, readonly) NSArray *selectedAssetsArr;

- (void)addAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults;
- (void)removeAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults;
- (BOOL)isSelectedWithAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults;

@end
