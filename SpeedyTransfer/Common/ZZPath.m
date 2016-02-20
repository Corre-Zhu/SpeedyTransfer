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

+ (NSString *)picturePath {
    static NSString *picturePath;
    if (!picturePath) {
        picturePath = [[ZZPath documentPath] stringByAppendingPathComponent:@"Picture"];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:picturePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:picturePath withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    return picturePath;
}

@end
