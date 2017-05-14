//
//  ZZFileUtility.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/27.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "ZZFileUtility.h"
#import <Photos/Photos.h>
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
        
        if (address.length == 0) {
            address = @"192.168.1.99"; // iOS之间Multipeer传输，可以不用连接wifi，此时ip地址为空
        }
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
                        fileUrl = [NSString stringWithFormat:@"http://%@:%@/image/origin/%@/%@", address, @(KSERVERPORT), localIdentifier, fileName];
                        thumbnailUrl = [NSString stringWithFormat:@"http://%@:%@/image/thumbnail/%@/%@", address, @(KSERVERPORT), localIdentifier, fileName];
                    }
                   
                    
                    NSLog(@"file size = %@", @(fileSize));
                    
                    NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                               FILE_TYPE: fileType,
                                               FILE_SIZE_IOS: @(fileSize),
                                               FILE_SIZE: [NSString formatSize:fileSize],
                                               FILE_URL: fileUrl,
                                               ICON_URL: thumbnailUrl,
                                               ASSET_ID: localIdentifier,
                                               FILE_IDENTIFIER: [NSString uniqueID]};
                    [self setObject:fileInfo forKey:object];
                    
                }];

            } else {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                    if (!url) {
                        NSLog(@"ZZFileUtility requestImageDataForAsset error");
                        url = [NSURL fileURLWithPath:@"file://fetchError.png"];
                    }
                    
                    //if (url.absoluteString.length > 0 && imageData.length > 0) {
                        NSString *fileName = [url.absoluteString lastPathComponent];
                        NSUInteger fileSize = imageData.length;
                        NSString *fileType = [url.absoluteString pathExtension];
                        
                        NSString *fileUrl = @"";
                        NSString *thumbnailUrl = @"";
                        
                        if (address.length > 0) {
                            fileUrl = [NSString stringWithFormat:@"http://%@:%@/image/origin/%@/%@", address, @(KSERVERPORT), localIdentifier, fileName];
                            thumbnailUrl = [NSString stringWithFormat:@"http://%@:%@/image/thumbnail/%@/%@", address, @(KSERVERPORT), localIdentifier, fileName];
                            
                        }
                        
                        NSLog(@"file size = %@", @(fileSize));
                        
                        NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                                   FILE_TYPE: fileType,
                                                   FILE_SIZE_IOS: @(fileSize),
                                                   FILE_SIZE: [NSString formatSize:fileSize],
                                                   FILE_URL: fileUrl,
                                                   ICON_URL: thumbnailUrl,
                                                   ASSET_ID: localIdentifier,
                                                   FILE_IDENTIFIER: [NSString uniqueID]};
                        [self setObject:fileInfo forKey:object];
                        
                 //   }
                 }];
            }
        } else if ([object isKindOfClass:[STContactInfo class]]) {
            STContactInfo *contactInfo = object;
            NSString *fileName = contactInfo.name;
            NSUInteger fileSize = contactInfo.size;
            NSString *fileType = @"vcard";
            NSString *fileUrl = @"";
            if (address.length > 0) {
                fileUrl = [NSString stringWithFormat:@"http://%@:%@/contact/%@/%@.vcard", address, @(KSERVERPORT), @(contactInfo.recordId), @(contactInfo.recordId)];
            }
            
            NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                       FILE_TYPE: fileType,
                                       FILE_SIZE_IOS: @(fileSize),
                                       FILE_SIZE: [NSString formatSize:fileSize],
                                       CONTACT_SIZE_ANDROID: @(contactInfo.androidSize),
                                       FILE_URL: fileUrl,
                                       RECORD_ID: @(contactInfo.recordId),
                                       FILE_IDENTIFIER: [NSString uniqueID]};
            [self setObject:fileInfo forKey:object];
        }/* else if ([object isKindOfClass:[STMusicInfo class]]) {
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
                                       FILE_SIZE_IOS: @(fileSize),
                                       FILE_SIZE: [NSString formatSize:fileSize],
                                       FILE_URL: fileUrl,
                                       RECORD_ID: musciInfo.persistentId,
                                       FILE_IDENTIFIER: [NSString uniqueID]};
            [self setObject:fileInfo forKey:object];
        }*/ else if ([object isKindOfClass:[STFileInfo class]]) {
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
                                       FILE_SIZE_IOS: @(fileSize),
                                       FILE_SIZE: [NSString formatSize:fileSize],
                                       FILE_URL: fileUrl,
                                       FILE_IDENTIFIER: file.identifier};
            [self setObject:fileInfo forKey:object];
        }
    }
}

