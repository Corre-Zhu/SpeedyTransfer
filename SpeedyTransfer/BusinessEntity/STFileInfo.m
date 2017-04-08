//
//  STFileInfo.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/4/4.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STFileInfo.h"

@implementation STFileInfo

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.identifier = [dic stringForKey:DBFileTransfer._identifier];
        self.fileType = [dic integerForKey:DBFileTransfer._fileType];
        self.fileName = [dic stringForKey:DBFileTransfer._fileName];
        self.pathExtension = [self.fileName pathExtension];
        self.fileSize = [dic doubleForKey:DBFileTransfer._fileSize];
        self.fileId = [dic integerForKey:DBFileTransfer._id];
        
        NSString *path = [[ZZPath downloadPath] stringByAppendingPathComponent:self.identifier];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            path = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", self.identifier, self.pathExtension]];
        }
        
        self.localPath = path;
        self.fileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
