//
//  ZZFunction.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/7/4.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZFunction : NSObject

+ (UIImage *)qrCodeImageWithStr:(NSString *)string withSize:(CGFloat)size topImage:(UIImage *)topImage;

+ (void)goToWifiPref;
+ (void)goToHotspotPref;

+ (STFileType)fileTypeWithPathExtension:(NSString *)fileType;


@end
