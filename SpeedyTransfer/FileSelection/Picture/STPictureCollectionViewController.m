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
#import "STNoFileAlertView.h"

#define KItemPadding 5.0f
#define ASSET_PER_ROW 4

static NSString *collectionReusableViewIdenfifier = @"CollectionReusableViewIdenfifier";
static NSString * const CollectionViewCellReuseIdentifier = @"CollectionViewCellReuseIdentifier";

@interface STPictureCollectionViewController ()<PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    STNoFileAlertView *alertView;

}

@property (strong) PHFetchResult *smartCollections;
@property (strong) NSMutableArray *smartFetchResults;
@property (strong) NSMutableArray *smartFetchTitles;
@property (strong) NSMutableArray *smartIdentifiers;

@property (strong) PHFetchResult *albumCollections;
@property (strong) NSMutableArray *albumFetchResults;
@property (strong) NSMutableArray *albumFetchTitles;
@property (strong) NSMutableArray *albumIdentifiers;

@property (strong) PHFetchResult *photoStreamResult;
@property (strong) NSString *photoStreamTitle;
@property (strong) NSString *photoStreamIdentifier;

@property (nonatomic, strong) NSArray *smartCollectionSubtypes;
@property (nonatomic, strong) PHFetchOptions *fetchOptions;

@property (strong) NSArray *fetchResultsArray;
@property (strong) NSArray *fetchResultsTitles;
@property (strong) NSArray *fetchResultsIdentifiers;

@property (nonatomic,strong) NSMutableArray *cachedHeaderModels;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation STPictureCollectionViewController

- (NSArray *)smartCollectionSubtypes {
    if (!_smartCollectionSubtypes) {
        _smartCollectionSubtypes = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                     @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                     @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                     @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
                                     @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
                                     @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                     @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                     @(PHAssetCollectionSubtypeSmartAlbumUserLibrary)
#ifdef __IPHONE_9_0
                                     ,@(PHAssetCollectionSubtypeSmartAlbumSelfPortraits)
                                     ,@(PHAssetCollectionSubtypeSmartAlbumScreenshots)
#endif
                                     ];
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
        _smartIdentifiers = [NSMutableArray array];
    }
    
    [_smartFetchResults removeAllObjects];
    [_smartFetchTitles removeAllObjects];
    [_smartIdentifiers removeAllObjects];
   
    // Smart collections
    for(PHCollection *collection in _smartCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            if ([self.smartCollectionSubtypes containsObject:@(assetCollection.assetCollectionSubtype)]) {
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
                
                if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                    [_smartFetchResults insertObject:assetsFetchResult atIndex:0];
                    [_smartFetchTitles insertObject:collection.localizedTitle atIndex:0];
                    [_smartIdentifiers insertObject:assetCollection.localIdentifier atIndex:0];
                } else {
                    if(assetsFetchResult.count>0) {
                        [_smartFetchResults addObject:assetsFetchResult];
                        [_smartFetchTitles addObject:collection.localizedTitle];
                        [_smartIdentifiers addObject:assetCollection.localIdentifier];
                    }
                }
            }
        }
    }
}

- (void)setupAlbumCollections {
    if (!_albumCollections) {
        _albumCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        _albumFetchResults = [NSMutableArray array];
        _albumFetchTitles = [NSMutableArray array];
        _albumIdentifiers = [NSMutableArray array];
    }
    
    [_albumFetchResults removeAllObjects];
    [_albumFetchTitles removeAllObjects];
    [_albumIdentifiers removeAllObjects];
    
    _photoStreamResult = nil;
    _photoStreamTitle = nil;
    _photoStreamIdentifier = nil;
    
    // User Created Albums
    for(PHCollection *collection in _albumCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            NSLog(@"%@", assetCollection.localIdentifier);
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
            if(assetsFetchResult.count > 0) {
                if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumMyPhotoStream) {
                    _photoStreamResult = assetsFetchResult;
                    _photoStreamTitle = collection.localizedTitle;
                    _photoStreamIdentifier = collection.localIdentifier;
                }
                
                [_albumFetchResults addObject:assetsFetchResult];
                [_albumFetchTitles addObject:collection.localizedTitle];
                [_albumIdentifiers addObject:collection.localIdentifier];
            }
        }
    }
}

