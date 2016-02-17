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

static NSString *serviceName = @"com.zz.SpeedyTransfer";
static NSString *openUDIDName = @"openudid";

+ (void)setOpenUDID:(NSString *)openUDID {
    if (openUDID.length <= 0) {
        return;
    }
    [HTSFHFKeychainUtils storeUsername:openUDIDName andPassword:openUDID forServiceName:serviceName updateExisting:YES error:NULL];
}

+ (NSString *)openUDID {
    return [HTSFHFKeychainUtils getPasswordForUsername:openUDIDName andServiceName:serviceName error:NULL];
}

@end