+ (NSData *)dataWithVcardForAndroid:(NSData *)vcard {
    NSString *lastName;
    NSString *firstName;
    NSString *name;
    
    NSMutableArray *phoneArr = [NSMutableArray array];
    
    NSString *vcardStr = [[NSString alloc] initWithData:vcard encoding:NSUTF8StringEncoding];

    
    NSArray *lines = [vcardStr componentsSeparatedByString:@"\n"];
    
    for(NSString* line in lines)
    {
        
        if ([line hasPrefix:@"BEGIN"])
        {
            NSLog(@"parse start");
        }
        else if ([line hasPrefix:@"END"])
        {
            NSLog(@"parse end");
        }
        else if ([line hasPrefix:@"N:"])
        {
            NSArray *upperComponents = [line componentsSeparatedByString:@":"];
            NSArray *components = [[upperComponents objectAtIndex:1] componentsSeparatedByString:@";"];
            
            lastName = [components objectAtIndex:0];
            firstName = [components objectAtIndex:1];
            
            NSLog(@"firstName: %@, lastName: %@", firstName, lastName);
            
        }
        else if ([line hasPrefix:@"FN:"])
        {
            NSArray *upperComponents = [line componentsSeparatedByString:@":"];
            name = [upperComponents objectAtIndex:1];
            NSLog(@"name: %@", name);
            
        }
        else if ([line hasPrefix:@"TEL;"])
        {
            NSArray *components = [line componentsSeparatedByString:@":"];
            NSString *phoneNumber = [components objectAtIndex:1];
            if (phoneNumber.length > 0) {
                if ([line.uppercaseString containsString:@"CELL"]) {
                    [phoneArr addObject:@{@"2": phoneNumber}];
                } else if ([line.uppercaseString containsString:@"HOME"]) {
                    [phoneArr addObject:@{@"1": phoneNumber}];
                }
                
                NSLog(@"phoneNumber %@",phoneNumber);

            }
            
        }
    }
    
    NSMutableArray *items = [NSMutableArray array];
    
    if (name.length > 0) {
        NSMutableDictionary *nameDic = [NSMutableDictionary dictionary];
        [nameDic setObject:@"vnd.android.cursor.item/name" forKey:@"mimetype"];
        [nameDic setObject:name forKey:@"data1"];
        if (firstName.length > 0) {
            [nameDic setObject:firstName forKey:@"data3"];
        }
        
        if (lastName.length > 0) {
            [nameDic setObject:lastName forKey:@"data2"];
        }
        
        [nameDic setObject:@"2" forKey:@"data10"];
        [nameDic setObject:@"0" forKey:@"data11"];

        [items addObject:nameDic];
    }
    
    for (NSDictionary *dic in phoneArr) {
        NSMutableDictionary *nameDic = [NSMutableDictionary dictionary];
        [nameDic setObject:@"vnd.android.cursor.item/phone_v2" forKey:@"mimetype"];
        [nameDic setObject:dic.allKeys.firstObject forKey:@"data2"];
        [nameDic setObject:dic.allValues.firstObject forKey:@"data1"];
        
        [items addObject:nameDic];
    }
    
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:@"0" forKey:@"starred"];
    [result setObject:@"0" forKey:@"send_to_voicemail"];
    [result setObject:@"com.local.contacts" forKey:@"account_type"];
    [result setObject:@"local_contact" forKey:@"account_name"];
    
    if (items.count > 0) {
        [result setObject:items forKey:@"items"];
    }
    
    NSMutableData *mutableData = [NSMutableData data];
    UInt32 count = 1;
    [mutableData appendBytes:&count length:4];
    
    NSData *jsonData = [[result jsonString] dataUsingEncoding:NSUTF8StringEncoding];
    
    UInt32 lenght = (UInt32)jsonData.length;
    [mutableData appendBytes:&lenght length:4];
    [mutableData appendData:jsonData];
    
    
    return mutableData;
}

@end
