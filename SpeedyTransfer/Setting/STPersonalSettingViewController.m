//
//  STPersonalSettingViewController.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STPersonalSettingViewController.h"
#import "STPersonalSettingCell.h"
#import <Photos/Photos.h>

static NSString *PersonalSetttingIdentifier = @"PersonalSetttingIdentifier";

@interface STPersonalSettingViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImageView *headImageView;
    NSArray *cellImages;
    NSArray *titles;
    NSArray *headImages;
    NSString *selectedImage;
}

@end

@implementation STPersonalSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"个人设置", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_done_white"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick)];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"048"]];
    topImageView.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 144.0f);
    [self.view addSubview:topImageView];
    
    headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((IPHONE_WIDTH - 90.0f) / 2.0f, 22.0f, 90.0f, 90.0f)];
    headImageView.backgroundColor = [UIColor whiteColor];
    headImageView.layer.cornerRadius = 45.0f;
    headImageView.layer.masksToBounds = YES;
    headImageView.contentMode = UIViewContentModeScaleAspectFill;
    NSString *headImage = [[NSUserDefaults standardUserDefaults] stringForKey:HeadImage];
    if ([headImage isEqualToString:CustomHeadImage]) {
        headImageView.image = [[UIImage alloc] initWithContentsOfFile:[[ZZPath documentPath] stringByAppendingPathComponent:CustomHeadImage]];
    } else {
        headImageView.image = [UIImage imageNamed:headImage];
    }
    [topImageView addSubview:headImageView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, IPHONE_HEIGHT_WITHOUTTOPBAR - 44.0f, IPHONE_WIDTH, 44.0f)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, IPHONE_WIDTH, 0.5f)];
    lineView.backgroundColor = RGBFromHex(0xb2b2b2);
    [bottomView addSubview:lineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"相册", nil) forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0f, 0.0f, IPHONE_WIDTH / 2.0f, 44.0f);
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [button setTitleColor:RGBFromHex(0x009688) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(albumnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:NSLocalizedString(@"相机", nil) forState:UIControlStateNormal];
    button2.frame = CGRectMake(IPHONE_WIDTH / 2.0f, 0.0f, IPHONE_WIDTH / 2.0f, 44.0f);
    button2.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [button2 setTitleColor:RGBFromHex(0x009688) forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(cameraClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button2];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 17.0f;
    layout.minimumInteritemSpacing = 0.0f;
    layout.itemSize = CGSizeMake(IPHONE_WIDTH / 3.0f, 85.0f);
    layout.sectionInset = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 0.0f);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, topImageView.bottom, IPHONE_WIDTH, IPHONE_HEIGHT_WITHOUTTOPBAR - topImageView.bottom - 44.0f) collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[STPersonalSettingCell class] forCellWithReuseIdentifier:PersonalSetttingIdentifier];
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    
    cellImages = @[@"head1", @"head2", @"head3", @"head4", @"head5", @"head6", @"head7", @"head8", @"head9", @"head10", @"head11", @"head12"];
    titles = @[NSLocalizedString(@"老鼠", nil), NSLocalizedString(@"牛", nil), NSLocalizedString(@"虎", nil), NSLocalizedString(@"兔子", nil), NSLocalizedString(@"龙", nil), NSLocalizedString(@"蛇", nil), NSLocalizedString(@"马", nil), NSLocalizedString(@"羊", nil), NSLocalizedString(@"猴子", nil), NSLocalizedString(@"鸡", nil), NSLocalizedString(@"狗", nil), NSLocalizedString(@"猪", nil)];
    headImages = @[@"鼠", @"牛", @"虎", @"兔", @"龙", @"蛇", @"马", @"羊", @"猴", @"鸡", @"狗", @"猪"];
}

- (void)leftBarButtonItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonItemClick {
    if (selectedImage.length > 0) {
        if ([selectedImage isEqualToString:CustomHeadImage]) {
            NSString *path = [[ZZPath documentPath] stringByAppendingPathComponent:CustomHeadImage];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            }
            NSData *data = UIImageJPEGRepresentation(headImageView.image, 1.0f);
            [data writeToFile:path atomically:YES];
        } else {
            NSInteger index = [headImages indexOfObject:selectedImage];
            if (index != NSNotFound && index < cellImages.count) {
                [[NSUserDefaults standardUserDefaults] setObject:[cellImages objectAtIndex:index] forKey:HeadImage_];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:selectedImage forKey:HeadImage];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)albumnClick {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }
    }];
}

- (void)cameraClick {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *image = [originalImage imageScaleAspectToMaxSize:90.0f];
    headImageView.image = image;
    [self dismissViewControllerAnimated:picker completion:NULL];
    selectedImage = CustomHeadImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:picker completion:NULL];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STPersonalSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PersonalSetttingIdentifier forIndexPath:indexPath];
    cell.image = [UIImage imageNamed:cellImages[indexPath.row]];
    cell.title = titles[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    headImageView.image = [UIImage imageNamed:headImages[indexPath.row]];
    selectedImage = headImages[indexPath.row];
}

@end
