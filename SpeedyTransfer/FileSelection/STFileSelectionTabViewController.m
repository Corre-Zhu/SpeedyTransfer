//
//  STFileSelectionTabViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileSelectionTabViewController.h"
#import <Photos/Photos.h>
#import "STMusicInfo.h"
#import "STFileSelectionPopupView.h"
#import "STWifiNotConnectedPopupView.h"
#import "STTransferInstructionViewController.h"
#import "STFileTransferModel.h"
#import "STContactInfo.h"

@interface STFileSelectionTabViewController ()
{
    UIImageView *toolView;
    UIButton *deleteButton;
    UIButton *transferButton;
    STFileSelectionPopupView *popupView;
    STWifiNotConnectedPopupView *wifiNotConnectedPopupView;
}

@end

@implementation STFileSelectionTabViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[STFileTransferModel shareInstant] removeObserver:self forKeyPath:@"selectedFilesCount"];
    [[STFileTransferModel shareInstant] removeObserver:self forKeyPath:@"photosCountChanged"];
    [[STFileTransferModel shareInstant] removeObserver:self forKeyPath:@"musicsCountChanged"];
    [[STFileTransferModel shareInstant] removeObserver:self forKeyPath:@"videosCountChanged"];
    [[STFileTransferModel shareInstant] removeObserver:self forKeyPath:@"contactsCountChanged"];
    [[STFileTransferModel shareInstant] removeAllSelectedFiles];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    self.navigationItem.title = NSLocalizedString(@"选择文件", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    toolView = [[UIImageView alloc] initWithFrame:CGRectMake((IPHONE_WIDTH - 175.0f) / 2.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 92.0f, 175.0f, 40.0f)];
    toolView.image = [[UIImage imageNamed:@"xuanze_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0f, 7.0f, 7.0f, 7.0f)];
    toolView.userInteractionEnabled = YES;
    [self.view addSubview:toolView];
    toolView.hidden = YES;
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(9.0f, 2.0f, 35.0f, 35.0f);
    [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:deleteButton];
    
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(53.0f, 12.0f, 0.5f, 17.0f)];
    lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    [toolView addSubview:lineView];
    
    transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
    transferButton.frame = CGRectMake(73.0f, 3.0f, 82.0f, 34.0f);
    [transferButton setTitle:NSLocalizedString(@"全部传输", nil) forState:UIControlStateNormal];
    [transferButton addTarget:self action:@selector(transferButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [transferButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    transferButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [toolView addSubview:transferButton];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:kHTReachabilityChangedNotification object:nil];
    
    [[STFileTransferModel shareInstant] addObserver:self forKeyPath:@"selectedFilesCount" options:NSKeyValueObservingOptionNew context:NULL];
    [[STFileTransferModel shareInstant] addObserver:self forKeyPath:@"photosCountChanged" options:NSKeyValueObservingOptionNew context:NULL];
    [[STFileTransferModel shareInstant] addObserver:self forKeyPath:@"musicsCountChanged" options:NSKeyValueObservingOptionNew context:NULL];
    [[STFileTransferModel shareInstant] addObserver:self forKeyPath:@"videosCountChanged" options:NSKeyValueObservingOptionNew context:NULL];
    [[STFileTransferModel shareInstant] addObserver:self forKeyPath:@"contactsCountChanged" options:NSKeyValueObservingOptionNew context:NULL];

}

- (void)configToolView {
    NSInteger count = [STFileTransferModel shareInstant].selectedFilesCount;
    if (count > 0) {
        [transferButton setTitle:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"全部传输", nil), @(count)] forState:UIControlStateNormal];
        toolView.hidden = NO;
    } else {
        [transferButton setTitle:NSLocalizedString(@"全部传输", nil) forState:UIControlStateNormal];
        toolView.hidden = YES;
    }
    
    [transferButton sizeToFit];
    CGFloat width = MAX(82.0f, transferButton.width);
    toolView.width = 93.0f + width;
    toolView.left = (IPHONE_WIDTH - toolView.width) / 2.0f;
    transferButton.width = width;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectedFilesCount"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configToolView];
        });
    } else if ([keyPath isEqualToString:@"photosCountChanged"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadAssetsTableView];
        });
    } else if ([keyPath isEqualToString:@"musicsCountChanged"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadMusicsTableView];
        });
    } else if ([keyPath isEqualToString:@"videosCountChanged"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadVideosTableView];
        });
    } else if ([keyPath isEqualToString:@"contactsCountChanged"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadContactsTableView];
        });
    }
}

