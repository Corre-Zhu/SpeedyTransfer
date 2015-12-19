//
//  HTContactsHeaderView.h
//  HelloTalk_Binary
//
//  Created by 任健生 on 13-7-30.
//  Copyright (c) 2013年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTContactsHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic) BOOL selected;
@property (nonatomic, strong) UIButton *selectAllButton;

@end
