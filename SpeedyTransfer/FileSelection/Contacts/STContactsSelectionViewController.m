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

static NSString *headerIdentifier = @"ContactsHeaderView";

@interface STContactsSelectionViewController ()
{
    UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, strong) NSArray *contactModels;

@end

@implementation STContactsSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.sectionIndexColor = RGBFromHex(0xeb694a);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 49.0f, 0.0f);
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

- (void)selectAllButtonClick:(UIButton *)sender {
    NSInteger section = sender.tag;
    NSDictionary *dic = [_contactModels objectAtIndex:section];
    if (!sender.selected) {
        [self.fileSelectionTabController addContacts:dic.allValues.firstObject];
        sender.selected = YES;
    } else {
        [self.fileSelectionTabController removeContacts:dic.allValues.firstObject];
        sender.selected = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
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
    cell.image = [UIImage imageNamed:@"phone_bg"];
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
    return 66.0f;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:_contactModels.count];
    for (NSDictionary *dic in _contactModels) {
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
    
    NSDictionary *dic = [_contactModels objectAtIndex:section];
    headerView.titleString = dic.allKeys.firstObject;
    
    if ([self.fileSelectionTabController isSelectedWithContacts:dic.allValues.firstObject]) {
        headerView.selected = YES;
    } else {
        headerView.selected = NO;
    }
    return headerView;
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