- (void)photoLibraryDidChange {
    if (popupView.superview) {
        [popupView removeFromSuperview];
    }
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonClick {
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *dic in [STFileTransferModel shareInstant].selectedAssetsArr) {
        if ([dic.allValues.firstObject count] > 0) {
            [array addObject:dic.allValues.firstObject];
        }
    }
    
    if (self.selectedMusicsArr.count > 0) {
        [array addObject:self.selectedMusicsArr];
    }
    
    if (self.selectedVideoAssetsArr.count > 0) {
        [array addObject:self.selectedVideoAssetsArr];
    }
    
    if (self.selectedContactsArr.count > 0) {
        [array addObject:self.selectedContactsArr];
    }
    
    popupView = [[STFileSelectionPopupView alloc] init];
    popupView.tabViewController = self;
    popupView.dataSource = array;
    [popupView showInView:self.navigationController.view];
}

- (void)reachabilityStatusChange:(NSNotification *)notification {
	NetworkStatus status = [ZZReachability shareInstance].currentReachabilityStatus;
	switch (status) {
		case NotReachable:
			break;
		case ReachableViaWiFi: {
			if ([wifiNotConnectedPopupView isShow]) {
				[wifiNotConnectedPopupView removeFromSuperview];
				
				STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
				[self.navigationController pushViewController:transferIns animated:YES];
			}
		}
			break;
		
		default:
			return;
	}
}

- (void)transferButtonClick {
	if ([ZZReachability shareInstance].currentReachabilityStatus != ReachableViaWiFi) {
        if (!wifiNotConnectedPopupView) {
            wifiNotConnectedPopupView = [[STWifiNotConnectedPopupView alloc] init];
        }
        [wifiNotConnectedPopupView showInView:self.navigationController.view];
        
    } else {
        STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
        [self.navigationController pushViewController:transferIns animated:YES];
    }
}

#pragma mark - Send file

//- (PHAsset *)firstPhotoAsset {
//    for (NSDictionary *dic in _selectedAssetsArr) {
//        NSMutableArray *arr = [dic.allValues firstObject];
//        if (arr.count > 0) {
//            PHAsset *asset = arr.firstObject;
//            [arr removeObject:asset];
//            return asset;
//        }
//    }
//    
//    return nil;
//}

/*
- (void)startSendFile {
    self.sendingFile = YES;
    
    // 发送图片
    PHAsset *photoAsset = [self firstPhotoAsset];
    if (photoAsset) {
        [self.fileSelectionTabController reloadAssetsTableView];
        [[PHImageManager defaultManager] requestImageDataForAsset:photoAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
            NSString *path = [[ZZPath picturePath] stringByAppendingPathComponent:[url.absoluteString lastPathComponent]];
            [imageData writeToFile:path atomically:YES];
//            self.currentTransferInfo = [[STFileTransferModel shareInstant] saveAssetWithIdentifier:photoAsset.localIdentifier fileName:[url.absoluteString lastPathComponent] length:imageData.length forKey:nil];
            
            __weak STFileTransferInfo *weakInfo = _currentTransferInfo;
            
            lastTimeInterval = [[NSDate date] timeIntervalSince1970];
        }];
        return;
    }
    
    // 发送音乐
    if (self.fileSelectionTabController.selectedMusicsArr.count > 0) {
        STMusicInfo *musicInfo = self.fileSelectionTabController.selectedMusicsArr.firstObject;
        [self.fileSelectionTabController removeMusic:musicInfo];
        [self.fileSelectionTabController reloadMusicsTableView];
        
        NSURL *url = musicInfo.url;
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                          initWithAsset: songAsset
                                          presetName: AVAssetExportPresetAppleM4A];
        
        exporter.outputFileType = @"com.apple.m4a-audio";
        
        NSString *exportFile = [[ZZPath documentPath] stringByAppendingPathComponent:@"31412313.m4a"];
        
        NSError *error1;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:exportFile])
        {
            [[NSFileManager defaultManager] removeItemAtPath:exportFile error:&error1];
        }
        
        NSURL* exportURL = [NSURL fileURLWithPath:exportFile];
        
        exporter.outputURL = exportURL;
        
        // do the export
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             int exportStatus = exporter.status;
             
             switch (exportStatus) {
                     
                 case AVAssetExportSessionStatusFailed: {
                     // log error to text view
                     NSError *exportError = exporter.error;
                     
                     NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                     break;
                 }
                     
                 case AVAssetExportSessionStatusCompleted: {
                     
                     NSLog (@"AVAssetExportSessionStatusCompleted");
                     
					 
                     break;
                 }
                 default:
                 { NSLog (@"didn't get export status");
                     break;
                 }
             }
             
         }];
        
        return;
    }
    
    // 发送联系人
    if (self.fileSelectionTabController.selectedContactsArr.count > 0) {
        STContactInfo *contact = self.fileSelectionTabController.selectedContactsArr.firstObject;
        NSData *data = [contact.vcardString dataUsingEncoding:NSUTF8StringEncoding];
        if (data.length > 0) {
//            STFileTransferInfo *info = [[STFileTransferModel shareInstant] setContactInfo:contact forKey:nil];
//            NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
			
        } else {
            [self.fileSelectionTabController removeContact:contact];
            [self.fileSelectionTabController reloadContactsTableView];
            [self startSendFile];
        }
        
        return;
    }
    
    self.sendingFile = NO;
}
 */

