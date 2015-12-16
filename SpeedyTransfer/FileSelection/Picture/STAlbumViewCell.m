//
//  STAlbumViewCell.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STAlbumViewCell.h"
#import "HZAssetCollectionViewCell.h"
#import "STFileSelectionTabViewController.h"
#import <Photos/Photos.h>

#define KItemPadding 5.0f
#define ASSET_PER_ROW 4

static NSString * const CollectionViewCellReuseIdentifier = @"CollectionViewCellReuseIdentifier";

@interface STAlbumViewCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIView *titleView;
    UIImageView *placeholdImageView;
    UILabel *titleLabel;
    UILabel *countLabel;
    UIButton *selectAllButton;
    
    UIView *contentView;
}

@property (nonatomic)CGFloat cellHeight;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic) CGSize itemSize;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation STAlbumViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        titleView = [[UIView alloc] init];
        [self.contentView addSubview:titleView];
        
        placeholdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 12.0f, 72.0f, 72.0f)];
        placeholdImageView.layer.cornerRadius = 4.0f;
        placeholdImageView.layer.masksToBounds = YES;
        [titleView addSubview:placeholdImageView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [titleView addSubview:titleLabel];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(98.0f, 58.0f, IPHONE_WIDTH - 148.0f, 18.0f)];
        countLabel.font = [UIFont systemFontOfSize:14.0f];
        countLabel.textColor = RGBFromHex(0x929292);
        [titleView addSubview:countLabel];

        selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [selectAllButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateSelected];
        [selectAllButton setTitleColor:RGBFromHex(0xeb694a) forState:UIControlStateNormal];
        [selectAllButton setTitleColor:RGBFromHex(0xeb694a) forState:UIControlStateSelected];
        [selectAllButton addTarget:self action:@selector(selectAllButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:selectAllButton];
        
        [self setExpand:NO];
    }
    
    return self;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = KItemPadding;
        layout.minimumInteritemSpacing = KItemPadding;
        CGFloat width = (IPHONE_WIDTH - (ASSET_PER_ROW + 1) * KItemPadding) / (float)ASSET_PER_ROW;
        CGFloat height = 100.0f / 88.0f * width;
        _itemSize = CGSizeMake(width, height);
        layout.itemSize = _itemSize;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, IPHONE_WIDTH, 0.0f) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.contentInset = UIEdgeInsetsMake(0.0f, KItemPadding, KItemPadding, KItemPadding);
        [_collectionView registerClass:[HZAssetCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellReuseIdentifier];
        [self.contentView addSubview:_collectionView];
        
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    
    return _collectionView;
}

- (void)setExpand:(BOOL)expand {
    _expand = expand;
    if (!_expand) {
        titleView.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 96.0f);
        titleView.backgroundColor = [UIColor whiteColor];
        placeholdImageView.hidden = NO;
        titleLabel.frame = CGRectMake(98.0f, 22.0f, IPHONE_WIDTH - 148.0f, 20.0f);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = self.title;
        countLabel.hidden = NO;
        countLabel.text = [NSString stringWithFormat:@"(%@)", @(_fetchResult.count).stringValue];
        selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 60.0f, 0.0f, 60.0f, 96.0f);
        self.collectionView.hidden = YES;
        [self.tableView reloadData];
    } else {
        titleView.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 44.0f);
        titleView.backgroundColor = RGB(240, 240, 240);
        placeholdImageView.hidden = YES;
        titleLabel.frame = CGRectMake(16.0f, 10.0f, IPHONE_WIDTH - 66.0f, 24.0f);
        titleLabel.textColor = RGBFromHex(0x646464);
        titleLabel.text = [NSString stringWithFormat:@"%@ ( %@ )", _title, @(_fetchResult.count)];
        countLabel.hidden = YES;
        selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 60.0f, 0.0f, 60.0f, 44.0f);
        self.collectionView.hidden = NO;
        [self.collectionView reloadData];
        [self.tableView reloadData];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self setExpand:_expand];
}

- (void)setPlaceholdImage:(UIImage *)placeholdImage {
    _placeholdImage = placeholdImage;
    placeholdImageView.image = _placeholdImage;
}

- (void)selectAllButtonClick {
    if (!selectAllButton.selected) {
        for (PHAsset *asset in self.fetchResult) {
            [self.tabViewController addAsset:asset inFetchResults:_fetchResult];
        }
    } else {
        for (PHAsset *asset in self.fetchResult) {
            [self.tabViewController removeAsset:asset inFetchResults:_fetchResult];
        }
    }
    
    selectAllButton.selected = !selectAllButton.selected;
    [self.collectionView reloadData];
}

- (CGFloat)cellHeight {
    if (!_expand) {
        _cellHeight = 96.0f;
    } else {
        NSInteger rows = ceilf(self.fetchResult.count / 4.0f);
        CGFloat collectionViewHeight = rows * (_itemSize.height + KItemPadding);
        _collectionView.height = collectionViewHeight;

        _cellHeight = 44.0f + collectionViewHeight;
    }
    
    return _cellHeight;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count + (_isCameraRoll ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    
    HZAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellReuseIdentifier forIndexPath:indexPath];
    if (_isCameraRoll) {
        if (item == 0) {
            cell.thumbnailImage = [UIImage imageNamed:@"相机"];
            [cell setup];
            return cell;
        } else {
            item -= 1;
        }
    }
    
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    CGSize size = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    PHAsset *asset = self.fetchResult[item];
    [self.imageManager requestImageForAsset:asset
                                 targetSize:size
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  if (cell.tag == currentTag) {
                                      cell.thumbnailImage = result;
                                      [cell setup];
                                  }
                              }];
    
    if ([self.tabViewController isSelectedWithAsset:asset inFetchResults:_fetchResult]) {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        cell.selected = NO;
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isCameraRoll && indexPath.item == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self.tabViewController presentViewController:imagePicker animated:YES completion:NULL];
        }
        return NO;
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    if (_isCameraRoll) {
        item -= 1;
    }

    PHAsset *asset = self.fetchResult[item];
    [self.tabViewController addAsset:asset inFetchResults:_fetchResult];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    if (_isCameraRoll) {
        item -= 1;
    }
    
    PHAsset *asset = self.fetchResult[item];
    [self.tabViewController removeAsset:asset inFetchResults:_fetchResult];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
}

@end
