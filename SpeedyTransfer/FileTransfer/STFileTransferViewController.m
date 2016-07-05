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
#import "STMusicInfo.h"
#import "STFileTransferModel.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Photos/Photos.h>
#import "STSendHeaderView.h"
#import "STReceiveHeaderView.h"
#import "STWifiNotConnectedPopupView2.h"
#import "MBProgressHUD.h"
#import "STHomeViewController.h"
#import "STWebServerModel.h"

static NSString *sendHeaderIdentifier = @"sendHeaderIdentifier";
static NSString *receiveHeaderIdentifier = @"receiveHeaderIdentifier";
static NSString *cellIdentifier = @"CellIdentifier";

@interface STFileTransferViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    STWifiNotConnectedPopupView2 *popupView;

    UIButton *continueSendButton;
    STFileTransferInfo *currentTransferInfo;
    NSTimeInterval lastTimeInterval;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) STFileTransferModel *model;

@end

@implementation STFileTransferViewController

- (void)dealloc {
    [_model removeObserver:self forKeyPath:@"transferFiles"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)leftBarButtonItemClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"不再传输其它文件，确认退出？", nil) message:nil preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[STFileTransferModel shareInstant] cancelAllTransferFile];
        [[STFileTransferModel shareInstant] removeAllSelectedDevices];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertController addAction:action1];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:NULL];
    [alertController addAction:action3];
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
    [continueSendButton setBackgroundImage:[[UIImage imageNamed:@"xuanze_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0f, 7.0f, 7.0f, 7.0f)] forState:UIControlStateNormal];
    continueSendButton.frame = CGRectMake((IPHONE_WIDTH - 180.0f) / 2.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 39.0f, 180.0f, 36.0f);
    [continueSendButton setTitle:NSLocalizedString(@"继续发送文件", nil) forState:UIControlStateNormal];
    continueSendButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [continueSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueSendButton addTarget:self action:@selector(continueSendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueSendButton];
    
    if (self.isFromReceive) {
        BOOL hotspotEnable = [UIDevice isPersonalHotspotEnabled];
        if ([ZZReachability shareInstance].currentReachabilityStatus != ReachableViaWiFi && !hotspotEnable) {
            if (!popupView) {
                popupView = [[STWifiNotConnectedPopupView2 alloc] init];
            }
            [popupView showInView:self.navigationController.view];
            
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:kHTReachabilityChangedNotification object:nil];
        }
    } else {
        // 对方退出共享网络通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceNotConnectedNotification:) name:KDeviceNotConnectedNotification object:nil];
    }
    
    
    _model = [STFileTransferModel shareInstant];
    [_model addObserver:self forKeyPath:@"transferFiles" options:NSKeyValueObservingOptionNew context:NULL];
    
    _model.sectionTransferFiles = [_model sortTransferInfo:_model.transferFiles];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
	
	// 启动webserver
	if (![[STWebServerModel shareInstant] isWebServerRunning]) {
		[[STWebServerModel shareInstant] startWebServer];
	}
	
    if (self.isFromReceive) {
        // 开始发送udp广播
        [[STFileReceiveModel shareInstant] startBroadcast];
    }
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"transferFiles"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _model.sectionTransferFiles = [_model sortTransferInfo:_model.transferFiles];
            [self.tableView reloadData];
        });
    }
}

- (void)deviceNotConnectedNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *deviceName = [notification.userInfo stringForKey:DEVICE_NAME];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = [NSString stringWithFormat:@"%@%@", deviceName, NSLocalizedString(@"已退出共享网络", nil)];
        HUD.removeFromSuperViewOnHide = YES;
        [self.view addSubview:HUD];
        [HUD show:YES];
        [HUD hide:YES afterDelay:2.5f];
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
    NSArray *arr = [_model.sectionTransferFiles objectAtIndex:indexPath.section];
    cell.transferInfo = [arr objectAtIndex:indexPath.row];
    [cell configCell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 92.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
     NSArray *arr = [_model.sectionTransferFiles objectAtIndex:section];
    STFileTransferInfo *info = arr.firstObject;
    if (info.transferType == STFileTransferTypeSend) {
        STSendHeaderView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:sendHeaderIdentifier];
        headView.transferInfo = info;
        return headView;
    } else {
        STReceiveHeaderView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:receiveHeaderIdentifier];
        headView.transferInfo = info;
        return headView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = [_model.sectionTransferFiles objectAtIndex:indexPath.section];
    STFileTransferInfo *info = [arr objectAtIndex:indexPath.row];
    if (info.fileType == STFileTypeContact) {
        
        CFDataRef vCardData;
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

@end
