//
//  STFileTransferCell.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferCell.h"
#import <Photos/Photos.h>

@interface STFileTransferCell ()
{
    UIImageView *coverImageView;
    UILabel *fileNameLabel;
    UILabel *dateLabel;
    UILabel *sizeLabel;
    UIProgressView *progressView;
    UILabel *rateLabel;
    UIImageView *succeedImageView;
    UILabel *failedLabel;
    
    BOOL progressObserverAdded;
}

@end

@implementation STFileTransferCell

- (void)dealloc {
    if (progressObserverAdded) {
        [_transferInfo removeObserver:self forKeyPath:@"progress"];
        [_transferInfo removeObserver:self forKeyPath:@"thumbnailProgress"];
        [_transferInfo removeObserver:self forKeyPath:@"transferStatus"];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 10.0f, 72.0f, 72.0f)];
        coverImageView.layer.cornerRadius = 4.0f;
        coverImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:coverImageView];
        
        fileNameLabel = [[UILabel alloc] init];
        fileNameLabel.textColor = RGBFromHex(0x323232);
        fileNameLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:fileNameLabel];
        
        dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = RGBFromHex(0x929292);
        dateLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:dateLabel];
        
        sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(coverImageView.right + 10.0f, 42.0f, 100.0f, 15.0f)];
        sizeLabel.textColor = RGBFromHex(0x929292);
        sizeLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:sizeLabel];
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(coverImageView.right + 10.0f, 75.0f, 140.0f, 0.0f)];
        progressView.trackTintColor = RGBFromHex(0xe0e1de);
        progressView.progressTintColor = RGBFromHex(0x4adb61);
        [self.contentView addSubview:progressView];
        [progressView setTransform:CGAffineTransformMakeScale(1.0, 2.2)];
        
        rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(progressView.right + 16.0f, 66.0f, IPHONE_WIDTH - progressView.right - 32.0f, 16.0f)];
        if (IPHONE_WIDTH == 320.0f) {
            rateLabel.frame = CGRectMake(progressView.right + 10.0f, 66.0f, IPHONE_WIDTH - progressView.right - 20.0f, 16.0f);
        }
        rateLabel.textColor = RGBFromHex(0x929292);
        rateLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:rateLabel];
        
        succeedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_green"]];
        succeedImageView.left = IPHONE_WIDTH - 38.0f;
        succeedImageView.centerY = 46.0f;
        [self.contentView addSubview:succeedImageView];
        succeedImageView.hidden = YES;
        
        failedLabel = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_WIDTH - 96.0f, 37.0f, 80.0f, 17.0f)];
        failedLabel.textColor = RGBFromHex(0xff3b30);
        failedLabel.font = [UIFont systemFontOfSize:14.0f];
        failedLabel.textAlignment = NSTextAlignmentRight;
        failedLabel.text = NSLocalizedString(@"传输失败", nil);
        [self.contentView addSubview:failedLabel];
        failedLabel.hidden = YES;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 91.5f, IPHONE_WIDTH, 0.5f)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lineView];
    }
    
    return self;
}

- (void)setTransferInfo:(STFileTransferInfo *)transferInfo {
    _transferInfo = transferInfo;
    
    if (!progressObserverAdded) {
        [_transferInfo addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:NULL];
        [_transferInfo addObserver:self forKeyPath:@"thumbnailProgress" options:NSKeyValueObservingOptionNew context:NULL];
        [_transferInfo addObserver:self forKeyPath:@"transferStatus" options:NSKeyValueObservingOptionNew context:NULL];

        progressObserverAdded = YES;
    }
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    if (progressObserverAdded) {
        [_transferInfo removeObserver:self forKeyPath:@"progress"];
        [_transferInfo removeObserver:self forKeyPath:@"thumbnailProgress"];
        [_transferInfo removeObserver:self forKeyPath:@"transferStatus"];

        progressObserverAdded = NO;
    }
}

- (void)configCell {
    if (_transferInfo.fileType == STFileTypeContact) {
        coverImageView.image = [UIImage imageNamed:@"phone_bg"];
    } else if (_transferInfo.fileType == STFileTypePicture ||
               _transferInfo.fileType == STFileTypeVideo) {
        BOOL localAssetExist = NO;
        if (self.transferInfo.url.length > 0 && ![self.transferInfo.url hasPrefix:@"http://"]) {
            PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[_transferInfo.url] options:nil];
            if (savedAssets.count > 0) {
                localAssetExist = YES;
                
                PHAsset *asset = savedAssets.firstObject;
                NSInteger currentTag = _transferInfo.tag + 1;
                _transferInfo.tag = currentTag;
                
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.resizeMode = PHImageRequestOptionsResizeModeExact;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
                [[PHImageManager defaultManager] requestImageForAsset:asset
                                                           targetSize:CGSizeMake([UIScreen mainScreen].scale * 72.0f, [UIScreen mainScreen].scale * 72.0f)
                                                          contentMode:PHImageContentModeAspectFill
                                                              options:options
                                                        resultHandler:^(UIImage *result, NSDictionary *info) {
                                                            if (_transferInfo.tag == currentTag) {
                                                                coverImageView.image = result;
                                                            }}];
                
            }
  
        }
    
        if (!localAssetExist) {
            NSString *path = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_thumb", _transferInfo.identifier]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
                coverImageView.image = image;
            } else {
                coverImageView.image = [UIImage imageNamed:@"picture"];
            }
        }
        
    } else if (_transferInfo.fileType == STFileTypeMusic) {
        coverImageView.image = [UIImage imageNamed:@"music_bg"];
	} else {
		// 未知文件类型
		coverImageView.image = [UIImage imageNamed:@"question"];
	}
	
    if (_transferInfo.transferStatus == STFileTransferStatusSending ||
        _transferInfo.transferStatus == STFileTransferStatusReceiving) {
        succeedImageView.hidden = YES;
        failedLabel.hidden = YES;
    } else if (_transferInfo.transferStatus == STFileTransferStatusSendFailed ||
               _transferInfo.transferStatus == STFileTransferStatusReceiveFailed) {
        succeedImageView.hidden = YES;
        failedLabel.hidden = NO;
    } else if (_transferInfo.transferStatus == STFileTransferStatusSent ||
               _transferInfo.transferStatus == STFileTransferStatusReceived) {
        succeedImageView.hidden = NO;
        failedLabel.hidden = YES;
    }
    
    fileNameLabel.text = _transferInfo.fileName;
    dateLabel.text = _transferInfo.dateString;
    sizeLabel.text = _transferInfo.fileSizeString;
    rateLabel.text = _transferInfo.rateString;
    progressView.progress = _transferInfo.progress;

    [dateLabel sizeToFit];
    dateLabel.left = coverImageView.right + 10.0f;
    dateLabel.top = 42.0f;
    
    sizeLabel.left = dateLabel.right + 16.0f;
    
    fileNameLabel.frame = CGRectMake(coverImageView.right + 10.0f, 12.0f, IPHONE_WIDTH - coverImageView.right - 26.0f, 17.0f);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"progress"]) {
        [[GCDQueue mainQueue] queueBlock:^{
            progressView.progress = _transferInfo.progress;
            rateLabel.text = _transferInfo.rateString;
        }];
    } else if ([keyPath isEqualToString:@"thumbnailProgress"] ||
               [keyPath isEqualToString:@"transferStatus"]) {
        [[GCDQueue mainQueue] queueBlock:^{
            [self configCell];
        }];
    }
}

@end
