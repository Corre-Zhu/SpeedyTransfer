//
//  STPictureCollectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STPictureCollectionViewController.h"
#import "STPictureCollectionReusableView.h"
#import "STPictureCollectionHeaderModel.h"
#import "HZAssetCollectionViewCell.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"

#define KItemPadding 5.0f
#define ASSET_PER_ROW 4

static NSString *collectionReusableViewIdenfifier = @"CollectionReusableViewIdenfifier";
static NSString * const CollectionViewCellReuseIdentifier = @"CollectionViewCellReuseIdentifier";

@interface STPictureCollectionViewController ()<PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong) PHFetchResult *topLevelCollections;
@property (strong) PHFetchResult *smartCollections;
@property (strong) PHFetchResult *photoStreamsCollections;
@property (strong) PHFetchResult *iCloudShareCollections;
@property (nonatomic, strong) NSArray *smartCollectionSubtypes;

@property (strong) NSArray *fetchResultsArray;
@property (strong) NSArray *fetchResultsTitles;

@property (nonatomic,strong) NSMutableArray *cachedHeaderModels;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation STPictureCollectionViewController

- (NSArray *)smartCollectionSubtypes {
    if (!_smartCollectionSubtypes) {
        _smartCollectionSubtypes = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                     @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                     @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
                                     @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                     @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                     @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                     @(PHAssetCollectionSubtypeSmartAlbumSelfPortraits),
                                     @(PHAssetCollectionSubtypeSmartAlbumScreenshots)];
    }
    
    return _smartCollectionSubtypes;
}

- (void)setupFetchResults {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    _topLevelCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    _smartCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    _photoStreamsCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    _iCloudShareCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    
    NSMutableArray *tempFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempFetchResultTitles = [[NSMutableArray alloc] init];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    // Smart collections
    for(PHCollection *collection in _smartCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            if ([self.smartCollectionSubtypes containsObject:@(assetCollection.assetCollectionSubtype)]) {
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if(assetsFetchResult.count>0) {
                    if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                        [tempFetchResultArray insertObject:assetsFetchResult atIndex:0];
                        [tempFetchResultTitles insertObject:collection.localizedTitle atIndex:0];
                    } else {
                        [tempFetchResultArray addObject:assetsFetchResult];
                        [tempFetchResultTitles addObject:collection.localizedTitle];
                    }
                }
            }
        }
    }
    
    // PhotoStreams
    for(PHCollection *collection in _photoStreamsCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if(assetsFetchResult.count > 0) {
                if (tempFetchResultArray.count > 0) {
                    [tempFetchResultArray insertObject:assetsFetchResult atIndex:1];
                    [tempFetchResultTitles insertObject:collection.localizedTitle atIndex:1];
                } else {
                    [tempFetchResultArray insertObject:assetsFetchResult atIndex:0];
                    [tempFetchResultTitles insertObject:collection.localizedTitle atIndex:0];
                }
            }
        }
    }
    
    // User Created Albums
    for(PHCollection *collection in _topLevelCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if (assetsFetchResult.count > 0) {
                [tempFetchResultArray addObject:assetsFetchResult];
                [tempFetchResultTitles addObject:collection.localizedTitle];
            }
        }
    }
    
    // iCloud Share Albums
    for(PHCollection *collection in _iCloudShareCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if(assetsFetchResult.count>0) {
                [tempFetchResultArray addObject:assetsFetchResult];
                [tempFetchResultTitles addObject:collection.localizedTitle];
            }
        }
    }
    
    self.fetchResultsArray = [NSArray arrayWithArray:tempFetchResultArray];
    self.fetchResultsTitles = [NSArray arrayWithArray:tempFetchResultTitles];
}

