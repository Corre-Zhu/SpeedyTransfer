//
//  STFeedbackCell.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STFeedbackCell.h"

@interface STFeedbackCell ()
{
    UIImageView *bubbleView;
    UILabel *contentLabel;
}

@end

@implementation STFeedbackCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *bubble = [[UIImage imageNamed:@"text_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 17.0f, 15.0f, 27.0f)];
        bubbleView = [[UIImageView alloc] initWithImage:bubble];
        [self.contentView addSubview:bubbleView];
        
        contentLabel = [[UILabel alloc] init];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.font = [UIFont systemFontOfSize:17.0f];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.numberOfLines = 0;
        [bubbleView addSubview:contentLabel];
    }
    
    return self;
}

- (void)configCell {
    bubbleView.width = _info.textWidth + 50.0f;
    bubbleView.height = _info.cellHeight - 25.0f;
    bubbleView.left = IPHONE_WIDTH - bubbleView.width - 16.0f;
    bubbleView.top = 25.0f;
    
    contentLabel.text = _info.content;
    contentLabel.width = _info.textWidth;
    contentLabel.height = _info.textHeight;
    contentLabel.left = 22.0f;
    contentLabel.top = 10.0f;
}

@end
