//
//  STFileReceivingViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileReceivingViewController.h"
#import "MCTransceiver.h"
#import "STWifiNotConnectedPopupView2.h"
#import "Reachability.h"
#import "STFileReceiveModel.h"
#import "STFileReceiveCell.h"
#import "STContactInfo.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "STHomeViewController.h"

static NSString *ReceiveCellIdentifier = @"ReceiveCellIdentifier";

@interface STFileReceivingViewController ()<MCTransceiverDelegate,UITableViewDataSource,UITableViewDelegate>
{
    STWifiNotConnectedPopupView2 *popupView;
    UIButton *continueSendButton;
    Reachability *reachability;
    STFileReceiveModel *model;
}

@property (nonatomic) BOOL connected;
@property (strong, nonatomic) MCTransceiver *transceiver;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation STFileReceivingViewController

-(void)configureTransceiver {
    _transceiver = [[MCTransceiver alloc] initWithDelegate:self
                                                  peerName:[UIDevice currentDevice].name
                                                      mode:MCTransceiverModeAdvertiser];
}

- (void)backBarButtonItemClick {
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemClick)];
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
    
    if (!reachability) {
        reachability = [Reachability reachabilityForLocalWiFi];
    }
    if (reachability.currentReachabilityStatus != ReachableViaWiFi) {
        if (!popupView) {
            popupView = [[STWifiNotConnectedPopupView2 alloc] init];
        }
        [popupView showInView:self.navigationController.view];
        
    } else {
        [self configureTransceiver];
    }
    
    [UIDevice getWifiName];
    [UIDevice getIpAddresses];
    
    model = [[STFileReceiveModel alloc] init];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.transceiver startAdvertising];
}

- (void)continueSendButtonClick {
    STHomeViewController *homeViewC = self.navigationController.viewControllers.firstObject;
    [homeViewC transferButtonClick];
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
