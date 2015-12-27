//
//  NSDate+ZZ.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "NSDate+ZZ.h"

@implementation NSDate (ZZ)

- (NSString *)dateString {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:calendar];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return [formatter stringFromDate:self];
}

@end
