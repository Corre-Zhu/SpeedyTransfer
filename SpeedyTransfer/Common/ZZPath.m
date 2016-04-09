//
//  ZZPath.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "ZZPath.h"

@implementation ZZPath

+ (NSString *)documentPath {
    static NSString *documentPath;
    if (!documentPath) {
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [[searchPaths objectAtIndex:0] copy];
    }
    return documentPath;
}

+ (NSString *)headImagePath {
    static NSString *headImagePath;
    if (!headImagePath) {
        headImagePath = [[self documentPath] stringByAppendingPathComponent:@"HeadImage"];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:headImagePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:headImagePath withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    return headImagePath;
}

+ (NSString *)downloadPath {
    static NSString *downloadPath;
    if (!downloadPath) {
        downloadPath = [[ZZPath documentPath] stringByAppendingPathComponent:@"Download"];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    return downloadPath;
}

+ (NSString *)tmpUploadPath {
    static NSString *uploadPath;
    if (!uploadPath) {
        uploadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Upload"];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:uploadPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:uploadPath withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    return uploadPath;
}

+ (NSString *)tmpReceivedPath {
    static NSString *receivedPath;
    if (!receivedPath) {
        receivedPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Received"];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:receivedPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:receivedPath withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    return receivedPath;
}

@end
