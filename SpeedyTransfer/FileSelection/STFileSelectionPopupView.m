//
//  STFileSelectionPopupView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/20.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileSelectionPopupView.h"
#import "STMusicInfoModel.h"
#import "STContactModel.h"
#import "STFileSelectionTabViewController.h"
#import <Photos/Photos.h>

@interface STFileSelectionPopupCell : UITableViewCell
{
    UIImageView *coverImageView;
    UILabel *titleLabel;
    UILabel *subTitleLabel;
}

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) double size;

@end

@implementation STFileSelectionPopupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0f, 5.0f, 73.0f, 73.0f)];
        [self.contentView addSubview:coverImageView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(coverImageView.right + 10.0f, 13.0f, IPHONE_WIDTH - 170.0f, 18.0f);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:titleLabel];
        
        subTitleLabel = [[UILabel alloc] init];
        subTitleLabel.frame = CGRectMake(coverImageView.right + 10.0f, 42.0f, IPHONE_WIDTH - 170.0f, 15.0f);
        subTitleLabel.textColor = RGBFromHex(0x929292);
        subTitleLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:subTitleLabel];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(IPHONE_WIDTH - 86.0f, 24.0f, 35.0f, 35.0f);
        [_deleteButton setImage:[UIImage imageNamed:@"delete_gray"] forState:UIControlStateNormal];
        [self.contentView addSubview:_deleteButton];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    titleLabel.text = title;
}

- (void)setImage:(UIImage *)image {
    coverImageView.image = image;
}

- (void)setSize:(double)size {
    if (size < 1024) {
        subTitleLabel.text = [NSString stringWithFormat:@"%.0fB", size];
    } else if (size < 1024 * 1024) {
        subTitleLabel.text = [NSString stringWithFormat:@"%.2fKB", size / 1024.0f];
    } else if (size < 1024 * 1024 * 1024) {
        subTitleLabel.text = [NSString stringWithFormat:@"%.2fMB", size / (1024.0f * 1024.0f)];
    } else {
        subTitleLabel.text = [NSString stringWithFormat:@"%.2fGB", size / (1024.0f * 1024.0f * 1024)];
    }
}

@end

@interface STFileSelectionPopupView ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *backView;
    UILabel *titleLabel;
    UIButton *deleteButton;

}

@property (nonatomic, strong) UITableView *tableView;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation STFileSelectionPopupView

static NSString *PopupCellIdentifier = @"PopupCellIdentifier";

- (instancetype)init {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGes];
        
        UIView *blackView = [[UIView alloc] init];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.layer.cornerRadius = 4.0f;
        blackView.frame = CGRectMake(17.5f, 96.0f, IPHONE_WIDTH - 35.5f, IPHONE_HEIGHT  - 194.0f);
        [self addSubview:blackView];
        
        UIImage *backImage = [[UIImage imageNamed:@"xuanze_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0f, 7.0f, 7.0f, 7.0f)];
        backView = [[UIImageView alloc] initWithImage:backImage];
        backView.frame = CGRectMake(16.0f, 95.0f, IPHONE_WIDTH - 32.0f, IPHONE_HEIGHT  - 190.0f);
        backView.userInteractionEnabled = YES;
        [self addSubview:backView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0f, 0.0f, IPHONE_WIDTH - 116.0f, 44.0f)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:titleLabel];
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(backView.width - 53.0f, 4.5f, 35.0f, 35.0f);
        [deleteButton setImage:[UIImage imageNamed:@"delete_white"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:deleteButton];
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(1.0f, 44.0f, backView.width - 3.0f, backView.height - 46.5f)];
        whiteView.backgroundColor = [UIColor whiteColor];
        whiteView.layer.masksToBounds = YES;
        [backView addSubview:whiteView];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:whiteView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4.0f, 4.0f)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = whiteView.bounds;
        maskLayer.path = maskPath.CGPath;
        whiteView.layer.mask = maskLayer;
        
        _tableView = [[UITableView alloc] initWithFrame:whiteView.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[STFileSelectionPopupCell class] forCellReuseIdentifier:PopupCellIdentifier];
        _tableView.tableFooterView = [UIView new];
        [whiteView addSubview:_tableView];
        
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    
    return self;
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    [self.tableView reloadData];
}

- (void)showInView:(UIView *)view {
    self.alpha = 0.0f;
    [view addSubview:self];
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if (!CGRectContainsPoint(backView.frame, point)) {
        [self removeFromSuperview];
    }
}

- (void)deleteButtonClick {
    [self.tabViewController removeAllSelectedFiles];
    _dataSource = nil;
    [self.tableView reloadData];
}

- (void)rowDeleteButtonClick:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (_dataSource.count > tag) {
        id object = [_dataSource objectAtIndex:tag];
        if ([object isKindOfClass:[PHAsset class]]) {
            PHAsset *asset = object;
            if (asset.mediaType == PHAssetMediaTypeImage) {
                
            } else {
                [self.tabViewController removeVideoAsset:asset];
            }
        } else if ([object isKindOfClass:[STMusicInfoModel class]]) {
            [self.tabViewController removeMusic:object];
        } else if ([object isKindOfClass:[STContactModel class]]) {
            [self.tabViewController removeContact:object];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileSelectionPopupCell *cell = [tableView dequeueReusableCellWithIdentifier:PopupCellIdentifier forIndexPath:indexPath];
    if (![cell.deleteButton.allTargets containsObject:self]) {
        [cell.deleteButton addTarget:self action:@selector(rowDeleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.tag = indexPath.row;
    id object = [_dataSource objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = object;
        NSInteger currentTag = cell.tag + 1;
        cell.tag = currentTag;
        
        [self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (cell.tag == currentTag) {
                cell.size = imageData.length;
                NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                cell.title = [url.absoluteString lastPathComponent];
            }
        }];
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize size = CGSizeMake(72.0f * scale, 72.0f * scale);
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            [self.imageManager requestImageForAsset:asset
                                         targetSize:size
                                        contentMode:PHImageContentModeAspectFill
                                            options:options
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          if (cell.tag == currentTag) {
                                              cell.image = result;
                                          }
                                      }];
        } else {
            cell.image = [UIImage imageNamed:@"video_bg"];
        }
        
        
    } else if ([object isKindOfClass:[STMusicInfoModel class]]) {
        STMusicInfoModel *model = object;
        cell.title = model.title;
        cell.image = [UIImage imageNamed:@"music_bg"];
        cell.size = model.fileSize;
    } else if ([object isKindOfClass:[STContactModel class]]) {
        STContactModel *model = object;
        cell.title = model.name;
        cell.image = [UIImage imageNamed:@"phone_bg"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 83.0f;
}

@end
