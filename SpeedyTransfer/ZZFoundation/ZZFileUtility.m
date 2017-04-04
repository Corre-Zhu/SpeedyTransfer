//
//  ZZFileUtility.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/27.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "ZZFileUtility.h"
#import <Photos/Photos.h>
#import "STMusicInfo.h"
#import "STContactInfo.h"
#import <GCDWebServerFunctions.h>
#import "NSString+Extension.h"

@interface ZZFileUtility ()

@property (nonatomic, strong) NSMutableDictionary *mutableDic;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) FileInfoCompletionBlock completionBlock;

@end

@implementation ZZFileUtility

- (void)setObject:(NSDictionary *)fileInfo forKey:(id)object {
    @synchronized(self) {
        [self.mutableDic setObject:fileInfo forKey:object];
        
        if (self.mutableDic.count == self.items.count) {
            NSMutableArray *fileInfos = [NSMutableArray arrayWithCapacity:_items.count];
            for (id object in self.items) {
                [fileInfos addObject:[_mutableDic objectForKey:object]];
            }
            
            _completionBlock(fileInfos);
        }
        
    }
    
}

- (void)fileInfoWithItems:(NSArray *)items completionBlock:(FileInfoCompletionBlock)completionBlock {
    _items = items;
    _mutableDic = [NSMutableDictionary dictionaryWithCapacity:items.count];
    _completionBlock = completionBlock;
    
    NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
    if (address.length == 0) {
        // 获取个人热点ip
        address = [UIDevice hotspotAddress];
    }
    
    for (id object in items) {
        if ([object isKindOfClass:[PHAsset class]]) {
            PHAsset *asset = object;
            NSString *localIdentifier = asset.localIdentifier;
            if (IOS9 && asset.mediaType == PHAssetMediaTypeVideo) {
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    NSArray *tracks = [asset tracks];
                    float estimatedSize = 0.0 ;
                    for (AVAssetTrack * track in tracks) {
                        float rate = ([track estimatedDataRate] / 8); // convert bits per second to bytes per second
                        float seconds = CMTimeGetSeconds([track timeRange].duration);
                        estimatedSize += seconds * rate;
                    }
                    
                    
                    NSString *temp = [info stringForKey:@"PHImageFileSandboxExtensionTokenKey"];
                    NSString *fileName = [temp.lastPathComponent uppercaseString];
                    NSUInteger fileSize = estimatedSize;
                    NSString *fileType = [fileName pathExtension];
                    
                    NSString *fileUrl = @"";
                    NSString *thumbnailUrl = @"";
                    if (address.length > 0) {
                        fileUrl = [NSString stringWithFormat:@"http://%@:%@/image/origin/%@", address, @(KSERVERPORT), localIdentifier];
                        thumbnailUrl = [NSString stringWithFormat:@"http://%@:%@/image/thumbnail/%@", address, @(KSERVERPORT), localIdentifier];
                    }
                   
                    
                    NSLog(@"file size = %@", @(fileSize));
                    
                    NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                               FILE_TYPE: fileType,
                                               FILE_SIZE: @(fileSize),
                                               FILE_URL: fileUrl,
                                               ICON_URL: thumbnailUrl,
                                               ASSET_ID: localIdentifier,
                                               FILE_IDENTIFIER: [NSString uniqueID]};
                    [self setObject:fileInfo forKey:object];
                    
                }];

            } else {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                    if (url.absoluteString.length > 0 && imageData.length > 0) {
                        NSString *fileName = [url.absoluteString lastPathComponent];
                        NSUInteger fileSize = imageData.length;
                        NSString *fileType = [url.absoluteString pathExtension];
                        
                        NSString *fileUrl = @"";
                        NSString *thumbnailUrl = @"";
                        
                        if (address.length > 0) {
                            fileUrl = [NSString stringWithFormat:@"http://%@:%@/image/origin/%@", address, @(KSERVERPORT), localIdentifier];
                            thumbnailUrl = [NSString stringWithFormat:@"http://%@:%@/image/thumbnail/%@", address, @(KSERVERPORT), localIdentifier];
                            
                        }
                        
                        NSLog(@"file size = %@", @(fileSize));
                        
                        NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                                   FILE_TYPE: fileType,
                                                   FILE_SIZE: @(fileSize),
                                                   FILE_URL: fileUrl,
                                                   ICON_URL: thumbnailUrl,
                                                   ASSET_ID: localIdentifier,
                                                   FILE_IDENTIFIER: [NSString uniqueID]};
                        [self setObject:fileInfo forKey:object];
                        
                    }}];
            }
        } else if ([object isKindOfClass:[STContactInfo class]]) {
            STContactInfo *contactInfo = object;
            NSString *fileName = contactInfo.name;
            NSUInteger fileSize = contactInfo.size;
            NSString *fileType = @"vcard";
            NSString *fileUrl = @"";
            if (address.length > 0) {
                fileUrl = [NSString stringWithFormat:@"http://%@:%@/contact/%@", address, @(KSERVERPORT), @(contactInfo.recordId)];
            }
            
            NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                       FILE_TYPE: fileType,
                                       FILE_SIZE: @(fileSize),
                                       FILE_URL: fileUrl,
                                       RECORD_ID: @(contactInfo.recordId),
                                       FILE_IDENTIFIER: [NSString uniqueID]};
            [self setObject:fileInfo forKey:object];
        } else if ([object isKindOfClass:[STMusicInfo class]]) {
            STMusicInfo *musciInfo = object;
            NSString *fileName = musciInfo.title;
            NSUInteger fileSize = musciInfo.fileSize;
            NSString *fileType = @"mp3";
            
            NSString *fileUrl = @"";
            if (address.length > 0) {
                fileUrl = [NSString stringWithFormat:@"http://%@:%@/music/%@", address, @(KSERVERPORT), musciInfo.persistentId];
            }
            
            NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                       FILE_TYPE: fileType,
                                       FILE_SIZE: @(fileSize),
                                       FILE_URL: fileUrl,
                                       RECORD_ID: musciInfo.persistentId,
                                       FILE_IDENTIFIER: [NSString uniqueID]};
            [self setObject:fileInfo forKey:object];
        } else if ([object isKindOfClass:[STFileInfo class]]) {
            STFileInfo *file = object;
            NSString *fileName = file.fileName;
            NSUInteger fileSize = file.fileSize;
            NSString *fileType = file.pathExtension;
            if (fileType.length == 0) {
                fileType = @"myfile";
            }
            NSString *fileUrl = @"";
            if (address.length > 0) {
                fileUrl = [NSString stringWithFormat:@"http://%@:%@/myfile/%@", address, @(KSERVERPORT), file.localPath.lastPathComponent];
            }
            
            NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                       FILE_TYPE: fileType,
                                       FILE_SIZE: @(fileSize),
                                       FILE_URL: fileUrl,
                                       FILE_IDENTIFIER: file.identifier};
            [self setObject:fileInfo forKey:object];
        }
    }
}

@end
