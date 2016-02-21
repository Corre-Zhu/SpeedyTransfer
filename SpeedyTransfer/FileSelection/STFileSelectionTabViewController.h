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

// 音乐
@property (nonatomic, strong, readonly) NSMutableArray *selectedMusicsArr;

- (void)addMusic:(STMusicInfo *)music;
- (void)addMusics:(NSArray *)musics;
- (void)removeMusic:(STMusicInfo *)music;
- (void)removeMusics:(NSArray *)musics;
- (BOOL)isSelectedWithMusic:(STMusicInfo *)music;
- (BOOL)isSelectedWithMusics:(NSArray *)musics;

// 视频
@property (nonatomic, strong, readonly) NSMutableArray *selectedVideoAssetsArr;

- (void)addVideoAsset:(PHAsset *)asset;
- (void)removeVideoAsset:(PHAsset *)asset;
- (BOOL)isSelectedWithVideoAsset:(PHAsset *)asset;

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

@end