- (void)setupHeaderModel {
    if (!_cachedHeaderModels) {
        _cachedHeaderModels = [NSMutableArray array];
    }
    
    for (PHFetchResult *result in self.fetchResultsArray) {
        NSInteger index = [self.fetchResultsArray indexOfObject:result];
        
        STPictureCollectionHeaderModel *headerModel = [[STPictureCollectionHeaderModel alloc] init];
        headerModel.fetchResult = result;
        if (index == 0) {
            headerModel.isCameraRoll = YES;
            headerModel.expand = YES;
        }
        headerModel.title = [self.fetchResultsTitles objectAtIndex:index];

        NSInteger currentTag = headerModel.tag + 1;
        headerModel.tag = currentTag;
        
        PHAsset *asset = result.lastObject;
        if (result.count > 0) {
            NSInteger scale = [UIScreen mainScreen].scale;
            CGSize size = CGSizeMake(72 * scale, 72 * scale);
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            [self.imageManager requestImageForAsset:asset
                                                       targetSize:size
                                                      contentMode:PHImageContentModeAspectFill options:options
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        if (headerModel.tag == currentTag) {
                                                            headerModel.placeholdImage = result;
                                                        }
                                                    }];
        }
        
        [_cachedHeaderModels addObject:headerModel];
    }
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout {
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = KItemPadding;
    layout.minimumInteritemSpacing = KItemPadding;
    CGFloat width = (IPHONE_WIDTH - (ASSET_PER_ROW + 1) * KItemPadding) / (float)ASSET_PER_ROW;
    CGFloat height = 100.0f / 88.0f * width;
    layout.itemSize = CGSizeMake(width, height);
    layout.sectionInset = UIEdgeInsetsMake(0.0f, KItemPadding, KItemPadding, KItemPadding);
    self = [super initWithCollectionViewLayout:layout];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageManager = [[PHCachingImageManager alloc] init];
    [self setupFetchResults];
    [self setupHeaderModel];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    [self.collectionView registerClass:[STPictureCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionReusableViewIdenfifier];
    [self.collectionView registerClass:[HZAssetCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellReuseIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)expandButtonClick:(UIButton *)sender {
    if (_cachedHeaderModels.count > sender.tag) {
        STPictureCollectionHeaderModel *model = [_cachedHeaderModels objectAtIndex:sender.tag];
        model.expand = !model.expand;
        [self.collectionView reloadData];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.cachedHeaderModels.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    STPictureCollectionHeaderModel *model = [self.cachedHeaderModels objectAtIndex:section];
    if (model.expand) {
        return model.fetchResult.count + (model.isCameraRoll ? 1 : 0);
    }

    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger item = indexPath.item;
    STPictureCollectionHeaderModel *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

    HZAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellReuseIdentifier forIndexPath:indexPath];
    cell.isCameraRoll = NO;
    if (model.isCameraRoll) {
        if (item == 0) {
            cell.thumbnailImage = [UIImage imageNamed:@"相机"];
            cell.isCameraRoll = YES;
            [cell setup];
            return cell;
        } else {
            item -= 1;
        }
    }
    
    PHAsset *asset = model.fetchResult[item];
    
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).itemSize;
    CGSize size = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
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
    
    if ([self.fileSelectionTabController isSelectedWithAsset:asset inFetchResults:model.fetchResult]) {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        cell.selected = NO;
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader)
    {
        STPictureCollectionReusableView *headerView = (STPictureCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionReusableViewIdenfifier forIndexPath:indexPath];
        headerView.tabViewController = (STFileSelectionTabViewController *)self.tabBarController;
        headerView.collectionView = self.collectionView;
        if (![headerView.expandButton.allTargets containsObject:self]) {
            [headerView.expandButton addTarget:self action:@selector(expandButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        headerView.expandButton.tag = indexPath.section;
        headerView.model = [self.cachedHeaderModels objectAtIndex:indexPath.section];
        [headerView reloadData];
        return headerView;
    }
    
    return nil;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    STPictureCollectionHeaderModel *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

    if (model.isCameraRoll && indexPath.item == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }
        return NO;
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    STPictureCollectionHeaderModel *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

    if (model.isCameraRoll) {
        item -= 1;
    }
    
    PHAsset *asset = model.fetchResult[item];
    [self.fileSelectionTabController addAsset:asset inFetchResults:model.fetchResult];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    STPictureCollectionHeaderModel *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

    if (model.isCameraRoll) {
        item -= 1;
    }
    
    PHAsset *asset = model.fetchResult[item];
    [self.fileSelectionTabController removeAsset:asset inFetchResults:model.fetchResult];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    STPictureCollectionHeaderModel *model = [self.cachedHeaderModels objectAtIndex:section];
    return CGSizeMake(IPHONE_WIDTH, model.height);
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
}

@end
