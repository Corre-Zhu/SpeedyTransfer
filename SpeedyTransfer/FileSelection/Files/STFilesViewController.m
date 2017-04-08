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
    UIView *alertView;
    
    UIImageView *toolView;
    UIButton *deleteButton;
    UIButton *transferButton;
    
    STFilesModel *model;
}

@property (nonatomic, strong) NSMutableArray *selectedFilesArray;

@end

@implementation STFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"我的文件", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[STFileCell class] forCellReuseIdentifier:STFileCellIdentifier];
    
    if (_isForEdit) {
        toolView = [[UIImageView alloc] initWithFrame:CGRectMake(0, IPHONE_HEIGHT_WITHOUTTOPBAR - 49, IPHONE_WIDTH, 49.0f)];
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
        [deleteButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:deleteButton];
        
        transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
        transferButton.frame = CGRectMake(IPHONE_WIDTH / 2.0, 0, IPHONE_WIDTH / 2.0, 49);
        [transferButton setImage:[UIImage imageNamed:@"ic_delet"] forState:UIControlStateNormal];
        [transferButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [transferButton setTitleColor:RGBFromHex(0xff6600) forState:UIControlStateNormal];
        transferButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [transferButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
        [toolView addSubview:transferButton];
        
        UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, 0.5)];
        lineView.backgroundColor = RGBFromHex(0xbdbdbd);
        [toolView addSubview:lineView];
        
        _selectedFilesArray = [NSMutableArray array];
    }
    
    model = [[STFilesModel alloc] init];
    [model initData];
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonClick {
    [self.selectedFilesArray removeAllObjects];
    [self selectedCountChanged];
    [self.tableView reloadData];
}

- (void)deleteButtonClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"\n是否删除全部已选文件\n\n" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [model deleteFiles:_selectedFilesArray];
        [model initData];
        [_selectedFilesArray removeAllObjects];
        [self setupSelectAllButton];
        [self selectedCountChanged];
        [self.tableView reloadData];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:destructiveAction];
    [alertController addAction:cancelAction];
    
    [cancelAction setValue:RGBFromHex(0x666666) forKey:@"_titleTextColor"];
    [destructiveAction setValue:RGBFromHex(0x01cc99) forKey:@"_titleTextColor"];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
}

- (UIView *)alertView2 {
    if (!alertView) {
        alertView = [[UIView alloc] init];
        alertView.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR);
        [self.view addSubview:alertView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_kongwenjian"]];
        [alertView addSubview:imageView];
        imageView.frame = CGRectMake((IPHONE_WIDTH - 100) / 2.0, 132, 100, 136);
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, IPHONE_WIDTH - 40, 0)];
        label1.text = @"在这里管理从点传接收到的文件 \n\n图片和视频可在系统相册中管理";
        label1.textColor = RGBFromHex(0x333333);
        label1.numberOfLines = 0;
        label1.font = [UIFont systemFontOfSize:16.0f];
        label1.textAlignment = NSTextAlignmentCenter;
        [alertView addSubview:label1];
        [label1 sizeToFit];
        label1.top = imageView.bottom + 40;
        label1.left = 20;
        label1.width = IPHONE_WIDTH - 40;
    }
    
    return alertView;
}

- (UIView *)alertView {
    if (!alertView) {
        STNoFileAlertView *alertV = [[[NSBundle mainBundle] loadNibNamed:@"STNoFileAlertView" owner:nil options:nil] lastObject];
        alertV.imageView.image = [UIImage imageNamed:@"img_wenjian"];
        alertV.label.text = @"此设备暂无文件";
        alertV.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT - 109);
        [self.view addSubview:alertV];
        
        alertView = alertV;
    }
    
    return alertView;
}

- (void)setupAlertView {
    if (self.isForEdit) {
        [self alertView2];
    } else {
       [self alertView];
    }
    
    if (model.dataSource.count == 0) {
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
    if (_isForEdit) {
        if (_selectedFilesArray.count >= model.dataSource.count) {
            selectAllButton.selected = YES;
        } else {
            selectAllButton.selected = NO;
        }
    } else {
        if (self.fileSelectionTabController.selectedFilesArray.count >= model.dataSource.count) {
            selectAllButton.selected = YES;
        } else {
            selectAllButton.selected = NO;
        }
    }
    
}

- (void)selectedCountChanged {
    if (_selectedFilesArray.count > 0) {
        [transferButton setTitle:[NSString stringWithFormat:@"%@ ( %@ )", NSLocalizedString(@"删除文件", nil), @(_selectedFilesArray.count)] forState:UIControlStateNormal];
        toolView.hidden = NO;
        [self.view bringSubviewToFront:toolView];
    } else {
        toolView.hidden = YES;
    }
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, _selectedFilesArray.count > 0 ? 49 : 0, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, _selectedFilesArray.count > 0 ? 49 : 0, 0)];

}

- (void)selectAll {
    if (_isForEdit) {
        if (selectAllButton.selected) {
            [_selectedFilesArray removeAllObjects];
        } else {
            [_selectedFilesArray removeAllObjects];
            [_selectedFilesArray addObjectsFromArray:model.dataSource];
        }
        
        [self selectedCountChanged];

    } else {
        if (selectAllButton.selected) {
            [self.fileSelectionTabController removeAllFiles];
        } else {
            [self.fileSelectionTabController removeAllFiles];
            [self.fileSelectionTabController addFiles:model.dataSource];
        }
    }
   
    
    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isForEdit && toolView && !toolView.hidden) {
        toolView.top = IPHONE_HEIGHT_WITHOUTTOPBAR - 49 + scrollView.contentOffset.y;
    }
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
    
    if (_isForEdit) {
        if ([_selectedFilesArray containsObject:info]) {
            cell.checked = YES;
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            cell.checked = NO;
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else {
        if ([self.fileSelectionTabController isSelectedWithFile:info]) {
            cell.checked = YES;
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            cell.checked = NO;
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (model.dataSource.count == 0) {
        return nil;
    }
    
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
    if (model.dataSource.count == 0) {
        return 0.0f;
    }
    
    return 40;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileInfo *info = [model.dataSource objectAtIndex:indexPath.row];
    
    if (_isForEdit) {
        if (![_selectedFilesArray containsObject:info]) {
            [_selectedFilesArray addObject:info];
        }
        
        [self selectedCountChanged];
    } else {
        [self.fileSelectionTabController addFile:info];
    }
    
    STFileCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checked = YES;
    [self setupSelectAllButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileInfo *info = [model.dataSource objectAtIndex:indexPath.row];
    
    if (_isForEdit) {
        [_selectedFilesArray removeObject:info];
        [self selectedCountChanged];
    } else {
        [self.fileSelectionTabController removeFile:info];
    }
    
    STFileCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checked = NO;
    [self setupSelectAllButton];
}

@end
