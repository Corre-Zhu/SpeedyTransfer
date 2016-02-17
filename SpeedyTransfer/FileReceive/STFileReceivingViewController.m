//
//  STFileReceivingViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileReceivingViewController.h"
#import "STWifiNotConnectedPopupView2.h"
#import "STFileReceiveModel.h"
#import "STFileReceiveCell.h"
#import "STContactInfo.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "STHomeViewController.h"
#import <Photos/Photos.h>

static NSString *ReceiveCellIdentifier = @"ReceiveCellIdentifier";

#define ALBUM_TITLE @"点传"

@interface STFileReceivingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    STWifiNotConnectedPopupView2 *popupView;
    UIButton *continueSendButton;
    STFileReceiveModel *model;
    
    STFileReceiveInfo *currentReceiveInfo;
    NSTimeInterval lastTimeInterval;
    NSProgress *currentProgress;
    
    __block PHAssetCollection *collection;
}

@property (nonatomic) BOOL connected;
@property (strong, nonatomic) MCTransceiver *transceiver;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation STFileReceivingViewController

- (void)leftBarButtonItemClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"不再接收其他文件，确认退出？", nil) message:nil preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
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
    self.navigationItem.title = NSLocalizedString(@"接收文件", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR - 44.0f) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[STFileReceiveCell class] forCellReuseIdentifier:ReceiveCellIdentifier];
    _tableView.tableFooterView = [UIView new];
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
    
    model = [STFileReceiveModel shareInstant];
    
    if ([ZZReachability shareInstance].currentReachabilityStatus != ReachableViaWiFi) {
        if (!popupView) {
            popupView = [[STWifiNotConnectedPopupView2 alloc] init];
        }
        [popupView showInView:self.navigationController.view];
    } else {
		
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.transceiver startAdvertising];
}

- (void)continueSendButtonClick {
    STHomeViewController *homeViewC = self.navigationController.viewControllers.firstObject;
    [homeViewC transferButtonClick];
}

#pragma mark - Kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float newProgress = [change floatForKey:NSKeyValueChangeNewKey];
            if (newProgress - currentReceiveInfo.progress > 0.02f || newProgress == 1.0f) {
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval timeInterval = now - lastTimeInterval;
                if (timeInterval != 0.0f) {
                    currentReceiveInfo.sizePerSecond = 1 / timeInterval * (newProgress - currentReceiveInfo.progress) * currentReceiveInfo.fileSize;
                }
                currentReceiveInfo.progress = newProgress;
                lastTimeInterval = now;
                NSInteger index = [model.receiveFiles indexOfObject:currentReceiveInfo];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                NSLog(@"%f", currentReceiveInfo.progress);
            }
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return model.receiveFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileReceiveCell *cell = [tableView dequeueReusableCellWithIdentifier:ReceiveCellIdentifier forIndexPath:indexPath];
    cell.transferInfo = [model.receiveFiles objectAtIndex:indexPath.row];
    [cell configCell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 92.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileTransferInfo *info = [model.receiveFiles objectAtIndex:indexPath.row];
    if (info.type == STFileTransferTypeContact) {
        NSData *vcard = [info.vcardString dataUsingEncoding:NSUTF8StringEncoding];
        CFDataRef vCardData = CFDataCreate(NULL, [vcard bytes], [vcard length]);
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

#pragma mark - MCTransceiverDelegate

-(void)didFindPeer:(MCPeerID *)peerID
{
    NSLog(@"----> did find peer %@", peerID);
}

-(void)didLosePeer:(MCPeerID *)peerID
{
    NSLog(@"<---- did lose peer %@", peerID);
}

- (BOOL)connectWithPeer:(MCPeerID *)peerId {
    return !_connected;
}

-(void)didReceiveInvitationFromPeer:(MCPeerID *)peerID
{
    NSLog(@"!!!!! did get invite from peer %@", peerID);
}

-(void)didConnectToPeer:(MCPeerID *)peerID
{
    NSLog(@">>>>> did connect to peer %@", peerID);
    _connected = YES;
    [self.transceiver stopAdvertising];
}

-(void)didDisconnectFromPeer:(MCPeerID *)peerID
{
    NSLog(@"<<<<< did disconnect from peer %@", peerID);
    _connected = NO;
    [self.transceiver startAdvertising];
}

-(void)didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [model saveContactInfo:data];
        [self.tableView reloadData];
    });
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        currentReceiveInfo = [model savePicture:resourceName size:progress.totalUnitCount];
        [self.tableView reloadData];
        
        currentProgress = progress;
        [currentProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    });
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    if (!localURL) {
        return;
    }
    
    NSString *destinationPath = [[ZZPath picturePath] stringByAppendingPathComponent:resourceName];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *copyError;
    [fileManager copyItemAtURL:localURL toURL:destinationURL error:&copyError];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    __block PHFetchResult *photosAsset;
    __block PHObjectPlaceholder *placeholder;
    
    dispatch_block_t block = ^ {
        // Save to the album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:destinationURL];
            placeholder = [assetRequest placeholderForCreatedAsset];
            photosAsset = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection
                                                                                                                          assets:photosAsset];
            [albumChangeRequest addAssets:@[placeholder]];
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    currentReceiveInfo.url = placeholder.localIdentifier;
                    [model updateWithUrl:placeholder.localIdentifier identifier:currentReceiveInfo.identifier];
                    [self.tableView reloadData];
                    NSLog(@"%@", placeholder.localIdentifier);
                } else {
                    NSLog(@"%@", error);
                }
            });
        }];
    };
    
    // Find the album
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", ALBUM_TITLE];
    collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                          subtype:PHAssetCollectionSubtypeAny
                                                          options:fetchOptions].firstObject;
    // Create the album
    if (!collection)
    {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *createAlbum = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:ALBUM_TITLE];
            placeholder = [createAlbum placeholderForCreatedAssetCollection];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success)
            {
                PHFetchResult *collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[placeholder.localIdentifier]
                                                                                                            options:nil];
                collection = collectionFetchResult.firstObject;
                block();
            }
        }];
    } else {
        block();
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        if (!error) {
            [model updateStatus:STFileReceiveStatusReceived rate:currentReceiveInfo.sizePerSecond withIdentifier:currentReceiveInfo.identifier];
            currentReceiveInfo.status = STFileReceiveStatusReceived;
            [self.tableView reloadData];
        } else {
           [model updateStatus:STFileReceiveStatusReceiveFailed rate:currentReceiveInfo.sizePerSecond withIdentifier:currentReceiveInfo.identifier];
            currentReceiveInfo.status = STFileReceiveStatusReceiveFailed;
            [self.tableView reloadData];
        }
    });
}

-(void)didStartAdvertising
{
    NSLog(@"+++++ did start advertising");
}

-(void)didStopAdvertising
{
    NSLog(@"----- did stop advertising");
}

-(void)didStartBrowsing
{
    NSLog(@"((((( did start browsing");
}

-(void)didStopBrowsing
{
    NSLog(@"))))) did stop browsing");
}


@end
