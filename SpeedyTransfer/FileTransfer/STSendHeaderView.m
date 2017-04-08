//
//  STSendHeaderView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/21.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STSendHeaderView.h"
#import "NSString+Extension.h"

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
        self.contentView.backgroundColor = RGBFromHex(0xf4f4f4);
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, IPHONE_WIDTH - 71.0f, 40.0)];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.numberOfLines = 0;
        [self.contentView addSubview:label];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_WIDTH - 56.0f, 10.0f, 40.0f, 40.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 20.0f;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
    }
    
    return self;
}

- (void)setFileSize:(double)fileSize {
    _fileSize = fileSize;
    
    if (_name.length > 0) {
        NSString *text = [NSString stringWithFormat:@"传输给%@\n%@个文件 , 共%@", _name, @(_filesCount), [NSString formatSize:_fileSize]];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
        [string addAttributes:@{NSForegroundColorAttributeName: RGBFromHex(0x333333)} range:NSMakeRange(0, text.length)];
        [string addAttributes:@{NSForegroundColorAttributeName: RGBFromHex(0xff6600)} range:NSMakeRange(3, _name.length)];
        label.attributedText = string;
    } else {
        label.attributedText = nil;
    }
    
    UIImage *headImage = nil;
    if (_name.length > 0) {
        NSString *headPath = [[ZZPath headImagePath] stringByAppendingPathComponent:_name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
            headImage = [[UIImage alloc] initWithContentsOfFile:headPath];
        }
    }
    
    imageView.image = headImage;
}

@end
