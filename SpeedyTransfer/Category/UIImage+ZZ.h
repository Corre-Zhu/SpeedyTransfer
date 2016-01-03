//
//  UIImage+ZZ.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZZ)

- (UIImage *)imageWithScaleSize:(CGSize)size;
- (UIImage *)imageWithScaleSize:(CGSize)size interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize;

@end
