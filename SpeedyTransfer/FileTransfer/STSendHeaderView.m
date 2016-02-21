//
//  STSendHeaderView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/21.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STSendHeaderView.h"

@interface STSendHeaderView ()
{
    UILabel *label;
    UIImageView *imageView;
}

@end

@implementation STSendHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, IPHONE_WIDTH - 71.0f, 40.0)];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:label];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH - 56.0f, 10.0f, 40.0f, 40.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 20.0f;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
    }
    
    return self;
}

- (void)setTransferInfo:(STFileTransferInfo *)transferInfo {
    if (transferInfo.deviceName.length > 0) {
        NSString *text = [NSString stringWithFormat:@"我发送给%@", transferInfo.deviceName];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
        [string addAttributes:@{NSForegroundColorAttributeName: RGBFromHex(0x323232)} range:NSMakeRange(0, 4)];
        [string addAttributes:@{NSForegroundColorAttributeName: RGBFromHex(0xeb684b)} range:NSMakeRange(4, text.length - 4)];
        label.attributedText = string;
    } else {
        label.attributedText = nil;
    }
    
    UIImage *headImage = nil;
    if (transferInfo.deviceId.length > 0) {
        NSString *headPath = [[ZZPath headImagePath] stringByAppendingPathComponent:transferInfo.deviceId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
            headImage = [[UIImage alloc] initWithContentsOfFile:headPath];
        }
    }
    
    imageView.image = headImage;
}

@end
