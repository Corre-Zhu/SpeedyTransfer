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
    
    for (id object in items) {
        if ([object isKindOfClass:[PHAsset class]]) {
            PHAsset *asset = object;
            NSString *localIdentifier = asset.localIdentifier;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
                if (url.absoluteString.length > 0 && imageData.length > 0 && address.length > 0) {
                    NSString *fileName = [url.absoluteString lastPathComponent];
                    NSUInteger fileSize = imageData.length;
                    NSString *fileType = [url.absoluteString pathExtension];
                    NSString *fileUrl = [NSString stringWithFormat:@"http://%@:%@/image/origin/%@", address, @(KSERVERPORT), localIdentifier];
                    NSString *thumbnailUrl = [NSString stringWithFormat:@"http://%@:%@/image/thumbnail/%@", address, @(KSERVERPORT), localIdentifier];
                    
                    NSLog(@"file size = %@", @(fileSize));
                    
                    NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                               FILE_TYPE: fileType,
                                               FILE_SIZE: @(fileSize),
                                               FILE_URL: fileUrl,
                                               ICON_URL: thumbnailUrl,
                                               ASSET_ID: localIdentifier};
                    [self setObject:fileInfo forKey:object];
                
                }}];
        }
    }
}

@end
