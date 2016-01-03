//
//  UIImage+ZZ.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "UIImage+ZZ.h"

@implementation UIImage (ZZ)

- (UIImage *)imageWithScaleSize:(CGSize)size {
    
    CGSize newSize = size;
    
    float scale = [[UIScreen mainScreen] scale];
    
    if (scale > 1) {
        newSize = CGSizeMake(size.width * scale, size.height * scale);
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [self drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (UIImage *)imageWithScaleSize:(CGSize)size interpolationQuality:(CGInterpolationQuality)quality
{
    CGSize newSize = size;
    
    float scale = [[UIScreen mainScreen] scale];
    
    if (scale > 1) {
        newSize = CGSizeMake(size.width * scale, size.height * scale);
    }
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize {
    CGSize size = [self size];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat ratio;
    if (size.width > size.height) {
        ratio = scale * newSize / size.width;
    } else {
        ratio = scale * newSize / size.height;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, ceilf(ratio * size.width), ceilf(ratio * size.height));
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
