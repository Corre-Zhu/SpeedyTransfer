//
//  STFileTransferViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferViewController.h"
#import "STFileTransferCell.h"
#import "STContactInfo.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Photos/Photos.h>
#import "STSendHeaderView.h"
#import "STReceiveHeaderView.h"
#import "STWifiNotConnectedPopupView2.h"
#import "MBProgressHUD.h"
#import "STHomeViewController.h"
#import "STWebServerModel.h"
#import "STFileTransferBaseModel.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
@import AVKit;

static NSString *sendHeaderIdentifier = @"sendHeaderIdentifier";
static NSString *receiveHeaderIdentifier = @"receiveHeaderIdentifier";
static NSString *cellIdentifier = @"CellIdentifier";

@interface STFileTransferViewController ()<UITableViewDataSource,UITableViewDelegate,UIDocumentInteractionControllerDelegate,STFileTransferBaseModelDelegate,UIGestureRecognizerDelegate>
{
    STWifiNotConnectedPopupView2 *popupView;

    UIButton *continueSendButton;
    STFileTransferInfo *currentTransferInfo;
    NSTimeInterval lastTimeInterval;
    
    UIDocumentInteractionController *documentController;
    
    UIView *noDiskSpaceAlertView; // 磁盘空间不足提示
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) STFileTransferBaseModel *model;

@end

@implementation STFileTransferViewController

- (void)dealloc {
    [_model removeObserver:self forKeyPath:@"transferFiles"];
    [[STMultiPeerTransferModel shareInstant] removeObserver:self forKeyPath:@"state"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    [self leftBarButtonItemClick];
    return NO;
}

- (void)leftBarButtonItemClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"\0\n不再传输其它文件，确认退出\n\0", nil) message:nil preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 停止广播，断开连接和传输
        [[STMultiPeerTransferModel shareInstant] cancelAllTransferFile];
        [[STFileTransferModel shareInstant] cancelAllTransferFile];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertController addAction:action1];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:NULL];
    [alertController addAction:action3];
    
    [action3 setValue:RGBFromHex(0x666666) forKey:@"_titleTextColor"];
    [action1 setValue:RGBFromHex(0x01cc99) forKey:@"_titleTextColor"];

    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    self.navigationItem.title = NSLocalizedString(@"传输空间", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR - 44.0f) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[STFileTransferCell class] forCellReuseIdentifier:cellIdentifier];
    [_tableView registerClass:[STSendHeaderView class] forHeaderFooterViewReuseIdentifier:sendHeaderIdentifier];
    [_tableView registerClass:[STReceiveHeaderView class] forHeaderFooterViewReuseIdentifier:receiveHeaderIdentifier];
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 44.0f, IPHONE_WIDTH, 0.5f)];
    lineView.backgroundColor = RGBFromHex(0xb2b2b2);
    [self.view addSubview:lineView];
    
    continueSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    continueSendButton.backgroundColor = RGBFromHex(0x01cc99);
    continueSendButton.layer.cornerRadius = 3.0f;
    continueSendButton.frame = CGRectMake((IPHONE_WIDTH - 180.0f) / 2.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 39.0f, 180.0f, 36.0f);
    [continueSendButton setTitle:NSLocalizedString(@"继续发送文件", nil) forState:UIControlStateNormal];
    continueSendButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [continueSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueSendButton addTarget:self action:@selector(continueSendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueSendButton];
    
    if (self.isFromReceive && !self.isMultipeerTransfer) {
        /*
        BOOL hotspotEnable = [UIDevice isPersonalHotspotEnabled];
        if ([ZZReachability shareInstance].currentReachabilityStatus != ReachableViaWiFi && !hotspotEnable) {
            if (!popupView) {
                popupView = [[STWifiNotConnectedPopupView2 alloc] init];
            }
            [popupView showInView:self.navigationController.view];
            
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:kHTReachabilityChangedNotification object:nil];
        }*/
    } else {
        // 对方退出共享网络通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceNotConnectedNotification:) name:KDeviceNotConnectedNotification object:nil];
    }
    
    [[STMultiPeerTransferModel shareInstant] addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    
    if (self.isMultipeerTransfer) {
        _model = [STMultiPeerTransferModel shareInstant];
    } else {
        _model = [STFileTransferModel shareInstant];
    }
    
    _model.delegate = self;
    [_model addObserver:self forKeyPath:@"transferFiles" options:NSKeyValueObservingOptionNew context:NULL];
    
    _model.sectionTransferFiles = [_model sortTransferInfo:_model.transferFiles];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
	
    if (self.isFromReceive) {
		// 启动webserver
		//[[STWebServerModel shareInstant] startWebServer];
		
        // 开始发送udp广播
        //[[STFileReceiveModel shareInstant] startBroadcast];
        
        // 开始监听udp广播
        //[[STFileTransferModel shareInstant] startListenBroadcast];
    }
}

- (void)setupNoDiskSpaceAlertView {
    if (!noDiskSpaceAlertView) {
        noDiskSpaceAlertView = [[UIView alloc] init];
        noDiskSpaceAlertView.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR);
        noDiskSpaceAlertView.backgroundColor = [UIColor whiteColor];
        [self.view insertSubview:noDiskSpaceAlertView aboveSubview:self.tableView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = RGB(26,194,155);
        imageView.layer.cornerRadius = 10;
        imageView.frame = CGRectMake((IPHONE_WIDTH - 280) / 2.0, 60, 280, 39);
        [noDiskSpaceAlertView addSubview:imageView];
        
        UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"传输空间对话框0"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 100, 30, 100)]];
        imageView2.top = imageView.bottom - 2;
        imageView2.left = imageView.right - 48;
        [noDiskSpaceAlertView addSubview:imageView2];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, imageView.width, 19)];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor whiteColor];
        label.text = @"本机可用容量少于300M，无法接收";
        label.textAlignment = NSTextAlignmentCenter;
        [imageView addSubview:label];
        
        UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_jiqiren2"]];
        imageView3.centerX = IPHONE_WIDTH / 2.0;
        imageView3.top = imageView.bottom + 30;
        [noDiskSpaceAlertView addSubview:imageView3];

    }
    
    noDiskSpaceAlertView.hidden = NO;
}


