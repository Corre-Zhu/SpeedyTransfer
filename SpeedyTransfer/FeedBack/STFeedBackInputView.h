//
//  STFeedBackInputView.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STFeedBackInputView : UIView

@property (nonatomic, strong) UIButton *sendButton;

- (void)clearText;
- (NSString *)text;
- (NSString *)email;

@end
