//
//  HTDrawView.m
//  HelloTalk_Binary
//
//  Created by 任健生 on 13-7-30.
//  Copyright (c) 2013年 HT. All rights reserved.
//

#import "HTDrawView.h"

@implementation HTDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (_drawBlock) {
        _drawBlock();
    }
}

@end
