//
//  STMusicSelectionViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/13.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STMusicSelectionViewController.h"
#import "HTContactsHeaderView.h"
#import "STMusicSelectionCell.h"
#import "STMusicInfoModel.h"

static NSString *headerIdentifier = @"ContactsHeaderView";

@interface STMusicSelectionViewController ()

@property (nonatomic, strong) NSArray *musicInfoModels;

@end

@implementation STMusicSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.sectionIndexColor = RGBFromHex(0xeb694a);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    [self.tableView registerClass:[HTContactsHeaderView class] forHeaderFooterViewReuseIdentifier:headerIdentifier];
    _musicInfoModels = [STMusicInfoModel musicModelList];
    
}

- (void)selectAllButtonClick:(UIButton *)sender {
    NSInteger section = sender.tag;
    NSDictionary *dic = [_musicInfoModels objectAtIndex:section];
    if (!sender.selected) {
        [self.fileSelectionTabController addMusics:dic.allValues.firstObject];
        sender.selected = YES;
    } else {
        [self.fileSelectionTabController removeMusics:dic.allValues.firstObject];
        sender.selected = NO;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_musicInfoModels count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = [_musicInfoModels objectAtIndex:section];
    return [dic.allValues.firstObject count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    STMusicSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[STMusicSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *dic = [_musicInfoModels objectAtIndex:indexPath.section];
    STMusicInfoModel *model = [dic.allValues.firstObject objectAtIndex:indexPath.row];
    cell.title = model.title;
    cell.subTitle = model.artist;
    if ([self.fileSelectionTabController isSelectedWithMusic:model]) {
        cell.checked = YES;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        cell.checked = NO;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0f;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:_musicInfoModels.count];
    for (NSDictionary *dic in _musicInfoModels) {
        [arr addObject:dic.allKeys.firstObject];
    }
    
    return arr;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HTContactsHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (![headerView.selectAllButton.allTargets containsObject:self]) {
        [headerView.selectAllButton addTarget:self action:@selector(selectAllButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    headerView.selectAllButton.tag = section;
    
    NSDictionary *dic = [_musicInfoModels objectAtIndex:section];
    headerView.titleString = dic.allKeys.firstObject;
    
    if ([self.fileSelectionTabController isSelectedWithMusics:dic.allValues.firstObject]) {
        headerView.selected = YES;
    } else {
        headerView.selected = NO;
    }
    return headerView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [_musicInfoModels objectAtIndex:indexPath.section];
    STMusicInfoModel *model = [dic.allValues.firstObject objectAtIndex:indexPath.row];
    [self.fileSelectionTabController addMusic:model];
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [_musicInfoModels objectAtIndex:indexPath.section];
    STMusicInfoModel *model = [dic.allValues.firstObject objectAtIndex:indexPath.row];
    [self.fileSelectionTabController removeMusic:model];
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}

@end
