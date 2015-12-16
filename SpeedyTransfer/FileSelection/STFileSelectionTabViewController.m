//
//  STFileSelectionTabViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileSelectionTabViewController.h"
#import <Photos/Photos.h>

@interface STFileSelectionTabViewController ()
{
    UIImageView *toolView;
    UIButton *deleteButton;
    UIButton *transferButton;
}

@end

@implementation STFileSelectionTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemClick)];
    self.navigationItem.title = NSLocalizedString(@"选择文件", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    toolView = [[UIImageView alloc] initWithFrame:CGRectMake((IPHONE_WIDTH - 175.0f) / 2.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 92.0f, 175.0f, 40.0f)];
    toolView.image = [[UIImage imageNamed:@"xuanze_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0f, 7.0f, 7.0f, 7.0f)];
    toolView.userInteractionEnabled = YES;
    [self.view addSubview:toolView];
    toolView.hidden = YES;
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(9.0f, 2.0f, 35.0f, 35.0f);
    [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:deleteButton];
    
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(53.0f, 12.0f, 0.5f, 17.0f)];
    lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    [toolView addSubview:lineView];
    
    transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
    transferButton.frame = CGRectMake(73.0f, 3.0f, 82.0f, 34.0f);
    [transferButton setTitle:NSLocalizedString(@"全部传输", nil) forState:UIControlStateNormal];
    [transferButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [transferButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    transferButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [toolView addSubview:transferButton];
}

- (void)configToolView {
    NSInteger count = [self selectedAssetsCount];
    if (count > 0) {
        [transferButton setTitle:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"全部传输", nil), @(count)] forState:UIControlStateNormal];
        toolView.hidden = NO;
    } else {
        [transferButton setTitle:NSLocalizedString(@"全部传输", nil) forState:UIControlStateNormal];
        toolView.hidden = YES;
    }
    
    [transferButton sizeToFit];
    CGFloat width = MAX(82.0f, transferButton.width);
    toolView.width = 93.0f + width;
    toolView.left = (IPHONE_WIDTH - toolView.width) / 2.0f;
    transferButton.width = width;
}

- (void)backBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonClick {
    
}

- (NSUInteger)selectedAssetsCount {
    NSUInteger count = 0;
    for (NSArray *arr in self.selectedAssetsDic.allValues) {
        count += arr.count;
    }
    
    return count;
}

- (NSArray *)selectedAssetsArr {
    NSMutableArray *mutableArr = [NSMutableArray array];
    for (NSArray *arr in self.selectedAssetsDic.allValues) {
        [mutableArr addObjectsFromArray:arr];
    }
    
    return [NSArray arrayWithArray:mutableArr];
}

- (void)addAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults {
    if (!asset || !fetchResults) {
        return;
    }
    
    if (!_selectedAssetsDic) {
        _selectedAssetsDic = [NSDictionary dictionary];
    }
    
    @autoreleasepool {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:_selectedAssetsDic];
        NSArray *tempArray = [tempDic objectForKey:fetchResults];
        if (tempArray) {
            if (![tempArray containsObject:asset]) {
                [tempDic setObject:[tempArray arrayByAddingObject:asset] forKey:fetchResults];
            }
        } else {
            [tempDic setObject:[NSArray arrayWithObject:asset] forKey:fetchResults];
        }
        _selectedAssetsDic = [NSDictionary dictionaryWithDictionary:tempDic];
    }
    
    [self configToolView];
}

- (void)removeAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults {
    if (!asset || !fetchResults) {
        return;
    }
    
    if (_selectedAssetsDic) {
        @autoreleasepool {
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:_selectedAssetsDic];
            NSArray *tempArray = [tempDic objectForKey:fetchResults];
            if (tempArray) {
                NSMutableArray *tempMutableArray = [NSMutableArray arrayWithArray:tempArray];
                [tempMutableArray removeObject:asset];
                [tempDic setObject:[NSArray arrayWithArray:tempMutableArray] forKey:fetchResults];
                _selectedAssetsDic = [NSDictionary dictionaryWithDictionary:tempDic];
            }
        }
    }
    
    [self configToolView];
}

- (BOOL)isSelectedWithAsset:(PHAsset *)asset inFetchResults:(PHFetchResult *)fetchResults {
    if (!asset || !fetchResults) {
        return NO;
    }
    
    NSArray *arr = [_selectedAssetsDic objectForKey:fetchResults];
    return [arr containsObject:asset];
}

@end
