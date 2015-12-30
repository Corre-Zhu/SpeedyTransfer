//
//  STAboutViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/30.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STAboutViewController.h"

@implementation STAboutViewController

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    self.navigationItem.title = NSLocalizedString(@"关于我们", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 186.0f)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dcshare"]];
    iconView.top = 33.0f;
    iconView.centerX = IPHONE_WIDTH / 2.0f;
    [headView addSubview:iconView];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, iconView.bottom + 15.0f, IPHONE_WIDTH, 19.0f)];
    label2.textColor = [UIColor blackColor];
    label2.font = [UIFont systemFontOfSize:16.0f];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = NSLocalizedString(@"点传", nil);
    [headView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, label2.bottom + 10.0f, IPHONE_WIDTH, 19.0f)];
    label3.textColor = RGBFromHex(0x929292);
    label3.font = [UIFont systemFontOfSize:14.0f];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = NSLocalizedString(@"V1.0", nil);
    [headView addSubview:label3];
    
    self.tableView.tableHeaderView = headView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier1 = @"cellIdentifier1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.textLabel.textColor = RGBFromHex(0x323232);
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"版本更新", nil);
    } else {
        cell.textLabel.text = NSLocalizedString(@"去评分", nil);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
       
    }
}

@end
