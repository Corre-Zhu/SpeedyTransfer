//
//  STContactsSelectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STContactsSelectionViewController.h"
#import "STMusicSelectionCell.h"
#import "HTContactsHeaderView.h"
#import "STContactInfo.h"
#import "STNoFileAlertView.h"

static NSString *headerIdentifier = @"ContactsHeaderView";

@interface STContactsSelectionViewController ()
{
    UIActivityIndicatorView *activityIndicatorView;
    
    UIView *topHeaderView;
    UILabel *topHeaderLabel;
    UIButton *selectAllButton;
    
    STNoFileAlertView *alertView;
}

@property (nonatomic, strong) NSArray *contactModels;

@end

@implementation STContactsSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.sectionIndexColor = RGBFromHex(0x01cc99);
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[HTContactsHeaderView class] forHeaderFooterViewReuseIdentifier:headerIdentifier];
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicatorView];
    activityIndicatorView.centerX = IPHONE_WIDTH / 2.0f;
    activityIndicatorView.centerY = (IPHONE_HEIGHT_WITHOUTTOPBAR - 49.0f) / 2.0f;
    [activityIndicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [STContactInfo getContactsModelListWithCompletion:^(NSArray *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicatorView stopAnimating];
                activityIndicatorView.hidden = YES;
                _contactModels = array;
                [self.tableView reloadData];
            });
        }];
    });

}

- (void)setupAlertView {
    if (_contactModels.count == 0) {
        if (!alertView) {
            alertView = [[[NSBundle mainBundle] loadNibNamed:@"STNoFileAlertView" owner:nil options:nil] lastObject];
            alertView.imageView.image = [UIImage imageNamed:@"img_tongxunlu"];
            alertView.label.text = @"此设备暂无联系人";
            alertView.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT - 109);
            [self.view addSubview:alertView];
            
        }
        
        [self.view bringSubviewToFront:alertView];
        alertView.hidden = NO;
    } else {
        alertView.hidden = YES;
    }
}

- (void)selectAllButtonClick:(UIButton *)sender {
    if (sender.selected) {
        [self.fileSelectionTabController removeAllContacts];
    } else {
        for (NSDictionary *dic in _contactModels) {
            [self.fileSelectionTabController removeContacts:dic.allValues.firstObject];
            [self.fileSelectionTabController addContacts:dic.allValues.firstObject];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    [self setupAlertView];
    return [_contactModels count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = [_contactModels objectAtIndex:section];
    return [dic.allValues.firstObject count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    STMusicSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[STMusicSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *dic = [_contactModels objectAtIndex:indexPath.section];
    STContactInfo *model = [dic.allValues.firstObject objectAtIndex:indexPath.row];
    cell.title = model.name;
    cell.subTitle = model.phone;
    cell.image = [UIImage imageNamed:@"ic_tongxunlu"];
    if ([self.fileSelectionTabController isSelectedWithContact:model]) {
        cell.checked = YES;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        cell.checked = NO;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:_contactModels.count];
//    for (NSDictionary *dic in _contactModels) {
//        [arr addObject:dic.allKeys.firstObject];
//    }
//    
//    return arr;
    
    return nil;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 72;
    }
    
    return 32.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *dic = [_contactModels objectAtIndex:section];
    
    if (section == 0) {
        if (!topHeaderView) {
            topHeaderView = [[UIView alloc] init];
            topHeaderView.backgroundColor = RGBFromHex(0xf4f4f4);
            
            topHeaderLabel = [[UILabel alloc] init];
            topHeaderLabel.font = [UIFont systemFontOfSize:16];
            topHeaderLabel.textColor = RGBFromHex(0x333333);
            topHeaderLabel.frame = CGRectMake(16, 0, 200, 72);
            topHeaderLabel.numberOfLines = 0;
            [topHeaderView addSubview:topHeaderLabel];
            
            selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [selectAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
            [selectAllButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateSelected];
            [selectAllButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateNormal];
            [selectAllButton setTitleColor:RGBFromHex(0x01cc99) forState:UIControlStateSelected];
            selectAllButton.frame = CGRectMake(IPHONE_WIDTH - 96, 0, 80.0f, 40.0f);
            selectAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [topHeaderView addSubview:selectAllButton];
            [selectAllButton addTarget:self action:@selector(selectAllButtonClick:)forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSInteger count = 0;
        for (NSDictionary *dic in _contactModels) {
            count += [dic.allValues.firstObject count];
        }
        topHeaderLabel.text = [NSString stringWithFormat:@"%@个联系人\n\n%@",@(count), dic.allKeys.firstObject];
        
        selectAllButton.selected = count <= self.fileSelectionTabController.selectedContactsArr.count;
        
        return topHeaderView;
    } else {
        HTContactsHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if (![headerView.selectAllButton.allTargets containsObject:self]) {
            [headerView.selectAllButton addTarget:self action:@selector(selectAllButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        headerView.titleString = dic.allKeys.firstObject;
        headerView.selectAllButton.tag = section;
        return headerView;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [_contactModels objectAtIndex:indexPath.section];
    STContactInfo *model = [dic.allValues.firstObject objectAtIndex:indexPath.row];
    [self.fileSelectionTabController addContact:model];
    
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [_contactModels objectAtIndex:indexPath.section];
    STContactInfo *model = [dic.allValues.firstObject objectAtIndex:indexPath.row];
    [self.fileSelectionTabController removeContact:model];
    
    [tableView reloadData];
}

@end
