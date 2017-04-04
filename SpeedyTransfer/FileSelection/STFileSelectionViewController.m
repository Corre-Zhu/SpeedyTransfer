//
//  STFileSelectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/18.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STFileSelectionViewController.h"
#import "STFileSegementControl.h"
#import "STPictureCollectionViewController.h"
#import "STVideoSelectionViewController.h"
#import "STContactsSelectionViewController.h"
#import "STFilesViewController.h"
#import <Photos/Photos.h>
#import "STMusicInfo.h"
#import "STWifiNotConnectedPopupView.h"
#import "STTransferInstructionViewController.h"
#import "STFileTransferViewController.h"
#import "STFileTransferModel.h"
#import "STContactInfo.h"
#import "STDeviceInfo.h"
#import "STWebServerModel.h"
#import "STEstablishConnectViewController.h"
#import "UIViewController+ZZ.h"

@interface STFileSelectionViewController ()<STFileSegementControlDelegate,UIScrollViewDelegate> {
    STFileSegementControl *segementControl;
    UIScrollView *scrollView;
    
    NSArray *childViewControllers;
    NSArray *titles;
    
    UIImageView *toolView;
    UIButton *deleteButton;
    UIButton *transferButton;
    STWifiNotConnectedPopupView *wifiNotConnectedPopupView;
}

@end

@implementation STFileSelectionViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[STFileTransferModel shareInstant] cancelAllTransferFile];
    [[STMultiPeerTransferModel shareInstant] cancelAllTransferFile];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    segementControl = [[STFileSegementControl alloc] init];
    segementControl.delegate = self;
    [self.view addSubview:segementControl];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, segementControl.bottom, IPHONE_WIDTH, IPHONE_HEIGHT - segementControl.height)];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(IPHONE_WIDTH * 4, IPHONE_HEIGHT - segementControl.height - 5);
    scrollView.directionalLockEnabled = YES;
    scrollView.delegate = self;
    scrollView.bounces = YES;
    [self.view addSubview:scrollView];
    
    STPictureCollectionViewController *picVC = [[STPictureCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    STVideoSelectionViewController *videoVC = [[STVideoSelectionViewController alloc] init];
    STContactsSelectionViewController *contactVC = [[STContactsSelectionViewController alloc] init];
    STFilesViewController *fileVC = [[STFilesViewController alloc] init];

    childViewControllers = @[picVC, videoVC, contactVC,fileVC];
    titles = @[@"选择图片", @"选择视频", @"选择联系人", @"选择文件"];

    [segementControl setSelectedIndex:0];
    
    toolView = [[UIImageView alloc] initWithFrame:CGRectMake(0, IPHONE_HEIGHT - 49, IPHONE_WIDTH, 49.0f)];
    toolView.userInteractionEnabled = YES;
    toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolView];
    toolView.hidden = YES;
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(0, 0, IPHONE_WIDTH / 2.0, 49.0f);
    [deleteButton setImage:[UIImage imageNamed:@"ic_quxiao"] forState:UIControlStateNormal];
    [deleteButton setTitle:@"取消选择" forState:UIControlStateNormal];
    [deleteButton setTitleColor:RGBFromHex(0xe09e2c) forState:UIControlStateNormal];
    [deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:deleteButton];
    
    transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
    transferButton.frame = CGRectMake(IPHONE_WIDTH / 2.0, 0, IPHONE_WIDTH / 2.0, 49);
    [transferButton setImage:[UIImage imageNamed:@"ic_next"] forState:UIControlStateNormal];
    [transferButton addTarget:self action:@selector(transferButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [transferButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateNormal];
    transferButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [transferButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
    [toolView addSubview:transferButton];
    
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, 0.5)];
    lineView.backgroundColor = RGBFromHex(0xbdbdbd);
    [toolView addSubview:lineView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:kHTReachabilityChangedNotification object:nil];
    
    // 启动webserver
    //[[STWebServerModel shareInstant] startWebServer];
    
    // 开始发送udp广播
    //[[STFileReceiveModel shareInstant] startBroadcast];
    
    // 开始监听udp广播
    //[[STFileTransferModel shareInstant] startListenBroadcast];
}

- (void)didTapBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectIndex:(NSInteger)index {
    UIViewController *viewController = [childViewControllers objectAtIndex:index];

    if (!viewController.view.superview) {
        [self addChildViewController:viewController];
        [scrollView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        viewController.view.frame = scrollView.bounds;
        viewController.view.left = index * IPHONE_WIDTH;
    }
    
    if (scrollView.contentOffset.x != index * IPHONE_WIDTH) {
        scrollView.contentOffset = CGPointMake(index * IPHONE_WIDTH, 0);
    }
    
    [segementControl setTitle:titles[index]];
    
    [self.view bringSubviewToFront:toolView];
}

/*
- (void)autoLayoutChildViewController:(UIViewController *)childViewController {
    [childViewController.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:segementControl withOffset:0.0f];
    [childViewController.view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [childViewController.view autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [childViewController.view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
}
 */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:NSClassFromString(@"STHomeViewController")]) {
        return;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)configToolView {
    NSInteger count = 0;
    for (NSDictionary *dic in self.selectedAssetsArr) {
        if ([dic.allValues.firstObject count] > 0) {
            count += [dic.allValues.firstObject count];
        }
    }
    
    if (self.selectedVideoAssetsArr.count > 0) {
        count += self.selectedVideoAssetsArr.count;
    }
    
    if (self.selectedContactsArr.count > 0) {
        count += self.selectedContactsArr.count;
    }
    
    if (count > 0) {
        [transferButton setTitle:[NSString stringWithFormat:@"%@ ( %@ )", NSLocalizedString(@"下一步", nil), @(count)] forState:UIControlStateNormal];
        toolView.hidden = NO;
        [self.view bringSubviewToFront:toolView];
        
    } else {
        toolView.hidden = YES;
    }
    
    [childViewControllers makeObjectsPerformSelector:@selector(setContentInset:) withObject:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 0, count > 0 ? 49 : 0, 0)]];

}