#pragma mark - Reload table view

- (void)reloadAssetsTableView {
    UICollectionViewController *viewC = self.viewControllers.firstObject;
    [viewC.collectionView reloadData];
}

- (void)reloadMusicsTableView {
    UITableViewController *viewC = self.viewControllers[1];
    [viewC.tableView reloadData];
}

- (void)reloadVideosTableView {
    UITableViewController *viewC = self.viewControllers[2];
    [viewC.tableView reloadData];
}

- (void)reloadContactsTableView {
    UITableViewController *viewC = self.viewControllers.lastObject;
    [viewC.tableView reloadData];
}

#pragma mark - Music

- (void)addMusic:(STMusicInfo *)music {
    if (!music) {
        return;
    }
    
    if (!_selectedMusicsArr) {
        _selectedMusicsArr = [NSMutableArray array];
    }
    
    if (![_selectedMusicsArr containsObject:music]) {
        [_selectedMusicsArr addObject:music];
    }
    
    [self configToolView];
}

- (void)addMusics:(NSArray *)musics {
    if (!musics) {
        return;
    }
    
    if (!_selectedMusicsArr) {
        _selectedMusicsArr = [NSMutableArray array];
    }
    
    [_selectedMusicsArr addObjectsFromArray:musics];
    
    [self configToolView];
}

- (void)removeMusic:(STMusicInfo *)music {
    if (!music) {
        return;
    }
    
    if ([_selectedMusicsArr containsObject:music]) {
        [_selectedMusicsArr removeObject:music];
    }
    
    [self configToolView];
}

- (void)removeMusics:(NSArray *)musics {
    if (!musics) {
        return;
    }
    
    [_selectedMusicsArr removeObjectsInArray:musics];
    
    [self configToolView];
}

- (BOOL)isSelectedWithMusic:(STMusicInfo *)music {
    return [_selectedMusicsArr containsObject:music];
}

- (BOOL)isSelectedWithMusics:(NSArray *)musics {
    for (STMusicInfo *model in musics) {
        if (![_selectedMusicsArr containsObject:model]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)addVideoAsset:(PHAsset *)asset {
    if (!asset) {
        return;
    }
    
    if (!_selectedVideoAssetsArr) {
        _selectedVideoAssetsArr = [NSMutableArray array];
    }
    
    if (![_selectedVideoAssetsArr containsObject:asset]) {
        [_selectedVideoAssetsArr addObject:asset];
    }
    
    [self configToolView];
}

- (void)removeVideoAsset:(PHAsset *)asset {
    if (!asset) {
        return;
    }
    
    [_selectedVideoAssetsArr removeObject:asset];
    
    [self configToolView];
}

- (BOOL)isSelectedWithVideoAsset:(PHAsset *)asset {
    return [_selectedVideoAssetsArr containsObject:asset];
}

- (void)addContact:(STContactInfo *)contact {
    if (!contact) {
        return;
    }
    
    if (!_selectedContactsArr) {
        _selectedContactsArr = [NSMutableArray array];
    }
    
    if (![_selectedContactsArr containsObject:contact]) {
        [_selectedContactsArr addObject:contact];
    }
    
    [self configToolView];
}

- (void)addContacts:(NSArray *)contacts {
    if (!contacts) {
        return;
    }
    
    if (!_selectedContactsArr) {
        _selectedContactsArr = [NSMutableArray array];
    }
    
    [_selectedContactsArr addObjectsFromArray:contacts];
    
    [self configToolView];
}

- (void)removeContact:(STContactInfo *)contact {
    if (!contact) {
        return;
    }
    
    [_selectedContactsArr removeObject:contact];
    
    [self configToolView];
}

- (void)removeContacts:(NSArray *)contacts {
    if (!contacts) {
        return;
    }
    
    [_selectedContactsArr removeObjectsInArray:contacts];
    
    [self configToolView];
}

- (BOOL)isSelectedWithContact:(STContactInfo *)contact {
    return [_selectedContactsArr containsObject:contact];
}

- (BOOL)isSelectedWithContacts:(NSArray *)contacts {
    for (STContactInfo *model in contacts) {
        if (![_selectedContactsArr containsObject:model]) {
            return NO;
        }
    }
    
    return YES;
}

@end
