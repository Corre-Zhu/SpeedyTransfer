//
//  NSDictionary+HT.h
//  HelloTalk_Binary
//
//  Created by 任健生 on 13-6-18.
//  Copyright (c) 2013年 HT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HT)

- (id)idForKey:(id)key;
- (NSString *)stringForKey:(id)key;
- (BOOL)boolForKey:(id)key;
- (int)intForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (uint)uintForKey:(id)key;
- (double)doubleForKey:(id)key;
- (float)floatForKey:(id)key;
- (long long)longLongForKey:(id)key;
- (UInt32)uInt32ForKey:(id)key;
- (UInt64)uInt64ForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSDictionary *)dictionaryForKey:(id)key;

@end
