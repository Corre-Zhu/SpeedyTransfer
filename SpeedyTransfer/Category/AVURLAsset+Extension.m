//
//  AVURLAsset+Extension.m
//  LocalMusicLoad
//
//  Created by Mr.Sunday on 15/6/16.
//  Copyright (c) 2015年 novogene. All rights reserved.
//

#import "AVURLAsset+Extension.h"
#import "NSString+Extension.h"

@implementation AVURLAsset (Extension)

/// 获取mp3信息
+ (NSDictionary *)getMp3InfoWithURL:(NSURL *)url
{
    // 1.创建 音乐数据对象
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    // 2.创建存储数据模型
    NSMutableDictionary *musicDict = [NSMutableDictionary dictionary];
    
    // 3.获取数据
    for (NSString *format in [mp3Asset availableMetadataFormats])
    {
        // 格式
        [musicDict setObject:format forKey:@"format"];
        
        for (AVMetadataItem *metadataitem in [mp3Asset metadataForFormat:format])
        {
            if ([metadataitem.commonKey isEqualToString:@"artwork"])
            {
                NSData *data = (NSData *)metadataitem.value;
                [musicDict setObject:data forKey:@"artwork"];
            }
            else
            {
                if([metadataitem.commonKey isEqualToString:@"title"])
                {
                    NSString *title = (NSString *)metadataitem.value;
                    [musicDict setObject:title forKey:@"title"];
                }
                else
                {
                    if([metadataitem.commonKey isEqualToString:@"artist"])
                    {
                        NSString *artist = (NSString *)metadataitem.value;
                        [musicDict setObject:artist forKey:@"artist"];
                    }
                    else
                    {
                        if([metadataitem.commonKey isEqualToString:@"albumName"])
                        {
                            NSString *albumName = (NSString *)metadataitem.value;
                            [musicDict setObject:albumName forKey:@"albumName"];
                        }
                    }
                }
            }
        }
    }
    
    //音乐时长格式转换
    CMTime durationTime = mp3Asset.duration;
    
    NSString *duration = [NSString getDuration:CMTimeGetSeconds(durationTime)];
    
    [musicDict setObject:duration forKey:@"duration"];
    [musicDict setObject:url forKey:@"url"];
    
    return musicDict;
}


//本地音乐
-(void)getMp3InfoWithAVURLAsset:(NSString *)name
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    for (NSString *format in [mp3Asset availableMetadataFormats]) {
        NSLog(@"formatString: %@",format);
        for (AVMetadataItem *metadataitem in [mp3Asset metadataForFormat:format]) {
            
            NSLog(@"commonKey = %@",metadataitem.commonKey);
            if ([metadataitem.commonKey isEqualToString:@"artwork"])
            {
                NSData *data = (NSData *)metadataitem.value;
                NSLog(@"%@",data);
            
                break;
            }
            else if([metadataitem.commonKey isEqualToString:@"title"])
            {
                NSString *title = (NSString *)metadataitem.value;
                NSLog(@"title: %@",title);
            }
            else if([metadataitem.commonKey isEqualToString:@"artist"])
            {
                NSString *artist = (NSString *)metadataitem.value;
                NSLog(@"artist: %@",artist);
            }
            else if([metadataitem.commonKey isEqualToString:@"albumName"])
            {
                NSString *albumName = (NSString *)metadataitem.value;
                
                NSLog(@"albumName: %@",albumName);
            }
        }
    }
    
    CMTime durationTime = mp3Asset.duration;
    CGFloat duration = CMTimeGetSeconds(durationTime);
    NSLog(@"%lf",duration);
}

@end
