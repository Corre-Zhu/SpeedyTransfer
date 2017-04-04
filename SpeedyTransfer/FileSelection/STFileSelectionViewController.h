//
//  STFileSelectionViewController.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/18.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class PHFetchResult;
@class STMusicInfo;
@class STContactInfo;
@class STFileInfo;

@interface STFileSelectionViewController : UIViewController

// All
- (void)selectedFilesCountChanged;
- (NSArray *)allSelectedFiles;
- (void)removeAllSelectedFiles;

// 图片
@property (nonatomic, strong, readonly) NSMutableArray *selectedAssetsArr;
- (NSInteger)selectedPhotosCountInCollection:(NSString *)collection;
- (void)addAsset:(PHAsset *)asset inCollection:(NSString *)collection;
- (void)addAssets:(NSArray *)assets inCollection:(NSString *)collection;
- (void)removeAsset:(PHAsset *)asset inCollection:(NSString *)collection;
- (void)removeAssets:(NSArray *)assets inCollection:(NSString *)collection;
- (void)removeAllAssetsInCollection:(NSString *)collection;
- (BOOL)isSelectedWithAsset:(PHAsset *)asset inCollection:(NSString *)collection;

// 视频
@property (nonatomic, strong, readonly) NSMutableOrderedSet *selectedVideoAssetsArr;
- (void)addVideoAsset:(PHAsset *)asset;
- (void)addVideoAssets:(NSArray *)assets;
- (void)removeVideoAsset:(PHAsset *)asset;
- (void)removeAllVideoAssets;
- (BOOL)isSelectedWithVideoAsset:(PHAsset *)asset;

// 联系人
@property (nonatomic, strong, readonly) NSMutableArray *selectedContactsArr;
- (void)addContact:(STContactInfo *)contact;
- (void)addContacts:(NSArray *)contacts;
- (void)removeContact:(STContactInfo *)contact;
- (void)removeContacts:(NSArray *)contacts;
- (void)removeAllContacts;
- (BOOL)isSelectedWithContact:(STContactInfo *)contact;
- (BOOL)isSelectedWithContacts:(NSArray *)contacts;

// 文件
@property (nonatomic, strong, readonly) NSMutableArray *selectedFilesArray;
- (void)addFile:(STFileInfo *)file;
- (void)addFiles:(NSArray *)files;
- (void)removeFile:(STFileInfo *)file;
- (void)removeAllFiles;
- (BOOL)isSelectedWithFile:(STFileInfo *)file;

// 界面刷新
- (void)photoLibraryDidChange;
- (void)reloadAssetsTableView;
- (void)reloadVideosTableView;
- (void)reloadContactsTableView;
- (void)reloadFilesTableView;

@end
