//
//  STFileSelectionTabViewController.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STFileTransferInfo.h"

@class PHAsset;
@class PHFetchResult;
@class STMusicInfo;
@class STContactInfo;

@interface STFileSelectionTabViewController : UITabBarController

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
@property (nonatomic, strong, readonly) NSMutableArray *selectedVideoAssetsArr;
- (void)addVideoAsset:(PHAsset *)asset;
- (void)removeVideoAsset:(PHAsset *)asset;
- (BOOL)isSelectedWithVideoAsset:(PHAsset *)asset;

// 音乐
@property (nonatomic, strong, readonly) NSMutableArray *selectedMusicsArr;
- (void)addMusic:(STMusicInfo *)music;
- (void)addMusics:(NSArray *)musics;
- (void)removeMusic:(STMusicInfo *)music;
- (void)removeMusics:(NSArray *)musics;
- (BOOL)isSelectedWithMusic:(STMusicInfo *)music;
- (BOOL)isSelectedWithMusics:(NSArray *)musics;

// 联系人
@property (nonatomic, strong, readonly) NSMutableArray *selectedContactsArr;
- (void)addContact:(STContactInfo *)contact;
- (void)addContacts:(NSArray *)contacts;
- (void)removeContact:(STContactInfo *)contact;
- (void)removeContacts:(NSArray *)contacts;
- (BOOL)isSelectedWithContact:(STContactInfo *)contact;
- (BOOL)isSelectedWithContacts:(NSArray *)contacts;

// 界面刷新
- (void)photoLibraryDidChange;
- (void)reloadAssetsTableView;
- (void)reloadMusicsTableView;
- (void)reloadVideosTableView;
- (void)reloadContactsTableView;

@end
