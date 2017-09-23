//
//  NSString+Extension.h
//  LocalMusicLoad
//
//  Created by Mr.Sunday on 15/6/16.
//  Copyright (c) 2015年 novogene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

//音乐时长格式转换
+ (NSString *)getDuration:(float)duration;
//简拼
- (NSString *)shortPinYin;
//是否为中日韩文字
- (BOOL)isZhKoJa;
// 音译,不带声标
- (NSString *)transliterateString;

+ (NSString *)formatSize:(double)size;

// 生成唯一ID
+ (NSString *)uniqueID;
- (NSString *)trim;

// md5
- (NSString *)md5String;

/**
 * 返回当前字符串对应的二维码图像
 *
 * 二维码的实现是将字符串传递给滤镜，滤镜直接转换生成二维码图片
 */
- (UIImage *)createRRcode;


- (NSString *)sha256;

@end
