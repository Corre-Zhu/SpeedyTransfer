//
//  HTKeychainUtil.h
//  HelloTalk_Binary
//
//  Created by Pat on 14-4-8.
//  Copyright (c) 2014年 HT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTNTTime;

@interface HTKeychainUtil : NSObject

+ (void)setOpenUDID:(NSString *)openUDID;
+ (NSString *)openUDID;

+ (void)setTranslationPurchaseTmpEndDate:(NSDate *)date;
+ (NSDate *)translationPurchaseTmpEndDate;

+ (void)setLastTime:(HTNTTime *)time andUserId:(NSString *)userid andTitleName:(NSString *)titleName;
+ (HTNTTime *)lastTimeWithUserId:(NSString *)userid andTitleName:(NSString *)titleName;

@end
