//
//  STFileReceiveCell.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileReceiveCell.h"
#import <Photos/Photos.h>

@interface STFileReceiveCell ()
{
    UIImageView *coverImageView;
    UILabel *fileNameLabel;
    UILabel *dateLabel;
    UILabel *sizeLabel;
    UIProgressView *progressView;
    UILabel *rateLabel;
    UIImageView *succeedImageView;
    UILabel *failedLabel;
}

@end

@implementation STFileReceiveCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 10.0f, 72.0f, 72.0f)];
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
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(coverImageView.right + 10.0f, 75.0f, 140.0f, 8.0f)];
        progressView.trackTintColor = RGBFromHex(0xe0e1de);
        progressView.progressTintColor = RGBFromHex(0x4adb61);
        [self.contentView addSubview:progressView];
        [progressView setTransform:CGAffineTransformMakeScale(1.0, 4.0)];
        
        rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(progressView.right + 16.0f, 66.0f, IPHONE_WIDTH - progressView.right - 32.0f, 16.0f)];
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
        failedLabel.text = NSLocalizedString(@"接收失败", nil);
        [self.contentView addSubview:failedLabel];
        failedLabel.hidden = YES;
    }
    
    return self;
}

- (void)configCell {
    if (_transferInfo.type == STFileTransferTypeContact) {
        coverImageView.image = [UIImage imageNamed:@"phone_bg"];
    } else if (_transferInfo.type == STFileTransferTypePicture) {
        if (self.transferInfo.url.length > 0) {
            PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[_transferInfo.url] options:nil];
            if (savedAssets.count > 0) {
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
        } else {
            coverImageView.image = [UIImage imageNamed:@"picture"];
        }
    }
    
    if (_transferInfo.status == STFileReceiveStatusReceiving) {
        succeedImageView.hidden = YES;
        failedLabel.hidden = YES;
    } else if (_transferInfo.status == STFileReceiveStatusReceiveFailed) {
        succeedImageView.hidden = YES;
        failedLabel.hidden = NO;
    } else if (_transferInfo.status == STFileReceiveStatusReceived) {
        succeedImageView.hidden = NO;
        failedLabel.hidden = YES;
    }
    
    fileNameLabel.text = _transferInfo.fileName;
    dateLabel.text = _transferInfo.dateString;
    
    if (_transferInfo.fileSize == 0.0f) {
        sizeLabel.hidden = YES;
    } else {
        sizeLabel.text = _transferInfo.fileSizeString;
    }
    
    rateLabel.text = _transferInfo.rateString;
    progressView.progress = _transferInfo.progress;
    
    [dateLabel sizeToFit];
    dateLabel.left = IPHONE_WIDTH - 16.0f - dateLabel.width;
    dateLabel.top = 13.0f;
    
    fileNameLabel.frame = CGRectMake(coverImageView.right + 10.0f, 12.0f, IPHONE_WIDTH - coverImageView.right - dateLabel.width - 26.0f, 15.0f);
}

@end