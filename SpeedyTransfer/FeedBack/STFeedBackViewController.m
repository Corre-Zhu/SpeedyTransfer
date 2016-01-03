//
//  STFeedBackViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STFeedBackViewController.h"
#import "STFeedBackInputView.h"
#import "STFeedbackCell.h"
#import "STFeedbackModel.h"

static NSString *FeedbackCellIdentifier = @"FeedbackCellIdentifier";

@interface STFeedBackViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    STFeedBackInputView *inputView;
    STFeedbackModel *model;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation STFeedBackViewController

- (void)dealloc {
    [self removeKeyboardNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"意见反馈", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[STFeedbackCell class] forCellReuseIdentifier:FeedbackCellIdentifier];
    [self.view addSubview:_tableView];
    
    inputView = [[STFeedBackInputView alloc] init];
    inputView.top = IPHONE_HEIGHT_WITHOUTTOPBAR - inputView.height;
    [inputView.sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputView];
    
    _tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, inputView.height, 0.0f);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    
    model = [[STFeedbackModel alloc] init];
    
    [self addKeyboardNotification];
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonClick {
    if (inputView.text.length > 0) {
        [model sendFeedback:inputView.text];
        [self.tableView reloadData];
        [self scrollToBottomAnimated:NO];
        [inputView clearText];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    if (rows > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark - Keyboard

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect rect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGSize keyboardbSize = rect.size;
    float keyboardHeight = keyboardbSize.height;
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:[UIView animationOptionsForCurve:curve]
                     animations:^{
                         inputView.top = IPHONE_HEIGHT_WITHOUTTOPBAR - keyboardHeight - inputView.height;
                         UIEdgeInsets inset = UIEdgeInsetsMake(0.0f, 0.0f, keyboardHeight + inputView.height, 0.0f);
                         self.tableView.contentInset = inset;
                         self.tableView.scrollIndicatorInsets = inset;
                         
                         [self scrollToBottomAnimated:NO];
                     } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification {
        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        [UIView animateWithDuration:duration
                              delay:0
                            options:[UIView animationOptionsForCurve:curve]
                         animations:^{
                             inputView.top = IPHONE_HEIGHT_WITHOUTTOPBAR - inputView.height;
                             UIEdgeInsets inset = UIEdgeInsetsMake(0.0f, 0.0f, inputView.height, 0.0f);
                             self.tableView.contentInset = inset;
                             self.tableView.scrollIndicatorInsets = inset;
                             
                             [self scrollToBottomAnimated:NO];
                         }completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return model.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFeedbackCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedbackCellIdentifier forIndexPath:indexPath];
    STFeedbackInfo *info = [model.dataSource objectAtIndex:indexPath.row];
    cell.info = info;
    [cell configCell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFeedbackInfo *info = [model.dataSource objectAtIndex:indexPath.row];
    return info.cellHeight;
}

@end
