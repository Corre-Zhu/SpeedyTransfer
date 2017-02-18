//
//  STReceiveHeaderView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/21.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STReceiveHeaderView.h"

@interface STReceiveHeaderView ()
{
    UILabel *label;
    UIImageView *imageView;
}

@end

@implementation STReceiveHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 10.0f, 40.0f, 40.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 20.0f;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(61.0f, 10.0f, IPHONE_WIDTH - 71.0f, 40.0f)];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:label];
    }
    
    return self;
}

- (void)setTransferInfo:(STFileTransferInfo *)transferInfo {
    if (transferInfo.deviceName.length > 0) {
        NSString *text = [NSString stringWithFormat:@"我接收自%@", transferInfo.deviceName];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
        [string addAttributes:@{NSForegroundColorAttributeName: RGBFromHex(0x333333)} range:NSMakeRange(0, 4)];
        [string addAttributes:@{NSForegroundColorAttributeName: RGBFromHex(0xeb684b)} range:NSMakeRange(4, text.length - 4)];
        label.attributedText = string;
    } else {
        label.attributedText = nil;
    }
    
    NSString *headImage = [[NSUserDefaults standardUserDefaults] stringForKey:HeadImage];
    if ([headImage isEqualToString:CustomHeadImage]) {
        imageView.image = [[UIImage alloc] initWithContentsOfFile:[[ZZPath documentPath] stringByAppendingPathComponent:CustomHeadImage]];
    } else {
        headImage = [[NSUserDefaults standardUserDefaults] stringForKey:HeadImage_];
        imageView.image = [UIImage imageNamed:headImage];
    }
    
}

@end
