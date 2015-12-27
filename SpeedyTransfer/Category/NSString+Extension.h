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

@end
