//
//  ZZPath.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZPath : NSObject

+ (NSString *)documentPath;
+ (NSString *)headImagePath;
+ (NSString *)downloadPath;
+ (NSString *)tmpUploadPath;
+ (NSString *)tmpReceivedPath; // 通过浏览器post接收到的文件

@end
