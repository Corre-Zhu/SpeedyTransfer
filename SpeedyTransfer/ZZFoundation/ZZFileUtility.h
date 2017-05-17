//
//  ZZFileUtility.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/27.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FileInfoCompletionBlock)(NSArray *fileInfos);

@interface ZZFileUtility : NSObject

- (void)fileInfoWithItems:(NSArray *)items completionBlock:(FileInfoCompletionBlock)completionBlock;

+ (NSString *)pathForContacts:(NSArray *)contacts;

@end