- (void)reachabilityStatusChange:(NSNotification *)notification {
    NetworkStatus status = [ZZReachability shareInstance].currentReachabilityStatus;
    switch (status) {
        case ReachableViaWiFi: {
            if (popupView) {
                [popupView removeFromSuperview];
                popupView = nil;
            }
        }
            break;
        default:
            return;
    }
}

- (void)shouldReceiveFile:(BOOL)flag {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!flag) {
            [self setupNoDiskSpaceAlertView];
        } else {
            noDiskSpaceAlertView.hidden = YES;
        }
    });
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"transferFiles"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _model.sectionTransferFiles = [_model sortTransferInfo:_model.transferFiles];
            [self.tableView reloadData];
        });
    } else if ([keyPath isEqualToString:@"state"]) {
        if ([STMultiPeerTransferModel shareInstant].state == STMultiPeerStateNotConnected) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showDeviceNotConnectedAlertWithName:[STMultiPeerTransferModel shareInstant].deviceInfo.deviceName];
                
                // 连接失败，停止广播和监听，需要重新扫描连接
                [[STMultiPeerTransferModel shareInstant] cancelAllTransferFile];
                [[STFileTransferModel shareInstant] cancelAllTransferFile];
            });
        }
    }
}

- (void)showDeviceNotConnectedAlertWithName:(NSString *)name {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.mode = MBProgressHUDModeText;
    HUD.detailsLabelText = [NSString stringWithFormat:@"%@%@", name, NSLocalizedString(@"已退出共享网络", nil)];
    HUD.detailsLabelFont = [UIFont boldSystemFontOfSize:16.f];
    HUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:2.5f];
}

- (void)deviceNotConnectedNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showDeviceNotConnectedAlertWithName:[notification.userInfo stringForKey:DEVICE_NAME]];
    });
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)continueSendButtonClick {
    if (self.isFromReceive) {
        STHomeViewController *homeVc = (STHomeViewController *)self.navigationController.viewControllers.firstObject;
        [homeVc transferButtonClick];
    } else {
         [self.navigationController popToViewController:self.fileSelectionTabController animated:YES];
    }
}

- (void)openContactWithTransferInfo:(STFileTransferInfo *)info {
    if (info.fileType == STFileTypeContact) {
        
        CFDataRef vCardData = nil;
        ABAddressBookRef book = ABAddressBookCreate();
        
        if (info.transferType == STFileTransferTypeSend && info.url.integerValue > 0) {
            ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(book, (ABRecordID)info.url.integerValue);
            CFArrayRef cfArrayRef =  (__bridge CFArrayRef)@[(__bridge id)recordRef];
            vCardData = (CFDataRef)ABPersonCreateVCardRepresentationWithPeople(cfArrayRef);
        } else if (info.transferType == STFileTransferTypeReceive) {
            NSString *path = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.vcard", info.identifier]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSData *vcard = [[NSData alloc] initWithContentsOfFile:path];
                vCardData = CFDataCreate(NULL, [vcard bytes], [vcard length]);
            }
        }
        
        if (vCardData) {
            ABAddressBookRef book = ABAddressBookCreate();
            ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
            CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
            if (CFArrayGetCount(vCardPeople) > 0) {
                ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, 0);
                ABPersonViewController *personViewc = [[ABPersonViewController alloc] init];
                personViewc.displayedPerson = person;
                personViewc.allowsEditing = NO;
                personViewc.allowsActions = YES;
                [self.navigationController pushViewController:personViewc animated:YES];
            }
        }
        
    }
}

