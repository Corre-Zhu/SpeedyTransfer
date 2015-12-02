//
//  UIView+HT.m
//
//
//  Created by ZZ.
//
//

#import "UIView+ZZ.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIView (ZZ)

+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve {
    return curve << 16;
}

+ (UIViewAnimationOptions)keyboardAnimationOptions {
    return IOS7 ? 7 << 16 : 0;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}


- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)centerX {
	return CGRectGetMidX(self.frame);
}

- (void)setCenterX:(CGFloat)centerX {
	CGPoint center = self.center;
	center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY {
	return CGRectGetMidY(self.frame);
}

- (void)setCenterY:(CGFloat)centerY {
	CGPoint center = self.center;
	center.y = centerY;
    self.center = center;
}

- (BOOL)containSubviewWithClass:(Class)clazz {
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:clazz]) {
            return YES;
        } else {
            if ([subView containSubviewWithClass:clazz]) {
                return YES;
            }
        }
    }
    
    return NO;
}


@end
