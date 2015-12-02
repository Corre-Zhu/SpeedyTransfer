//
//  UIColor+ZZ.h
//
//
//  Created by ZZ.
//
//

#import <UIKit/UIKit.h>

#define RGB(r,g,b) [UIColor rgbColorWithRed:r green:g blue:b]
#define RGBA(r,g,b,a) [UIColor rgbColorWithRed:r green:g blue:b alpha:a]
#define RGBFromHex(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface UIColor (ZZ)

+ (UIColor *)rgbColorWithRed:(float)red green:(float)green blue:(float)blue;
+ (UIColor *)rgbColorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

@end
