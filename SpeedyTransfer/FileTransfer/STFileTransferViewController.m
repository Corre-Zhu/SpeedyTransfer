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

static NSString *cellIdentifier = @"CellIdentifier";

@interface STFileTransferViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *continueSendButton;
    STFileTransferInfo *currentTransferInfo;
    NSTimeInterval lastTimeInterval;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) STFileTransferModel *model;

@end

@implementation STFileTransferViewController

- (void)leftBarButtonItemClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"不再发送其他文件，确认退出？", nil) message:nil preferredStyle: UIAlertControllerStyleAlert];
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
    self.navigationItem.title = NSLocalizedString(@"发送文件", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR - 44.0f) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[STFileTransferCell class] forCellReuseIdentifier:cellIdentifier];
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
    
    _model = [[STFileTransferModel alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startSendFile];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float newProgress = [change floatForKey:NSKeyValueChangeNewKey];
            if (newProgress - currentTransferInfo.progress > 0.02f || newProgress == 1.0f) {
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval timeInterval = now - lastTimeInterval;
                if (timeInterval != 0.0f) {
                    currentTransferInfo.sizePerSecond = 1 / timeInterval * (newProgress - currentTransferInfo.progress) * currentTransferInfo.fileSize;
                }
                currentTransferInfo.progress = newProgress;
                lastTimeInterval = now;
                NSInteger index = [_model.transferFiles indexOfObject:currentTransferInfo];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                NSLog(@"%f", currentTransferInfo.progress);
            }
           
        });
    }
}

- (void)startSendFile {
    // 发送图片
    if (self.fileSelectionTabController.selectedAssetsArr.count > 0) {
        PHAsset *sendAsset = self.fileSelectionTabController.selectedAssetsArr.firstObject;
        [self.fileSelectionTabController removeAsset:sendAsset];
        [self.fileSelectionTabController reloadAssetsTableView];
        [[PHImageManager defaultManager] requestImageDataForAsset:sendAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
            NSString *path = [[ZZPath picturePath] stringByAppendingPathComponent:[url.absoluteString lastPathComponent]];
            [imageData writeToFile:path atomically:YES];
            currentTransferInfo = [_model saveAssetWithIdentifier:sendAsset.localIdentifier fileName:[url.absoluteString lastPathComponent] length:imageData.length forKey:nil];
            [self.tableView reloadData];
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(currentTransferInfo) weakInfo = currentTransferInfo;
            
            lastTimeInterval = [[NSDate date] timeIntervalSince1970];
            NSProgress *progress = [self.transceiver sendResourceAtURL:[NSURL fileURLWithPath:path] withName:[url.absoluteString lastPathComponent] toPeer:self.transceiver.connectedPeers.firstObject withCompletionHandler:^(NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
                    if (!error) {
                        weakInfo.status = STFileTransferStatusSucceed;
                        [weakSelf.model updateStatus:STFileTransferStatusSucceed rate:weakInfo.sizePerSecond withIdentifier:weakInfo.identifier];
                        [weakSelf.tableView reloadData];
                    } else {
                        weakInfo.status = STFileTransferStatusFailed;
                        [weakSelf.model updateStatus:STFileTransferStatusFailed rate:weakInfo.sizePerSecond withIdentifier:weakInfo.identifier];
                        [weakSelf.tableView reloadData];
                    }
                    
                    [self startSendFile];
                });
            }];
            
            [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        }];
    }
    
    // 发送音乐
    if (self.fileSelectionTabController.selectedMusicsArr.count > 0) {
        STMusicInfo *musicInfo = self.fileSelectionTabController.selectedMusicsArr.firstObject;
        [self.fileSelectionTabController removeMusic:musicInfo];
        [self.fileSelectionTabController reloadMusicsTableView];
        
        [self.transceiver sendResourceAtURL:musicInfo.url withName:@"sdfsdfsdf.sdf" toPeer:self.transceiver.connectedPeers.firstObject withCompletionHandler:^(NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [self startSendFile];
            });
        }];
    }
    
    // 发送联系人
    if (self.fileSelectionTabController.selectedContactsArr.count > 0) {
        STContactInfo *contact = self.fileSelectionTabController.selectedContactsArr.firstObject;
        NSData *data = [contact.vcardString dataUsingEncoding:NSUTF8StringEncoding];
        if (data.length > 0) {
            STFileTransferInfo *info = [_model setContactInfo:contact forKey:nil];
            [self.tableView reloadData];
            NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
            [self.transceiver sendUnreliableData:data toPeers:self.transceiver.connectedPeers completion:^(NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                    info.status = STFileTransferStatusFailed;
                    [_model updateStatus:info.status rate:0 withIdentifier:info.identifier];
                } else {
                    NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
                    info.sizePerSecond = 1 / (end - start) * data.length;
                    info.status = STFileTransferStatusSucceed;
                    info.progress = 1.0f;
                    [_model updateStatus:info.status rate:info.sizePerSecond withIdentifier:info.identifier];
                }
                [self.tableView reloadData];
                [self.fileSelectionTabController removeContact:contact];
                [self.fileSelectionTabController reloadContactsTableView];
                [self startSendFile];
            }];
        } else {
            [self.fileSelectionTabController removeContact:contact];
            [self.fileSelectionTabController reloadContactsTableView];
            [self startSendFile];
        }
    }
}

- (void)continueSendButtonClick {
    [self.navigationController popToViewController:self.fileSelectionTabController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _model.transferFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileTransferCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.transferInfo = [_model.transferFiles objectAtIndex:indexPath.row];
    [cell configCell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 92.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileTransferInfo *info = [_model.transferFiles objectAtIndex:indexPath.row];
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

@end