- (void)photoLibraryDidChange {
    
}

- (void)deleteButtonClick {
    [self removeAllSelectedFiles];
}

- (void)reachabilityStatusChange:(NSNotification *)notification {
    NetworkStatus status = [ZZReachability shareInstance].currentReachabilityStatus;
    switch (status) {
        case ReachableViaWiFi: {
            if ([wifiNotConnectedPopupView isShow]) {
                [wifiNotConnectedPopupView removeFromSuperview];
                [self transferButtonClick];
            }
        }
            break;
            
        default:
            return;
    }
}

- (void)transferButtonClick {
    // 如果只发现一台设备，直接选择这台设备
    if ([STFileTransferModel shareInstant].selectedDevicesArray.count == 0 && [STFileTransferModel shareInstant].devicesArray.count >= 1) {
        STDeviceInfo *deviceInfo = [[STFileTransferModel shareInstant].devicesArray firstObject];
        [STFileTransferModel shareInstant].selectedDevicesArray = [NSArray arrayWithObject:deviceInfo];
    }
    
    if ([STFileTransferModel shareInstant].selectedDevicesArray.count > 0) {
        if ([[STWebServerModel shareInstant] isWebServer2Running]) {
            // 无界传送条件下，调用STTransferInstructionViewController设置网页参数
            STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
            [transferIns setupVariablesAndStartWebServer:[self allSelectedFiles]];
        }
        
        [[STFileTransferModel shareInstant] sendItems:[self allSelectedFiles]];
        [self removeAllSelectedFiles];
        
        STFileTransferViewController *fileTransferVc = [[STFileTransferViewController alloc] init];
        [self.navigationController pushViewController:fileTransferVc animated:YES];
    } else if ([STMultiPeerTransferModel shareInstant].state == STMultiPeerStateConnected) {
        [[STMultiPeerTransferModel shareInstant] addSendItems:[self.fileSelectionTabController allSelectedFiles]];
        [self.fileSelectionTabController removeAllSelectedFiles];
        
        STFileTransferViewController *fileTransferVc = [[STFileTransferViewController alloc] init];
        fileTransferVc.isMultipeerTransfer = YES;
        [self.navigationController pushViewController:fileTransferVc animated:YES];
    } else {
        STEstablishConnectViewController *vc = [[STEstablishConnectViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        //STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
        //[self.navigationController pushViewController:transferIns animated:YES];
    }
    /*
    BOOL hotspotEnable = [UIDevice isPersonalHotspotEnabled];
    if ([ZZReachability shareInstance].currentReachabilityStatus != ReachableViaWiFi && !hotspotEnable) {
        if (!wifiNotConnectedPopupView) {
            wifiNotConnectedPopupView = [[STWifiNotConnectedPopupView alloc] init];
        }
        [wifiNotConnectedPopupView showInView:self.navigationController.view];
        
    } else {
        // 如果只发现一台设备，直接选择这台设备
        if ([STFileTransferModel shareInstant].selectedDevicesArray.count == 0 && [STFileTransferModel shareInstant].devicesArray.count == 1) {
            STDeviceInfo *deviceInfo = [[STFileTransferModel shareInstant].devicesArray firstObject];
            [STFileTransferModel shareInstant].selectedDevicesArray = [NSArray arrayWithObject:deviceInfo];
        }
        
        // 已经选择好设备的情况下直接进入发送界面
        if ([STFileTransferModel shareInstant].selectedDevicesArray.count > 0) {
            if ([[STWebServerModel shareInstant] isWebServer2Running]) {
                // 无界传送条件下，调用STTransferInstructionViewController设置网页参数
                STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
                [transferIns setupVariablesAndStartWebServer:[self allSelectedFiles]];
            }
            
            [[STFileTransferModel shareInstant] sendItems:[self allSelectedFiles]];
            [self removeAllSelectedFiles];
            
            STFileTransferViewController *fileTransferVc = [[STFileTransferViewController alloc] init];
            [self.navigationController pushViewController:fileTransferVc animated:YES];
        } else {
            STTransferInstructionViewController *transferIns = [[STTransferInstructionViewController alloc] init];
            [self.navigationController pushViewController:transferIns animated:YES];
        }
        
    }
     */
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollV {
    [segementControl setSelectedIndex:scrollView.contentOffset.x / IPHONE_WIDTH];
}

#pragma mark - Send file

#pragma mark - Reload table view

- (void)reloadAssetsTableView {
    UICollectionViewController *viewC = childViewControllers[0];
    [viewC.collectionView reloadData];
}

- (void)reloadVideosTableView {
    UITableViewController *viewC = childViewControllers[1];
    [viewC.tableView reloadData];
}

- (void)reloadContactsTableView {
    UITableViewController *viewC = childViewControllers[2];
    [viewC.tableView reloadData];
}

- (void)reloadFilesTableView {
    UITableViewController *viewC = childViewControllers[3];
    [viewC.tableView reloadData];
}

#pragma mark - All files handle

- (void)selectedFilesCountChanged {
    [self configToolView];
}

- (NSArray *)allSelectedFiles {
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *dic in self.selectedAssetsArr) {
        if ([dic.allValues.firstObject count] > 0) {
            [array addObjectsFromArray:dic.allValues.firstObject];
        }
    }
    
    if (self.selectedVideoAssetsArr.count > 0) {
        [array addObjectsFromArray:self.selectedVideoAssetsArr];
    }
    
    if (self.selectedContactsArr.count > 0) {
        [array addObjectsFromArray:self.selectedContactsArr];
    }
    
    return array;
}

- (void)removeAllSelectedFiles {
    if (_selectedAssetsArr.count > 0) {
        [_selectedAssetsArr removeAllObjects];
        [self reloadAssetsTableView];
    }
    
    if (_selectedVideoAssetsArr.count > 0) {
        [_selectedVideoAssetsArr removeAllObjects];
        [self reloadVideosTableView];
    }
    
    if (_selectedContactsArr.count > 0) {
        [_selectedContactsArr removeAllObjects];
        [self reloadContactsTableView];
    }
    
    [self selectedFilesCountChanged];
}

#pragma mark - Picture

- (void)addAsset:(PHAsset *)asset inCollection:(NSString *)collection {
    if (!asset || !collection) {
        return;
    }
    
    if (!_selectedAssetsArr) {
        _selectedAssetsArr = [NSMutableArray array];
    }
    
    BOOL collectionExist = NO;
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            if (![arr containsObject:asset]) {
                [arr addObject:asset];
            }
            collectionExist = YES;
            break;
        }
    }
    
    if (!collectionExist) {
        [_selectedAssetsArr addObject:@{collection: [NSMutableArray arrayWithObject:asset]}];
    }
    
    [self selectedFilesCountChanged];
    
}

