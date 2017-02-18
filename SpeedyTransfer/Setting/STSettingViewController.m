//
//  STSettingViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/30.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STSettingViewController.h"
#import "STAboutViewController.h"

@interface STSettingViewController ()
{
    
}

@end

@implementation STSettingViewController

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    self.navigationItem.title = NSLocalizedString(@"设置", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
}

- (void)switchValueChanged:(UISwitch *)switc {
    [[NSUserDefaults standardUserDefaults] setBool:switc.on forKey:switc.tag == 0 ? AutoImportPhoto : AutoImportVideo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier1 = @"cellIdentifier1";
    static NSString *cellIdentifier2 = @"cellIdentifier2";
    if (indexPath.row <= 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 11.0f, 200.0f, 19.0f)];
            label1.textColor = RGBFromHex(0x333333);
            label1.font = [UIFont systemFontOfSize:16.0f];
            label1.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:label1];
            label1.tag = 10;
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, label1.bottom + 8.0f, 200.0f, 19.0f)];
            label2.textColor = RGBFromHex(0x333333);
            label2.font = [UIFont systemFontOfSize:14.0f];
            label2.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:label2];
            label2.tag = 11;
            
            UISwitch *swit = [[UISwitch alloc] init];
            swit.left = IPHONE_WIDTH - swit.width - 16.0f;
            swit.centerY = 33.0f;
            [swit addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:swit];
        }
        
        UILabel *label1 = [cell.contentView viewWithTag:10];
        UILabel *label2 = [cell.contentView viewWithTag:11];
        UISwitch *swit = [cell.contentView.subviews lastObject];
        if (indexPath.row == 0) {
            label1.text = NSLocalizedString(@"自动导入图片", nil);
            label2.text = NSLocalizedString(@"导入接收的图片到系统图库", nil);
            swit.on = [[NSUserDefaults standardUserDefaults] boolForKey:AutoImportPhoto];
            swit.tag = 0;
        } else {
            label1.text = NSLocalizedString(@"自动导入视频", nil);
            label2.text = NSLocalizedString(@"导入接收的视频到系统", nil);
            swit.on = [[NSUserDefaults standardUserDefaults] boolForKey:AutoImportVideo];
            swit.tag = 1;
        }
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.textLabel.textColor = RGBFromHex(0x333333);
    }
    
    if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"清空缓存", nil);
    } else {
        cell.textLabel.text = NSLocalizedString(@"关于我们", nil);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 1) {
        return 66.0f;
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"你确定要清空缓存吗", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action1];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:NULL];
        [alertController addAction:action2];
        [self presentViewController:alertController animated:YES completion:NULL];
    } else if (indexPath.row == 3) {
        STAboutViewController *aboutVc = [[STAboutViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:aboutVc animated:YES];
    }
}

@end
