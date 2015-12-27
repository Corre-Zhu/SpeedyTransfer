//
//  STPictureCollectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STPictureCollectionViewController.h"
#import "STPictureCollectionReusableView.h"
#import "STPictureCollectionHeaderInfo.h"
#import "HZAssetCollectionViewCell.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"

#define KItemPadding 5.0f
#define ASSET_PER_ROW 4

static NSString *collectionReusableViewIdenfifier = @"CollectionReusableViewIdenfifier";
static NSString * const CollectionViewCellReuseIdentifier = @"CollectionViewCellReuseIdentifier";

@interface STPictureCollectionViewController ()<PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    BOOL inserting; //
}

@property (strong) PHFetchResult *smartCollections;
@property (strong) NSMutableArray *smartFetchResults;
@property (strong) NSMutableArray *smartFetchTitles;

@property (strong) PHFetchResult *topLevelCollections;
@property (strong) NSMutableArray *topLevelFetchResults;
@property (strong) NSMutableArray *topLevelFetchTitles;

@property (strong) PHFetchResult *photoStreamsCollections;
@property (strong) NSMutableArray *photoStreamsFetchResults;
@property (strong) NSMutableArray *photoStreamsFetchTitles;

@property (strong) PHFetchResult *iCloudShareCollections;
@property (strong) NSMutableArray *iCloudShareFetchResults;
@property (strong) NSMutableArray *iCloudShareFetchTitles;

@property (nonatomic, strong) NSArray *smartCollectionSubtypes;
@property (nonatomic, strong) PHFetchOptions *fetchOptions;

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

- (PHFetchOptions *)fetchOptions {
    if (!_fetchOptions) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        _fetchOptions = options;
    }
    
    return _fetchOptions;
}

- (void)setupSmartCollections {
    if (!_smartCollections) {
        _smartCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        _smartFetchResults = [NSMutableArray array];
        _smartFetchTitles = [NSMutableArray array];
    }
    
    [_smartFetchResults removeAllObjects];
    [_smartFetchTitles removeAllObjects];
   
    // Smart collections
    for(PHCollection *collection in _smartCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            if ([self.smartCollectionSubtypes containsObject:@(assetCollection.assetCollectionSubtype)]) {
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
                if(assetsFetchResult.count>0) {
                    if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                        [_smartFetchResults insertObject:assetsFetchResult atIndex:0];
                        [_smartFetchTitles insertObject:collection.localizedTitle atIndex:0];
                    } else {
                        [_smartFetchResults addObject:assetsFetchResult];
                        [_smartFetchTitles addObject:collection.localizedTitle];
                    }
                }
            }
        }
    }
}

- (void)setupPhotoStreamsCollections {
    if (!_photoStreamsCollections) {
        _photoStreamsCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        _photoStreamsFetchResults = [NSMutableArray array];
        _photoStreamsFetchTitles = [NSMutableArray array];
    }
    
    [_photoStreamsFetchResults removeAllObjects];
    [_photoStreamsFetchTitles removeAllObjects];
    
    // PhotoStreams
    for(PHCollection *collection in _photoStreamsCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
            if(assetsFetchResult.count > 0) {
                [_photoStreamsFetchResults addObject:assetsFetchResult];
                [_photoStreamsFetchTitles addObject:collection.localizedTitle];
            }
        }
    }
}

- (void)setupTopLevelCollections {
    if (!_topLevelCollections) {
        _topLevelCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        _topLevelFetchResults = [NSMutableArray array];
        _topLevelFetchTitles = [NSMutableArray array];
    }
    
    [_topLevelFetchResults removeAllObjects];
    [_topLevelFetchTitles removeAllObjects];
    
    // User Created Albums
    for(PHCollection *collection in _topLevelCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
            if (assetsFetchResult.count > 0) {
                [_topLevelFetchResults addObject:assetsFetchResult];
                [_topLevelFetchTitles addObject:collection.localizedTitle];
            }
        }
    }
}

- (void)setupiCloudShareCollections {
    if (!_iCloudShareCollections) {
        _iCloudShareCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        _iCloudShareFetchResults = [NSMutableArray array];
        _iCloudShareFetchTitles = [NSMutableArray array];
    }
    
    [_iCloudShareFetchResults removeAllObjects];
    [_iCloudShareFetchTitles removeAllObjects];
    
    // iCloud Share Albums
    for(PHCollection *collection in _iCloudShareCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
            if(assetsFetchResult.count>0) {
                [_iCloudShareFetchResults addObject:assetsFetchResult];
                [_iCloudShareFetchTitles addObject:collection.localizedTitle];
            }
        }
    }
}

- (void)setupFetchResults {
    @autoreleasepool {
        NSMutableArray *tempArr = [NSMutableArray array];
        NSMutableArray *tempArr2 = [NSMutableArray array];
        [tempArr addObjectsFromArray:_smartFetchResults];
        [tempArr2 addObjectsFromArray:_smartFetchTitles];
        if (_photoStreamsFetchResults.count > 0) {
            if (tempArr.count > 0) {
                [tempArr insertObject:_photoStreamsFetchResults.firstObject atIndex:1];
                [tempArr2 insertObject:_photoStreamsFetchTitles.firstObject atIndex:1];
            } else {
                [tempArr addObject:_photoStreamsFetchResults.firstObject];
                [tempArr2 addObject:_photoStreamsFetchTitles.firstObject];
            }
        }
        [tempArr addObjectsFromArray:_topLevelFetchResults];
        [tempArr2 addObjectsFromArray:_topLevelFetchTitles];
        [tempArr addObjectsFromArray:_iCloudShareFetchResults];
        [tempArr2 addObjectsFromArray:_iCloudShareFetchTitles];
        
        self.fetchResultsArray = [NSArray arrayWithArray:tempArr];
        self.fetchResultsTitles = [NSArray arrayWithArray:tempArr2];
    }
}

