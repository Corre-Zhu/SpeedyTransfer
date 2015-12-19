//
//  NSString+Extension.m
//  LocalMusicLoad
//
//  Created by Mr.Sunday on 15/6/16.
//  Copyright (c) 2015年 novogene. All rights reserved.
//

#import "NSString+Extension.h"

#define IN_RANGE(x, low, high)  ((low<=(x))&&((x)<=high))
#define IS_JA_HIRAGANA(x)   IN_RANGE(x, 0x3040, 0x309F)
#define IS_JA_KATAKANA(x)   ((IN_RANGE(x, 0x30A0, 0x30FF)&&((x)!=0x30FB))||IN_RANGE(x, 0xFF66, 0xFF9F))
#define IS_JA_KANJI(x)      (IN_RANGE(x, 0x2E80, 0x2EFF)||IN_RANGE(x, 0x2F00, 0x2FDF)||IN_RANGE(x, 0x4E00, 0x9FAF))
#define IS_JA_KUTEN(x)      (((x)==0x3001)||((x)==0xFF64)||((x)==0xFF0E))
#define IS_JA_TOUTEN(x)     (((x)==0x3002)||((x)==0xFF61)||((x)==0xFF0C))
#define IS_JA_SPACE(x)      ((x)==0x3000)
#define IS_JA_FWLATAIN(x)   IN_RANGE(x, 0xFF01, 0xFF5E)
#define IS_JA_FWNUMERAL(x)	IN_RANGE(x, 0xFF10, 0xFF19)
#define IS_JAPANESE_SPECIFIC(x)	(IN_RANGE(x, 0x3040, 0x30FF)||IN_RANGE(x, 0x30A0, 0x30FF)||IN_RANGE(x, 0x31F0, 0x31FF)||IN_RANGE(x, 0xFF62, 0xFF9F))

@implementation NSString (Extension)

//音乐时长格式转换
+(NSString *)getDuration:(float)duration
{
    // 00:00:00
    float time = duration;
    float h = 0;
    if (duration > 3600) {
        
        h = duration / 3600;
        duration = (int)duration % 3600;
    }
    
    float m = duration / 60;
    duration = (int)duration % 60;
    
    if (time > 3600) {
        
        return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)h, (int)m, (int)duration];
    }
    
    return [NSString stringWithFormat:@"%02d:%02d", (int)m, (int)duration];;
}

- (NSString *)shortPinYin{
    NSString *source = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    __block NSMutableString *transliterate = [NSMutableString stringWithString:@""];
    [source enumerateSubstringsInRange:NSMakeRange(0, source.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSString *transliterateString;
        if (![self isZhKoJa]) {
            transliterateString = [substring transliterateString];
        }
        else{
            NSString *temp = [substring transliterateString];
            if (temp.length > 0) {
                transliterateString = [temp substringToIndex:1];
            }
        }
        
        if (transliterateString.length > 0) {
            int c = [transliterateString characterAtIndex:0];
            if ((c >= 65 && c <= 90 ) || (c >= 97 && c <= 122)) {
                [transliterate appendString:transliterateString];
            }
        }
    }];
    return transliterate;
}

- (BOOL)isZhKoJa{
    //    \0x4E00-\0x9FA5 (中文)
    //    \0x3130-\0x318F (韩文)
    //    \0xAC00-\0xD7A3 (韩文)
    //    \0x3040-\0x309F (日文)
    //    \0x30A0-\0x30FF (日文)
    //    \0x31F0-\0x31FF (日文)
    //    \0xFF01-\0xFF9F (日文)
    NSUInteger length = self.length;
    for(int i=0; i<length; i++){
        int ch = [self characterAtIndex:i];
        
        if (IN_RANGE(ch, 0x4e00, 0x9fff)) {
            return YES;
        }
        
        if (IS_JAPANESE_SPECIFIC(ch)) {
            return YES;
        }
        
        if (IN_RANGE(ch, 0x3130, 0x318f) ||
            IN_RANGE(ch, 0xac00, 0xd7a3)) {
            return YES;;
        }
        
    }
    return NO;
    
}

- (NSString *)transliterateString {
    if (self.length <= 0) {
        return nil;
    }
    
    NSMutableString *source = [self mutableCopy];
    
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformToLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    if (source.length <= 0) {
        return nil;
    }
    
    return source;
}

@end