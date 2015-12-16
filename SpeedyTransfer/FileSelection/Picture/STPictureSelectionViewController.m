//
//  STPictureSelectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STPictureSelectionViewController.h"
#import "STAlbumViewCell.h"
#import <Photos/Photos.h>

@interface STPictureSelectionViewController ()<PHPhotoLibraryChangeObserver>

@property (strong) PHFetchResult *topLevelCollections;
@property (strong) PHFetchResult *smartCollections;
@property (strong) PHFetchResult *photoStreamsCollections;
@property (strong) PHFetchResult *iCloudShareCollections;
@property (nonatomic, strong) NSArray *smartCollectionSubtypes;

@property (strong) NSArray *fetchResultsArray;
@property (strong) NSArray *fetchResultsTitles;

@property (nonatomic,strong) NSMutableDictionary *cachedCells;

@end

@implementation STPictureSelectionViewController

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
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
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

- (void)setupCells {
    if (!_cachedCells) {
        _cachedCells = [NSMutableDictionary dictionary];
    }
    
    for (PHFetchResult *result in self.fetchResultsArray) {
        NSInteger index = [self.fetchResultsArray indexOfObject:result];
        
        STAlbumViewCell *cell = [[STAlbumViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.tableView = self.tableView;
        cell.tabViewController = (STFileSelectionTabViewController *)self.tabBarController;
        cell.isCameraRoll = (index == 0);
        
        NSInteger currentTag = cell.tag + 1;
        cell.tag = currentTag;
        
        cell.fetchResult = result;
        cell.title = [self.fetchResultsTitles objectAtIndex:index];
        
        PHAsset *asset = result.lastObject;
        if (result.count > 0) {
            NSInteger scale = [UIScreen mainScreen].scale;
            CGSize size = CGSizeMake(72 * scale, 72 * scale);
            [[PHImageManager defaultManager] requestImageForAsset:asset
                                                       targetSize:size
                                                      contentMode:PHImageContentModeAspectFill options:nil
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        if (cell.tag == currentTag) {
                                                            cell.placeholdImage = result;
                                                        }
                                                    }];
        }
        
        [_cachedCells setObject:cell forKey:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFetchResults];
    [self setupCells];
    self.tableView.separatorColor = RGBFromHex(0xc8c7cc);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cachedCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_cachedCells objectForKey:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    STAlbumViewCell *cell = (STAlbumViewCell *)[_cachedCells objectForKey:indexPath];
    return [cell cellHeight];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STAlbumViewCell *cell = (STAlbumViewCell *)[_cachedCells objectForKey:indexPath];
    cell.expand = !cell.expand;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
}

@end