- (void)setupHeaderModel {
    if (!_cachedHeaderModels) {
        _cachedHeaderModels = [NSMutableArray array];
    }
    
    [_cachedHeaderModels removeAllObjects];
    
    for (PHFetchResult *result in self.fetchResultsArray) {
        NSInteger index = [self.fetchResultsArray indexOfObject:result];
        
        STPictureCollectionHeaderInfo *headerModel = [[STPictureCollectionHeaderInfo alloc] init];
        headerModel.fetchResult = result;
        if (index == 0) {
            headerModel.isCameraRoll = YES;
            headerModel.expand = YES;
        }
        headerModel.title = [self.fetchResultsTitles objectAtIndex:index];

        NSInteger currentTag = headerModel.tag + 1;
        headerModel.tag = currentTag;
        
        PHAsset *asset = result.firstObject;
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

- (void)dealloc {
    inserting = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    _imageManager = [[PHCachingImageManager alloc] init];
    [self setupSmartCollections];
    [self setupPhotoStreamsCollections];
    [self setupTopLevelCollections];
    [self setupiCloudShareCollections];
    [self setupFetchResults];
    [self setupHeaderModel];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    [self.collectionView registerClass:[STPictureCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionReusableViewIdenfifier];
    [self.collectionView registerClass:[HZAssetCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellReuseIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)expandButtonClick:(UIButton *)sender {
    if (_cachedHeaderModels.count > sender.tag) {
        STPictureCollectionHeaderInfo *model = [_cachedHeaderModels objectAtIndex:sender.tag];
        model.expand = !model.expand;
        [self.collectionView reloadData];
    }
}

- (void)didEnterBackgroundNotification:(NSNotification *)notification {
    inserting = NO;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info: %@", info);
    [self dismissViewControllerAnimated:YES completion:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }];
    inserting = YES;
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        inserting = NO;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.cachedHeaderModels.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    STPictureCollectionHeaderInfo *model = [self.cachedHeaderModels objectAtIndex:section];
    if (model.expand) {
        return model.fetchResult.count + (model.isCameraRoll ? 1 : 0);
    }

    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger item = indexPath.item;
    STPictureCollectionHeaderInfo *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

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
    
    if ([self.fileSelectionTabController isSelectedWithAsset:asset]) {
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
    STPictureCollectionHeaderInfo *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

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
    STPictureCollectionHeaderInfo *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

    if (model.isCameraRoll) {
        item -= 1;
    }
    
    PHAsset *asset = model.fetchResult[item];
    [self.fileSelectionTabController addAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    STPictureCollectionHeaderInfo *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

    if (model.isCameraRoll) {
        item -= 1;
    }
    
    PHAsset *asset = model.fetchResult[item];
    [self.fileSelectionTabController removeAsset:asset];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    STPictureCollectionHeaderInfo *model = [self.cachedHeaderModels objectAtIndex:section];
    return CGSizeMake(IPHONE_WIDTH, model.height);
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL reloadRequired = NO;
        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:_smartCollections];
        if (changeDetails != nil) {
            _smartCollections = [changeDetails fetchResultAfterChanges];
            [self setupSmartCollections];
            reloadRequired = YES;
        }
        
        changeDetails = [changeInstance changeDetailsForFetchResult:_photoStreamsCollections];
        if (changeDetails != nil) {
            _photoStreamsCollections = [changeDetails fetchResultAfterChanges];
            [self setupPhotoStreamsCollections];
            reloadRequired = YES;
        }
        
        changeDetails = [changeInstance changeDetailsForFetchResult:_topLevelCollections];
        if (changeDetails != nil) {
            _topLevelCollections = [changeDetails fetchResultAfterChanges];
            [self setupTopLevelCollections];
            reloadRequired = YES;
        }
        
        changeDetails = [changeInstance changeDetailsForFetchResult:_iCloudShareCollections];
        if (changeDetails != nil) {
            _iCloudShareCollections = [changeDetails fetchResultAfterChanges];
            [self setupiCloudShareCollections];
            reloadRequired = YES;
        }
     
        if (reloadRequired) {
            [self setupFetchResults];
        }
        
        NSMutableArray *updatedFetchResultsArray = [self.fetchResultsArray mutableCopy];
        
        __block BOOL reloadRequired2 = NO;
        [self.fetchResultsArray enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (collectionChanges != nil) {
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                        PHAsset *asset = collectionsFetchResult[idx];
                        [self.fileSelectionTabController removeAsset:asset];
                    }];
                }
                
                PHFetchResult *newFetchResult = [collectionChanges fetchResultAfterChanges];
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] == 1 && index == 0 && inserting) {
                    PHAsset *newAsset = [newFetchResult objectAtIndex:insertedIndexes.firstIndex];
                    [self.fileSelectionTabController addAsset:newAsset];
                }
                inserting = NO;
                [updatedFetchResultsArray replaceObjectAtIndex:index withObject:[collectionChanges fetchResultAfterChanges]];
                reloadRequired2 = YES;
            }
            
        }];
        
        if (reloadRequired2) {
            self.fetchResultsArray = [NSArray arrayWithArray:updatedFetchResultsArray];
        }
        
        if (reloadRequired || reloadRequired2) {
            [self setupHeaderModel];
            [self.collectionView reloadData];
        }
    });
}

@end
