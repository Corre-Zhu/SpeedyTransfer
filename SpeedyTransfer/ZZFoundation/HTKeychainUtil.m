//
//  HTKeychainUtil.m
//  HelloTalk_Binary
//
//  Created by Pat on 14-4-8.
//  Copyright (c) 2014年 HT. All rights reserved.
//

#import "HTKeychainUtil.h"
#import "HTSFHFKeychainUtils.h"

@implementation HTKeychainUtil

static NSString *serviceName = @"com.helloTalk.helloTalk";
static NSString *openUDIDName = @"openudid";
static NSString *translationPurchaseTmpEndDateDateName = @"translationPurchaseTmpEndDateDate";

+ (void)setOpenUDID:(NSString *)openUDID {
    if (openUDID.length <= 0) {
        return;
    }
    [HTSFHFKeychainUtils storeUsername:openUDIDName andPassword:openUDID forServiceName:serviceName updateExisting:YES error:NULL];
}

+ (NSString *)openUDID {
    return [HTSFHFKeychainUtils getPasswordForUsername:openUDIDName andServiceName:serviceName error:NULL];
}

+ (void)setTranslationPurchaseTmpEndDate:(NSDate *)date {
    if (!date) {
        return;
    }
    NSString *dateString = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    NSString *userId = [[HTUserCache sharedCache] stringForKey:HT_UserId];
    [HTSFHFKeychainUtils storeUsername:[NSString stringWithFormat:@"%@_%@",userId,translationPurchaseTmpEndDateDateName] andPassword:dateString forServiceName:serviceName updateExisting:YES error:NULL];
}

+ (NSDate *)translationPurchaseTmpEndDate {
    NSString *userId = [[HTUserCache sharedCache] stringForKey:HT_UserId];
    NSString *dateString = [HTSFHFKeychainUtils getPasswordForUsername:[NSString stringWithFormat:@"%@_%@",userId,translationPurchaseTmpEndDateDateName] andServiceName:serviceName error:NULL];
    if (dateString.length <= 0) {
        // 如果不存在缓存时间,返回昨天的时间
        return [NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60];
    }
    double timeInterval = dateString.doubleValue;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}

+ (void)setLastTime:(HTNTTime *)time andUserId:(NSString *)userid andTitleName:(NSString *)titleName
{
    if (!time) {
        return;
    }
    NSString *lastTime = [NSString stringWithFormat:@"%d+%d+%d+%d+%d+%d", time.wYear, time.wMonth, time.wDay, time.wHour, time.wMinute, time.wSecond];
    NSString *username = [titleName stringByAppendingString:userid];
    BOOL isTestServer = [[NSUserDefaults standardUserDefaults] integerForKey:@"testServerIsOn"];
    if (isTestServer) {
        username = [username stringByAppendingString:@"testserver"];
    }
    [HTSFHFKeychainUtils storeUsername:username andPassword:lastTime forServiceName:serviceName updateExisting:YES error:NULL];
}

+ (HTNTTime *)lastTimeWithUserId:(NSString *)userid andTitleName:(NSString *)titleName
{
    HTNTTime *lastTime = [[HTNTTime alloc] init];
    NSString *username = [titleName stringByAppendingString:userid];
    BOOL isTestServer = [[NSUserDefaults standardUserDefaults] integerForKey:@"testServerIsOn"];
    if (isTestServer) {
        username = [username stringByAppendingString:@"testserver"];
    }
    NSString *lastTimeString = [HTSFHFKeychainUtils getPasswordForUsername:username andServiceName:serviceName error:NULL];
    if (lastTimeString) {
        NSArray *array = [lastTimeString componentsSeparatedByString:@"+"];
        if (array.count == 6) {
            lastTime.wYear = ((NSNumber *)[array objectAtIndex:0]).integerValue;
            lastTime.wMonth = ((NSNumber *)[array objectAtIndex:1]).integerValue;
            lastTime.wDay = ((NSNumber *)[array objectAtIndex:2]).integerValue;
            lastTime.wHour = ((NSNumber *)[array objectAtIndex:3]).integerValue;
            lastTime.wMinute = ((NSNumber *)[array objectAtIndex:4]).integerValue;
            lastTime.wSecond = ((NSNumber *)[array objectAtIndex:5]).integerValue;
        }
    }
    return lastTime;
}

@end
