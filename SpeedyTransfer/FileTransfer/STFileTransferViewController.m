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
    
    _model = [STFileTransferModel shareInstant];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.fileSelectionTabController.sendingFile) {
        [self.fileSelectionTabController startSendFile];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float newProgress = [change floatForKey:NSKeyValueChangeNewKey];
            if (newProgress - currentTransferInfo.progress > 0.02f || newProgress == 1.0f) {
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval timeInterval = now - lastTimeInterval;
                if (timeInterval != 0.0f) {
                    currentTransferInfo.downloadSpeed = 1 / timeInterval * (newProgress - currentTransferInfo.progress) * currentTransferInfo.fileSize;
                }
                currentTransferInfo.progress = newProgress;
                lastTimeInterval = now;
//                NSInteger index = [_model.transferFiles indexOfObject:currentTransferInfo];
//                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                NSLog(@"%f", currentTransferInfo.progress);
            }
           
        });
    }
}



- (void)continueSendButtonClick {
    [self.navigationController popToViewController:self.fileSelectionTabController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;//_model.transferFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileTransferCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.transferInfo = [_model.transferFiles objectAtIndex:indexPath.row];
    [cell configCell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 92.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileTransferInfo *info = nil;//[_model.transferFiles objectAtIndex:indexPath.row];
    if (info.fileType == STFileTypeContact) {
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
