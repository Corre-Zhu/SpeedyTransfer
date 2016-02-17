//
//  STFileSelectionPopupView.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/20.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileSelectionPopupView.h"
#import "STMusicInfo.h"
#import "STContactInfo.h"
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
    subTitleLabel.text = [NSString formatSize:size];
}

@end

@interface STFileSelectionPopupView ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *backView;
    UILabel *titleLabel;
    UIButton *deleteButton;

    BOOL caculating;
    double totalSize;
    GCDQueue *caculatingQueue;
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
        caculatingQueue = [[GCDQueue alloc] initSerial];
    }
    
    return self;
}

- (void)reloadTitle {
    NSInteger count = 0;
    for (NSArray *arr in _dataSource) {
        count += arr.count;
    }
    
    if (count > 0) {
        titleLabel.text = [NSString stringWithFormat:@"已选择%ld个文件，共%@", count, [NSString formatSize:totalSize]];
    } else {
        titleLabel.text = [NSString stringWithFormat:@"已选择0个文件"];
    }
}

- (void)caculateCompleted {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTitle];
    });
}

- (double)caculateSize {
    caculating = YES;
    __block NSInteger caculatingIndex = 0;
    __block double size = 0.0f;
    NSMutableArray *tempDataSource = [NSMutableArray array];
    for (NSArray *arr in self.dataSource) {
        [tempDataSource addObjectsFromArray:arr];
    }
    for (id object in tempDataSource) {
        if ([object isKindOfClass:[PHAsset class]]) {
            PHAsset *asset = object;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                [caculatingQueue queueBlock:^{
                    size += imageData.length;
                    caculatingIndex++;
                    if (caculatingIndex == tempDataSource.count) {
                        caculating = NO;
                        totalSize = size;
                        [self caculateCompleted];
                    }
                }];
            }];
        } else if ([object isKindOfClass:[STMusicInfo class]]) {
            STMusicInfo *model = object;
            size += model.fileSize;
            caculatingIndex++;
            if (caculatingIndex == tempDataSource.count) {
                caculating = NO;
                totalSize = size;
                [self caculateCompleted];
            }
        } else if ([object isKindOfClass:[STContactInfo class]]) {
            STContactInfo *model = object;
            size += model.size;
            caculatingIndex++;
            if (caculatingIndex == tempDataSource.count) {
                caculating = NO;
                totalSize = size;
                [self caculateCompleted];
            }
        }
    }
    
    return size;
}

- (void)removeAsset:(PHAsset *)asset {
    [self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        totalSize -= imageData.length;
        [self reloadTitle];
    }];
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    NSInteger count = 0;
    for (NSArray *arr in _dataSource) {
        count += arr.count;
    }
    titleLabel.text = [NSString stringWithFormat:@"已选择%@个文件", @(count).stringValue];
    [self.tableView reloadData];
    
    [caculatingQueue queueBlock:^{
        [self caculateSize];
    }];
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
    if (caculating) {
        return;
    }
    
    [self.tabViewController removeAllSelectedFiles];
    _dataSource = nil;
    [self.tabViewController reloadAssetsTableView];
    [self.tabViewController reloadMusicsTableView];
    [self.tabViewController reloadVideosTableView];
    [self.tabViewController reloadContactsTableView];
    [self.tableView reloadData];
    totalSize = 0.0f;
    [self reloadTitle];
}

- (NSIndexPath *)indexPathForEvent:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    return [self.tableView indexPathForRowAtPoint:currentTouchPosition];
}

- (void)rowDeleteButtonClick:(UIButton *)sender event:(UIEvent *)event {
    if (caculating) {
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathForEvent:event];
    if (_dataSource.count > indexPath.section) {
        NSMutableArray *mutableArr = _dataSource[indexPath.section];
        id object = [mutableArr objectAtIndex:indexPath.row];
        [mutableArr removeObject:object];
        if ([object isKindOfClass:[PHAsset class]]) {
            PHAsset *asset = object;
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [self.tabViewController configToolView];
                [self.tabViewController reloadAssetsTableView];
            } else {
                [self.tabViewController configToolView];
                [self.tabViewController reloadVideosTableView];
            }
            [self removeAsset:asset];
        } else if ([object isKindOfClass:[STMusicInfo class]]) {
            [self.tabViewController configToolView];
            [self.tabViewController reloadMusicsTableView];
            totalSize -= ((STMusicInfo *)object).fileSize;
            [self reloadTitle];
        } else if ([object isKindOfClass:[STContactInfo class]]) {
            [self.tabViewController configToolView];
            [self.tabViewController reloadContactsTableView];
            totalSize -= ((STContactInfo *)object).size;
            [self reloadTitle];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STFileSelectionPopupCell *cell = [tableView dequeueReusableCellWithIdentifier:PopupCellIdentifier forIndexPath:indexPath];
    if (![cell.deleteButton.allTargets containsObject:self]) {
        [cell.deleteButton addTarget:self action:@selector(rowDeleteButtonClick: event:) forControlEvents:UIControlEventTouchUpInside];
    }
    id object = [_dataSource[indexPath.section] objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = object;
        NSInteger currentTag = cell.tag + 1;
        cell.tag = currentTag;
		
		@autoreleasepool {
			[self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
				if (cell.tag == currentTag) {
					cell.size = imageData.length;
					NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
					cell.title = [url.absoluteString lastPathComponent];
				}
			}];
			
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
		}
		
		
    } else if ([object isKindOfClass:[STMusicInfo class]]) {
        STMusicInfo *model = object;
        cell.title = model.title;
        cell.image = [UIImage imageNamed:@"music_bg"];
        cell.size = model.fileSize;
    } else if ([object isKindOfClass:[STContactInfo class]]) {
        STContactInfo *model = object;
        cell.title = model.name;
        cell.image = [UIImage imageNamed:@"phone_bg"];
        cell.size = model.size;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 83.0f;
}

@end
