//
//  STFileInfo.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/4/4.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFileTransferInfo.h"

@interface STFileInfo : NSObject<NSCopying>

@property (nonatomic) STFileType fileType;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *pathExtension;
@property (nonatomic) double fileSize;
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic) BOOL fileExist;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