- (void)addAssets:(NSArray *)assets inCollection:(NSString *)collection {
    if (!assets || !collection) {
        return;
    }
    
    if (!_selectedAssetsArr) {
        _selectedAssetsArr = [NSMutableArray array];
    }
    
    BOOL collectionExist = NO;
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            [arr addObjectsFromArray:assets];
            collectionExist = YES;
            break;
        }
    }
    
    if (!collectionExist) {
        [_selectedAssetsArr addObject:@{collection: [NSMutableArray arrayWithArray:assets]}];
    }
    
    [self selectedFilesCountChanged];
    
}

- (void)removeAsset:(PHAsset *)asset inCollection:(NSString *)collection {
    if (!asset || !collection) {
        return;
    }
    
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            [arr removeObject:asset];
            break;
        }
    }
    
    [self selectedFilesCountChanged];
    
}

- (void)removeAssets:(NSArray *)assets inCollection:(NSString *)collection {
    if (!assets || !collection) {
        return;
    }
    
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            [arr removeObjectsInArray:assets];
            break;
        }
    }
    
    [self selectedFilesCountChanged];
    
}

- (void)removeAllAssetsInCollection:(NSString *)collection {
    if (!collection) {
        return;
    }
    
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            [arr removeAllObjects];
            break;
        }
    }
    
    [self selectedFilesCountChanged];
    
}

