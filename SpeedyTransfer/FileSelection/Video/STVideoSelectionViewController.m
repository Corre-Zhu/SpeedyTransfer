//
//  STVideoSelectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STVideoSelectionViewController.h"
#import "STVideoSelectionCell.h"
#import <Photos/Photos.h>
#import "STNoFileAlertView.h"

static NSString *VideoSelectionCellIdentifier = @"VideoSelectionCellIdentifier";

@interface STVideoSelectionViewController ()<PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    UIView *headerView;
    UILabel *headerLabel;
    UIButton *selectAllButton;
    
    STNoFileAlertView *alertView;
}

@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation STVideoSelectionViewController

- (void)setupFetchResults {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    PHFetchResult *smartCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeVideo)]];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
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
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self setupFetchResults];
        _imageManager = [[PHCachingImageManager alloc] init];
    }

    self.tableView.allowsMultipleSelection = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    [self.tableView registerClass:[STVideoSelectionCell class] forCellReuseIdentifier:VideoSelectionCellIdentifier];
    
}

- (void)setupAlertView {
    if (_fetchResult.count == 0) {
        if (!alertView) {
            alertView = [[[NSBundle mainBundle] loadNibNamed:@"STNoFileAlertView" owner:nil options:nil] lastObject];
            alertView.imageView.image = [UIImage imageNamed:@"img_vedio"];
            alertView.label.text = @"此设备暂无视频";
            alertView.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT - 109);
            [self.view addSubview:alertView];
            
        }
        
        [self.view bringSubviewToFront:alertView];
        alertView.hidden = NO;
    } else {
        alertView.hidden = YES;
    }
}

- (void)setupSelectAllButton {
    if (self.fileSelectionTabController.selectedVideoAssetsArr.count >= _fetchResult.count) {
        selectAllButton.selected = YES;
    } else {
        selectAllButton.selected = NO;
    }
}

- (void)selectAll {
    if (selectAllButton.selected) {
        [self.fileSelectionTabController removeAllVideoAssets];
    } else {
        [self.fileSelectionTabController addVideoAssets:[_fetchResult objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _fetchResult.count)]]];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self setupAlertView];
    return _fetchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STVideoSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:VideoSelectionCellIdentifier forIndexPath:indexPath];
   
    PHAsset *asset = _fetchResult[indexPath.item];
    
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;

	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.resizeMode = PHImageRequestOptionsResizeModeExact;
	options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
//    [_imageManager requestImageForAsset:asset
//                                 targetSize:CGSizeMake([UIScreen mainScreen].scale * 68.0f, [UIScreen mainScreen].scale * 52.0f)
//                                contentMode:PHImageContentModeAspectFill
//                                    options:options
//                              resultHandler:^(UIImage *result, NSDictionary *info) {
//                                  if (cell.tag == currentTag) {
//                                      cell.image = result;
//                                  }
//                              }];
    
    if (IOS9 && asset.mediaType == PHAssetMediaTypeVideo) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([asset isKindOfClass:[AVComposition class]]) {
                    
                }
                
                if (cell.tag == currentTag) {
                    NSArray *tracks = [asset tracks];
                    float estimatedSize = 0.0 ;
                    for (AVAssetTrack * track in tracks) {
                        float rate = ([track estimatedDataRate] / 8); // convert bits per second to bytes per second
                        float seconds = CMTimeGetSeconds([track timeRange].duration);
                        estimatedSize += seconds * rate;
                    }
                    float sizeInMB = estimatedSize / 1024.0f / 1024.0f;
                    cell.subTitle = [NSString stringWithFormat:@"%.2fMB", sizeInMB];
                    
                    
                    NSString *temp = [info stringForKey:@"PHImageFileSandboxExtensionTokenKey"];
                    NSString *df = temp.lastPathComponent;
                    
                    cell.title = [df uppercaseString];
                }
            });
            
        }];
    } else {
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            if (cell.tag == currentTag) {
                float imageSize = imageData.length;
                imageSize = imageSize/(1024*1024);
                cell.subTitle = [NSString stringWithFormat:@"%.2fMB", imageSize];
                NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                cell.title = [url.absoluteString lastPathComponent];
            }
        }];
    }
    
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
    return 80.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!headerView) {
        headerView = [[UIView alloc] init];
        headerView.backgroundColor = RGBFromHex(0xf4f4f4);
        
        headerLabel = [[UILabel alloc] init];
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.textColor = RGBFromHex(0x333333);
        headerLabel.frame = CGRectMake(16, 0, 200, 40);
        [headerView addSubview:headerLabel];
        
        selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [selectAllButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateSelected];
        [selectAllButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateNormal];
        [selectAllButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateSelected];
        selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 96, 0, 80.0f, 40.0f);
        selectAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [headerView addSubview:selectAllButton];
        [selectAllButton addTarget:self action:@selector(selectAll)forControlEvents:UIControlEventTouchUpInside];
    }
    headerLabel.text = [NSString stringWithFormat:@"%@个视频", @(_fetchResult.count)];
    [self setupSelectAllButton];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _fetchResult[indexPath.item];
    [self.fileSelectionTabController addVideoAsset:asset];
    STVideoSelectionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checked = YES;
    [self setupSelectAllButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _fetchResult[indexPath.item];
    [self.fileSelectionTabController removeVideoAsset:asset];
    STVideoSelectionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checked = NO;
    [self setupSelectAllButton];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
}

@end
