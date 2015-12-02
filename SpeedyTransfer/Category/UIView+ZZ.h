//
//  UIView+HT.h
//
//
//  Created by ZZ
//
//

#import <UIKit/UIKit.h>

@interface UIView (ZZ)

- (CGFloat)width;
- (CGFloat)height;
- (CGFloat)top;
- (CGFloat)left;
- (CGFloat)bottom;
- (CGFloat)right;
- (CGFloat)centerX;
- (CGFloat)centerY;

- (void)setTop:(CGFloat)top;
- (void)setLeft:(CGFloat)left;
- (void)setRight:(CGFloat)right;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setCenterX:(CGFloat)centerX;
- (void)setCenterY:(CGFloat)centerY;

+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve;
+ (UIViewAnimationOptions)keyboardAnimationOptions;

- (BOOL)containSubviewWithClass:(Class)clazz;

@end

@interface UIView (Private)

- (NSString *)recursiveDescription;

@end
