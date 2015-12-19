//
//  HZAssetCollectionViewCell.m
//  AssetsPickerViewController
//
//  Created by zhuzhi on 15/8/19.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HZAssetCollectionViewCell.h"

@interface HZAssetCollectionViewCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIImageView *selectedView;

@end

@implementation HZAssetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_thumbnailImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
		[_thumbnailImageView setClipsToBounds:YES];
		[self.contentView addSubview:_thumbnailImageView];
	}
	
	return self;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	if (selected) {
		if (!_selectedView) {
			UIImage *image = [UIImage imageNamed:@"check_yellow"];
			_selectedView = [[UIImageView alloc] initWithImage:image];
            _selectedView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45f];
            _selectedView.contentMode = UIViewContentModeCenter;
            _selectedView.frame = self.bounds;
			_selectedView.userInteractionEnabled = NO;
			[self.contentView addSubview:_selectedView];
		}
		
		_selectedView.hidden = NO;
	} else {
		_selectedView.hidden = YES;
	}
}

- (void)setup {
    if (_isCameraRoll) {
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
	_thumbnailImageView.image = _thumbnailImage;
}

@end
