//
//  ZZCategory.h
//
//
//  Created by ZZ.
//
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const UIStatusBarOrientationDidChangeNotification;

#define IOS9 [[UIDevice currentDevice] isIOS9]
#define IOS8 [[UIDevice currentDevice] isIOS8]
#define IOS7 [[UIDevice currentDevice] isIOS7]
#define IOS6 [[UIDevice currentDevice] isIOS6]
#define iPad [[UIDevice currentDevice] isPad]

@interface UIDevice (ZZ)

- (NSString *)openUDID;
- (NSString *)devicePlatform;
- (BOOL)isPhone;
- (BOOL)isPod;
- (BOOL)isPad;
- (BOOL)isIOS6;
- (BOOL)isIOS7;
- (BOOL)isIOS8;
- (BOOL)isIOS9;
- (BOOL)isPortrait;
- (BOOL)isLandscape;

- (float)screenWidth;
- (float)screenHeight;
- (float)statusbarWidth;
- (float)statusbarHeight;

+ (NSString *)getWifiName;
+ (NSDictionary *)getIpAddresses;

@end
