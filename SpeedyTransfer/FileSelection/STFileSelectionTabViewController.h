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

@property (nonatomic, strong) NSArray *selectedFilesArray;
@property (nonatomic) NSInteger selectedFilesCount;

- (void)removeAllSelectedFiles;

// 开始发送选择好的文件
- (void)startSendFile;
@property (nonatomic, strong) STFileTransferInfo *currentTransferInfo;
@property (nonatomic) BOOL sendingFile;

// 图片
@property (nonatomic, strong, readonly) NSArray *selectedAssetsArr;

- (void)addAsset:(PHAsset *)asset;
- (void)addAssets:(NSArray *)assetss;
- (void)removeAsset:(PHAsset *)asset;
- (void)removeAssets:(NSArray *)assets;
- (BOOL)isSelectedWithAsset:(PHAsset *)asset;

- (void)reloadAssetsTableView;

// 音乐
@property (nonatomic, strong, readonly) NSArray *selectedMusicsArr;

- (void)addMusic:(STMusicInfo *)music;
- (void)addMusics:(NSArray *)musics;
- (void)removeMusic:(STMusicInfo *)music;
- (void)removeMusics:(NSArray *)musics;
- (BOOL)isSelectedWithMusic:(STMusicInfo *)music;
- (BOOL)isSelectedWithMusics:(NSArray *)musics;

- (void)reloadMusicsTableView;

// 视频
@property (nonatomic, strong, readonly) NSArray *selectedVideoAssetsArr;

- (void)addVideoAsset:(PHAsset *)asset;
- (void)removeVideoAsset:(PHAsset *)asset;
- (BOOL)isSelectedWithVideoAsset:(PHAsset *)asset;

- (void)reloadVideosTableView;

// 联系人
@property (nonatomic, strong, readonly) NSArray *selectedContactsArr;

- (void)addContact:(STContactInfo *)contact;
- (void)addContacts:(NSArray *)contacts;
- (void)removeContact:(STContactInfo *)contact;
- (void)removeContacts:(NSArray *)contacts;
- (BOOL)isSelectedWithContact:(STContactInfo *)contact;
- (BOOL)isSelectedWithContacts:(NSArray *)contacts;

- (void)reloadContactsTableView;

@end
