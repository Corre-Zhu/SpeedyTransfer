//
//  STFilesViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/18.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STFilesViewController.h"
#import "STNoFileAlertView.h"
#import "STFileCell.h"
#import "STFilesModel.h"
#import "STFileInfo.h"

static NSString *STFileCellIdentifier = @"STFileCellIdentifier";

@interface STFilesViewController () {
    UIView *headerView;
    UILabel *headerLabel;
    UIButton *selectAllButton;
    STNoFileAlertView *alertView;
    
    STFilesModel *model;
}

@end

@implementation STFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[STFileCell class] forCellReuseIdentifier:STFileCellIdentifier];
    
    model = [[STFilesModel alloc] init];
    [model initData];
}

- (void)setupAlertView {
    if (model.dataSource.count == 0) {
        if (!alertView) {
            alertView = [[[NSBundle mainBundle] loadNibNamed:@"STNoFileAlertView" owner:nil options:nil] lastObject];
            alertView.imageView.image = [UIImage imageNamed:@"img_wenjian"];
            alertView.label.text = @"此设备暂无文件";
            alertView.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT - 109);
            [self.view addSubview:alertView];
            
        }
        
        [self.view bringSubviewToFront:alertView];
        alertView.hidden = NO;
    } else {
        alertView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSelectAllButton {
    if (self.fileSelectionTabController.selectedFilesArray.count >= model.dataSource.count) {
        selectAllButton.selected = YES;
    } else {
        selectAllButton.selected = NO;
    }
}

- (void)selectAll {
    if (selectAllButton.selected) {
        [self.fileSelectionTabController removeAllFiles];
    } else {
        [self.fileSelectionTabController addFiles:model.dataSource];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self setupAlertView];
    return model.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileCell *cell = [tableView dequeueReusableCellWithIdentifier:STFileCellIdentifier forIndexPath:indexPath];
    
    STFileInfo *info = [model.dataSource objectAtIndex:indexPath.row];
    cell.title = info.fileName;
    cell.subTitle = [NSString formatSize:info.fileSize];
    
    if ([self.fileSelectionTabController isSelectedWithFile:info]) {
        cell.checked = YES;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        cell.checked = NO;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!headerView) {
        headerView = [[UIView alloc] init];
        headerView.backgroundColor = RGBFromHex(0xf4f4f4);
        
        headerLabel = [[UILabel alloc] init];
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.textColor = RGBFromHex(0x333333);
        headerLabel.frame = CGRectMake(16, 0, 200, 40);
        [headerView addSubview:headerLabel];
        
        selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [selectAllButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateSelected];
        [selectAllButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateNormal];
        [selectAllButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateSelected];
        selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 96, 0, 80.0f, 40.0f);
        selectAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [headerView addSubview:selectAllButton];
        [selectAllButton addTarget:self action:@selector(selectAll)forControlEvents:UIControlEventTouchUpInside];
    }
    headerLabel.text = [NSString stringWithFormat:@"%@个文件", @(model.dataSource.count)];
    [self setupSelectAllButton];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileInfo *info = [model.dataSource objectAtIndex:indexPath.row];
    [self.fileSelectionTabController addFile:info];
    STFileCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checked = YES;
    [self setupSelectAllButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileInfo *info = [model.dataSource objectAtIndex:indexPath.row];
    [self.fileSelectionTabController removeFile:info];
    STFileCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checked = NO;
    [self setupSelectAllButton];
}

@end
