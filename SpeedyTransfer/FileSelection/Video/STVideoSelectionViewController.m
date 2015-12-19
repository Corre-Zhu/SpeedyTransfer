//
//  STVideoSelectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STVideoSelectionViewController.h"
#import "STMusicSelectionCell.h"
#import <Photos/Photos.h>

static NSString *VideoSelectionCellIdentifier = @"VideoSelectionCellIdentifier";

@interface STVideoSelectionViewController ()<PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation STVideoSelectionViewController

- (void)setupFetchResults {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    PHFetchResult *smartCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeVideo)]];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    // Smart collections
    for(PHCollection *collection in smartCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumVideos) {
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if(assetsFetchResult.count>0) {
                    _fetchResult = assetsFetchResult;
                }
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFetchResults];
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    [self.tableView registerClass:[STMusicSelectionCell class] forCellReuseIdentifier:VideoSelectionCellIdentifier];
    _imageManager = [[PHCachingImageManager alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fetchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STMusicSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:VideoSelectionCellIdentifier forIndexPath:indexPath];
   
    PHAsset *asset = _fetchResult[indexPath.item];
    
    cell.image = [UIImage imageNamed:@"video_bg"];
    
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;

//    [_imageManager requestImageForAsset:asset
//                                 targetSize:CGSizeMake(96.0f, 96.0f)
//                                contentMode:PHImageContentModeAspectFill
//                                    options:nil
//                              resultHandler:^(UIImage *result, NSDictionary *info) {
//                                  if (cell.tag == currentTag) {
//                                      cell.image = result;
//                                  }
//                              }];
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (cell.tag == currentTag) {
            float imageSize = imageData.length;
            imageSize = imageSize/(1024*1024);
            cell.subTitle = [NSString stringWithFormat:@"%.2fMB", imageSize];
            NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
            cell.title = [url.absoluteString lastPathComponent];
        }
    }];
    
    if ([self.fileSelectionTabController isSelectedWithVideoAsset:asset]) {
        cell.checked = YES;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        cell.checked = NO;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _fetchResult[indexPath.item];
    [self.fileSelectionTabController addVideoAsset:asset];
    STMusicSelectionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checked = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _fetchResult[indexPath.item];
    [self.fileSelectionTabController removeVideoAsset:asset];
    STMusicSelectionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checked = NO;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
}

@end
