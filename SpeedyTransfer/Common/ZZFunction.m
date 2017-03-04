//
//  ZZFunction.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/7/4.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "ZZFunction.h"

@implementation ZZFunction

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size topImage:(UIImage *)topImage {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *outputImage = [UIImage imageWithCGImage:scaledImage];
    
    if (topImage) {
        //给二维码加 logo 图
        UIGraphicsBeginImageContextWithOptions(outputImage.size, NO, [[UIScreen mainScreen] scale]);
        [outputImage drawInRect:CGRectMake(0,0 , size, size)];
        //把logo图画到生成的二维码图片上，注意尺寸不要太大（最大不超过二维码图片的%30），太大会造成扫不出来
        [topImage drawInRect:CGRectMake((size-topImage.size.width)/2.0, (size-topImage.size.width)/2.0, topImage.size.width, topImage.size.height)];
        outputImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return outputImage;
}

+ (UIImage *)qrCodeImageWithStr:(NSString *)string withSize:(CGFloat)size topImage:(UIImage *)topImage {
    // 1. 创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    
    // 2. 给滤镜添加数据
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 使用KVC的方式给filter赋值
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 3. 生成二维码
    CIImage *image = [filter outputImage];
    
    return [self createNonInterpolatedUIImageFormCIImage:image withSize:size topImage:topImage];
}

+(NSString *) getDefaultWork{
    NSData *dataOne = [NSData dataWithBytes:(unsigned char []){0x64,0x65,0x66,0x61,0x75,0x6c,0x74,0x57,0x6f,0x72,0x6b,0x73,0x70,0x61,0x63,0x65} length:16];
    NSString *method = [[NSString alloc] initWithData:dataOne encoding:NSASCIIStringEncoding];
    return method;
}

+(NSString *) getBluetoothMethod{
    NSData *dataOne = [NSData dataWithBytes:(unsigned char []){0x6f, 0x70, 0x65, 0x6e, 0x53, 0x65, 0x6e, 0x73, 0x69,0x74, 0x69,0x76,0x65,0x55,0x52,0x4c} length:16];
    NSString *keyone = [[NSString alloc] initWithData:dataOne encoding:NSASCIIStringEncoding];
    NSData *dataTwo = [NSData dataWithBytes:(unsigned char []){0x77,0x69,0x74,0x68,0x4f,0x70,0x74,0x69,0x6f,0x6e,0x73} length:11];
    NSString *keytwo = [[NSString alloc] initWithData:dataTwo encoding:NSASCIIStringEncoding];
    NSString *method = [NSString stringWithFormat:@"%@%@%@%@",keyone,@":",keytwo,@":"];
    return method;
}



+ (void)goToWifiPref {
    if (IOS10) {
        @try {
            NSString * defaultWork = [self getDefaultWork];
            NSString * bluetoothMethod = [self getBluetoothMethod];
            NSURL*url=[NSURL URLWithString:@"Prefs:root=WIFI"];
            Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
            [[LSApplicationWorkspace  performSelector:NSSelectorFromString(defaultWork)]   performSelector:NSSelectorFromString(bluetoothMethod) withObject:url     withObject:nil];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
    
}

@end