- (BOOL)isSelectedWithAsset:(PHAsset *)asset inCollection:(NSString *)collection{
    if (!asset || !collection) {
        return NO;
    }
    
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            return [arr containsObject:asset];
        }
    }
    
    return NO;
}

- (NSInteger)selectedPhotosCountInCollection:(NSString *)collection {
    NSInteger count = 0;
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            count += [dic.allValues.firstObject count];
            break;
        }
    }
    
    return count;
}

#pragma mark - Video

- (void)addVideoAsset:(PHAsset *)asset {
    if (!asset) {
        return;
    }
    
    if (!_selectedVideoAssetsArr) {
        _selectedVideoAssetsArr = [NSMutableOrderedSet orderedSet];
    }
    
    if (![_selectedVideoAssetsArr containsObject:asset]) {
        [_selectedVideoAssetsArr addObject:asset];
    }
    
    [self selectedFilesCountChanged];
    
}

- (void)addVideoAssets:(NSArray *)assets {
    if (!assets) {
        return;
    }
    
    if (!_selectedVideoAssetsArr) {
        _selectedVideoAssetsArr = [NSMutableOrderedSet orderedSet];
    }
    
    [_selectedVideoAssetsArr addObjectsFromArray:assets];
    
    [self selectedFilesCountChanged];
}

- (void)removeVideoAsset:(PHAsset *)asset {
    if (!asset) {
        return;
    }
    
    if ([_selectedVideoAssetsArr containsObject:asset]) {
        [_selectedVideoAssetsArr removeObject:asset];
    }
    
    [self selectedFilesCountChanged];
    
}

- (void)removeAllVideoAssets {
    [_selectedVideoAssetsArr removeAllObjects];
    [self selectedFilesCountChanged];
}

- (BOOL)isSelectedWithVideoAsset:(PHAsset *)asset {
    return [_selectedVideoAssetsArr containsObject:asset];
}

#pragma mark - Contacts

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
    
    [self selectedFilesCountChanged];
    
}

- (void)addContacts:(NSArray *)contacts {
    if (!contacts) {
        return;
    }
    
    if (!_selectedContactsArr) {
        _selectedContactsArr = [NSMutableArray array];
    }
    
    [_selectedContactsArr addObjectsFromArray:contacts];
    
    [self selectedFilesCountChanged];
}

- (void)removeContact:(STContactInfo *)contact {
    if (!contact) {
        return;
    }
    
    [_selectedContactsArr removeObject:contact];
    
    [self selectedFilesCountChanged];
}

- (void)removeContacts:(NSArray *)contacts {
    if (!contacts) {
        return;
    }
    
    [_selectedContactsArr removeObjectsInArray:contacts];
    
    [self selectedFilesCountChanged];
}

- (void)removeAllContacts {
    [_selectedContactsArr removeAllObjects];
    [self selectedFilesCountChanged];
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
