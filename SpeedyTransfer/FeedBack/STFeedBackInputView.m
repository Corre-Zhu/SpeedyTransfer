//
//  STFeedBackInputView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STFeedBackInputView.h"

@interface STFeedBackInputView ()
{
    
}

@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UITextField *emailTextField;

@end

@implementation STFeedBackInputView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 83.0f)];
    if (self) {
        self.backgroundColor = RGBFromHex(0xf8f8f8);
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 0.5f)];
        line.backgroundColor = RGBFromHex(0xb2b2b2);
        [self addSubview:line];
        
        _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, 9.0f, IPHONE_WIDTH - 80.0f, 28.0f)];
        _inputTextField.borderStyle = UITextBorderStyleRoundedRect;
        _inputTextField.font = [UIFont systemFontOfSize:14.0f];
        _inputTextField.textColor = RGBFromHex(0x929292);
        _inputTextField.backgroundColor = [UIColor clearColor];
        [self addSubview:_inputTextField];
        
        _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, _inputTextField.bottom + 9.0f, IPHONE_WIDTH - 80.0f, 28.0f)];
        _emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        _emailTextField.font = [UIFont systemFontOfSize:14.0f];
        _emailTextField.textColor = RGBFromHex(0x929292);
        _emailTextField.backgroundColor = [UIColor clearColor];
        _emailTextField.placeholder = NSLocalizedString(@"联系方式（可填写您的邮箱或QQ号）", nil);
        [self addSubview:_emailTextField];
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(IPHONE_WIDTH - 57.0f, 9.0f, 49.0f, 65.0f);
        _sendButton.layer.cornerRadius = 4.0f;
        _sendButton.backgroundColor = RGBFromHex(0x858f99);
        [_sendButton setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [self addSubview:_sendButton];
        
    }
    
    return self;
}

- (void)clearText {
    _inputTextField.text = nil;
    _emailTextField.text = nil;
}

- (NSString *)text {
    return _inputTextField.text;
}

- (NSString *)email {
    return _emailTextField.text;
}

@end