- (void)setupFetchResults {
    @autoreleasepool {
        NSMutableArray *tempArr = [NSMutableArray array];
        NSMutableArray *tempArr2 = [NSMutableArray array];
        NSMutableArray *tempArr3 = [NSMutableArray array];
        [tempArr addObjectsFromArray:_smartFetchResults];
        [tempArr2 addObjectsFromArray:_smartFetchTitles];
        [tempArr3 addObjectsFromArray:_smartIdentifiers];
        [tempArr addObjectsFromArray:_albumFetchResults];
        [tempArr2 addObjectsFromArray:_albumFetchTitles];
        [tempArr3 addObjectsFromArray:_albumIdentifiers];
        
        if (_photoStreamResult && _photoStreamTitle && _photoStreamIdentifier) {
            [tempArr removeObject:_photoStreamResult];
            [tempArr2 removeObject:_photoStreamTitle];
            [tempArr3 removeObject:_photoStreamIdentifier];
            if (tempArr.count > 0) {
                [tempArr insertObject:_photoStreamResult atIndex:1];
                [tempArr2 insertObject:_photoStreamTitle atIndex:1];
                [tempArr3 insertObject:_photoStreamIdentifier atIndex:1];
            } else {
                [tempArr addObject:_photoStreamResult.firstObject];
                [tempArr2 addObject:_photoStreamTitle];
                [tempArr3 addObject:_photoStreamIdentifier];
            }
        }

        self.fetchResultsArray = [NSArray arrayWithArray:tempArr];
        self.fetchResultsTitles = [NSArray arrayWithArray:tempArr2];
        self.fetchResultsIdentifiers = [NSArray arrayWithArray:tempArr3];
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
        headerModel.localIdentifier = [self.fetchResultsIdentifiers objectAtIndex:index];

        NSInteger currentTag = headerModel.tag + 1;
        headerModel.tag = currentTag;
        
        PHAsset *asset = result.firstObject;
        if (result.count > 0) {
            NSInteger scale = [UIScreen mainScreen].scale;
            CGSize size = CGSizeMake(88 * scale, 88 * scale);
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
    CGFloat height = width;
    layout.itemSize = CGSizeMake(width, height);
    layout.sectionInset = UIEdgeInsetsMake(0.0f, KItemPadding, KItemPadding, KItemPadding);
    self = [super initWithCollectionViewLayout:layout];
    return self;
}

- (void)dealloc {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        _imageManager = [[PHCachingImageManager alloc] init];
        [self setupSmartCollections];
        [self setupAlbumCollections];
        [self setupFetchResults];
        [self setupHeaderModel];
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[STPictureCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionReusableViewIdenfifier];
    [self.collectionView registerClass:[HZAssetCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellReuseIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupAlertView {
    if (self.cachedHeaderModels.count == 0) {
        if (!alertView) {
            alertView = [[[NSBundle mainBundle] loadNibNamed:@"STNoFileAlertView" owner:nil options:nil] lastObject];
            alertView.imageView.image = [UIImage imageNamed:@"img_tupian"];
            alertView.label.text = @"此设备暂无图片";
            alertView.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT - 109);
            [self.view addSubview:alertView];
            
        }
        
        [self.view bringSubviewToFront:alertView];
        alertView.hidden = NO;
    } else {
        alertView.hidden = YES;
    }
}

- (void)expandButtonClick:(UIButton *)sender {
    if (_cachedHeaderModels.count > sender.tag) {
        STPictureCollectionHeaderInfo *model = [_cachedHeaderModels objectAtIndex:sender.tag];
        model.expand = !model.expand;
        [self.collectionView reloadData];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    __block PHObjectPlaceholder *placeholder;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:originalImage];
        placeholder = [assetRequest placeholderForCreatedAsset];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                      subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                      options:nil].firstObject;
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[placeholder.localIdentifier] options:nil].firstObject;
                [self.fileSelectionTabController addAsset:asset inCollection:collection.localIdentifier];
            } else {
                NSLog(@"Saving image error : %@", error);
            }
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [self setupAlertView];
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
            cell.thumbnailImage = [UIImage imageNamed:@"ic_xiangji"];
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
    
    if ([self.fileSelectionTabController isSelectedWithAsset:asset inCollection:model.localIdentifier]) {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        cell.selected = NO;
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
    if (model.fetchResult.count == [self.fileSelectionTabController selectedPhotosCountInCollection:model.localIdentifier]) {
        model.selectedAll = YES;
    } else {
        model.selectedAll = NO;
    }
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader)
    {
        STPictureCollectionReusableView *headerView = (STPictureCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionReusableViewIdenfifier forIndexPath:indexPath];
        headerView.tabViewController = (STFileSelectionViewController *)self.fileSelectionTabController;
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
    [self.fileSelectionTabController addAsset:asset inCollection:model.localIdentifier];
    if (model.fetchResult.count == [self.fileSelectionTabController selectedPhotosCountInCollection:model.localIdentifier]) {
        model.selectedAll = YES;
        [collectionView reloadData];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    STPictureCollectionHeaderInfo *model = [self.cachedHeaderModels objectAtIndex:indexPath.section];

    if (model.isCameraRoll) {
        item -= 1;
    }
    
    PHAsset *asset = model.fetchResult[item];
    [self.fileSelectionTabController removeAsset:asset inCollection:model.localIdentifier];
    if (model.selectedAll) {
        model.selectedAll = NO;
        [collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    STPictureCollectionHeaderInfo *model = [self.cachedHeaderModels objectAtIndex:section];
    return CGSizeMake(IPHONE_WIDTH, model.height);
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL needReload = NO;
        if (!_imageManager) {
            _imageManager = [[PHCachingImageManager alloc] init];
            [self setupSmartCollections];
            [self setupAlbumCollections];
            [self setupFetchResults];
            [self setupHeaderModel];
            needReload = YES;
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
                        [self.fileSelectionTabController removeAsset:asset inCollection:[self.fetchResultsIdentifiers objectAtIndex:index]];
                    }];
                }
                
                [updatedFetchResultsArray replaceObjectAtIndex:index withObject:[collectionChanges fetchResultAfterChanges]];
                
                NSUInteger index = [_smartFetchResults indexOfObject:collectionsFetchResult];
                if (index != NSNotFound) {
                    [_smartFetchResults replaceObjectAtIndex:index withObject:[collectionChanges fetchResultAfterChanges]];
                }
                
                index = [_albumFetchResults indexOfObject:collectionsFetchResult];
                if (index != NSNotFound) {
                    [_albumFetchResults replaceObjectAtIndex:index withObject:[collectionChanges fetchResultAfterChanges]];
                }
                
                if (collectionsFetchResult == _photoStreamResult) {
                    _photoStreamResult = [collectionChanges fetchResultAfterChanges];
                }
                
                reloadRequired2 = YES;
            }
            
        }];
        if (reloadRequired2) {
            self.fetchResultsArray = [NSArray arrayWithArray:updatedFetchResultsArray];
        }
        
        BOOL reloadRequired = NO;
        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:_smartCollections];
        if (changeDetails != nil) {
            _smartCollections = [changeDetails fetchResultAfterChanges];
            [self setupSmartCollections];
            reloadRequired = YES;
        }
        
        changeDetails = [changeInstance changeDetailsForFetchResult:_albumCollections];
        if (changeDetails != nil) {
            NSIndexSet *indexSet = [changeDetails removedIndexes];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                if (self.albumIdentifiers.count > idx) {
                    [self.fileSelectionTabController removeAllAssetsInCollection:self.albumIdentifiers[idx]];
                }
            }];
            _albumCollections = [changeDetails fetchResultAfterChanges];
            [self setupAlbumCollections];
            reloadRequired = YES;
        }
     
        if (reloadRequired) {
            [self setupFetchResults];
        }

        if (reloadRequired || reloadRequired2 || needReload) {
            [self setupHeaderModel];
            [self.collectionView reloadData];
            [self.fileSelectionTabController photoLibraryDidChange];
        }
    });
}

@end