- (void)openVideoWithTransferInfo:(STFileTransferInfo *)transferInfo {
    if (transferInfo.fileType == STFileTypeVideo) {
        if (transferInfo.url.length > 0 && ![transferInfo.url hasPrefix:@"http://"]) {
            PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[transferInfo.url] options:nil];
            if (savedAssets.count > 0) {
                PHAsset *asset = savedAssets.firstObject;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
                    AVPlayer *videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
                    AVPlayerViewController *playerController = [[AVPlayerViewController alloc]init];
                    playerController.player = videoPlayer;
                    
                    [self presentViewController:playerController animated:YES completion:^{
                        [videoPlayer play];
                    }];
                }];
            }
        } else {
            NSString *path = [[ZZPath downloadPath] stringByAppendingPathComponent:transferInfo.identifier];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSURL *url1 = [NSURL fileURLWithPath:path];
                
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url1];
                AVPlayer *videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
                AVPlayerViewController *playerController = [[AVPlayerViewController alloc]init];
                playerController.player = videoPlayer;
                
                [self presentViewController:playerController animated:YES completion:^{
                    [videoPlayer play];
                }];
            }
        }
        
    }
}

- (void)openOtherFileWithTransferInfo:(STFileTransferInfo *)transferInfo {
    NSString *path = [[ZZPath downloadPath] stringByAppendingPathComponent:transferInfo.identifier];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", transferInfo.identifier, transferInfo.pathExtension]];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
        if ([documentController presentOptionsMenuFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES]) {
            documentController.delegate = self;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"此类文件不支持" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    
    
}

- (void)openImageWithTransferInfo:(STFileTransferInfo *)transferInfo {
    NSMutableArray *temp = [NSMutableArray array];
    MJPhoto *tempPhoto = nil;
    
    for (STFileTransferInfo *info in _model.transferFiles) {
        if (info.fileType == STFileTypePicture && info.transferType == STFileTransferTypeReceive) {
            if (info.url.length > 0 && ![info.url hasPrefix:@"http://"]) {
                PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[info.url] options:nil];
                if (savedAssets.count > 0) {
                    MJPhoto *photo = [[MJPhoto alloc] init];
                    photo.info = info;
                    [temp addObject:photo];
                    
                    if (transferInfo == info) {
                        tempPhoto = photo;
                    }
                }
            } else {
                NSString *path = [[ZZPath downloadPath] stringByAppendingPathComponent:info.identifier];
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    path = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", transferInfo.identifier, transferInfo.pathExtension]];
                }
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    MJPhoto *photo = [[MJPhoto alloc] init];
                    photo.info = info;
                    [temp addObject:photo];
                    
                    if (transferInfo == info) {
                        tempPhoto = photo;
                    }
                }
            }
            
        }
    }
    
    if (temp.count > 0) {
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.photos = temp;
        browser.currentPhotoIndex = [temp indexOfObject:tempPhoto];
        [self.navigationController pushViewController:browser animated:YES];
    }
    
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}
- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.view.frame;
}

//点击预览窗口的“Done”(完成)按钮时调用
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
}

- (void)openButtonClick:(UIButton *)button event:(UIEvent *)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    NSArray *arr = [_model.sectionTransferFiles objectAtIndex:indexPath.section];
    STFileTransferInfo *transferInfo = [arr objectAtIndex:indexPath.row];
    if (transferInfo.fileType == STFileTypeVideo) {
        [self openVideoWithTransferInfo:transferInfo];
    } else if (transferInfo.fileType == STFileTypePicture) {
        [self openImageWithTransferInfo:transferInfo];
    } else if (transferInfo.fileType == STFileTypeContact) {
        [self openContactWithTransferInfo:transferInfo];
    } else {
        [self openOtherFileWithTransferInfo:transferInfo];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _model.sectionTransferFiles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = [_model.sectionTransferFiles objectAtIndex:section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileTransferCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.openButton addTarget:self action:@selector(openButtonClick:event:) forControlEvents:UIControlEventTouchUpInside];
    NSArray *arr = [_model.sectionTransferFiles objectAtIndex:indexPath.section];
    cell.transferInfo = [arr objectAtIndex:indexPath.row];
    [cell configCell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = [_model.sectionTransferFiles objectAtIndex:indexPath.section];
    STFileTransferInfo *info = [arr objectAtIndex:indexPath.row];
    if ([info.pathExtension isEqualToString:@"apk"]) {
        return 123;
    }
    
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *arr = [_model.sectionTransferFiles objectAtIndex:section];
    double fileSize = 0;
    for (STFileTransferInfo *info in arr) {
        fileSize += info.fileSize;
    }
    
    STFileTransferInfo *info = arr.firstObject;
    if (info.transferType == STFileTransferTypeSend) {
        STSendHeaderView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:sendHeaderIdentifier];
        headView.name = info.deviceName;
        headView.filesCount = arr.count;
        headView.fileSize = fileSize;
        
        return headView;
    } else {
        STReceiveHeaderView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:receiveHeaderIdentifier];
        headView.name = info.deviceName;
        headView.filesCount = arr.count;
        headView.fileSize = fileSize;
        return headView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

}

@end
