//
//  STPictureCollectionHeaderModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STPictureCollectionHeaderInfo : NSObject

@property (nonatomic, strong) NSString *localIdentifier; // collection的唯一标识
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *placeholdImage;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic) BOOL expand; // 是否展开
@property (nonatomic) BOOL isCameraRoll; // 是否是相机胶卷
@property (nonatomic) CGFloat height; // head的高度
@property (nonatomic) BOOL selectedAll; // 是否全部选中
@property (nonatomic) NSInteger tag;

@end
