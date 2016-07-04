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

@end
