//
//  HTKeychainUtil.h
//  
//
//  Created by Pat on 14-4-8.
//  Copyright (c) 2014年 HT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTNTTime;

@interface HTKeychainUtil : NSObject

+ (void)setOpenUDID:(NSString *)openUDID;
+ (NSString *)openUDID;

@end
