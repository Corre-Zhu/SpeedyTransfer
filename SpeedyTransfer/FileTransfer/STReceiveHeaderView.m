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
        self.contentView.backgroundColor = RGBFromHex(0xf4f4f4);
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 10.0f, 40.0f, 40.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 20.0f;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(61.0f, 10.0f, IPHONE_WIDTH - 71.0f, 40.0f)];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.numberOfLines = 0;
        [self.contentView addSubview:label];
    }
    
    return self;
}

- (void)setFileSize:(double)fileSize {
    _fileSize = fileSize;
    
    if (_name.length > 0) {
        NSString *text = [NSString stringWithFormat:@"我接收自%@\n%@个文件 , 共%@", _name, @(_filesCount), [NSString formatSize:_fileSize]];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
        [string addAttributes:@{NSForegroundColorAttributeName: RGBFromHex(0x333333)} range:NSMakeRange(0, text.length)];
        [string addAttributes:@{NSForegroundColorAttributeName: RGBFromHex(0xff6600)} range:NSMakeRange(4, _name.length)];
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
