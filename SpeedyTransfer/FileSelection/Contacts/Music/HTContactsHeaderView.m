//
//  HTContactsHeaderView.m
//  
//
//  Created by zz on 13-7-30.
//  Copyright (c) 2013年 HT. All rights reserved.
//

#import "HTContactsHeaderView.h"
#import "HTDrawView.h"

@interface HTContactsHeaderView ()

@property (nonatomic,strong) HTDrawView *titleView;

@end

@implementation HTContactsHeaderView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *backView = [UIImageView newAutoLayoutView];
		backView.backgroundColor = RGBFromHex(0xf0f0f0);
        [self.contentView addSubview:backView];
        [backView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        _titleView = [[HTDrawView alloc] initWithFrame:CGRectMake(9, 0, IPHONE_WIDTH - 20, 44)];
        _titleView.backgroundColor = [UIColor clearColor];
        
        __block __weak HTContactsHeaderView *sself = self;
        _titleView.drawBlock = ^{
            [RGBFromHex(0x646464) set];
            [sself.titleString drawInRect:CGRectMake(7.0f, 6, IPHONE_WIDTH - 120, 20) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0f], }];
        };
        [self.contentView addSubview:_titleView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [_titleView setNeedsDisplay];
}

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    _selectAllButton.selected = selected;
}

@end
