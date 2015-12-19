//
//  AVURLAsset+Extension.h
//  LocalMusicLoad
//
//  Created by Mr.Sunday on 15/6/16.
//  Copyright (c) 2015年 novogene. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVURLAsset (Extension)


//获取bould中的音乐(下载-缓存)
- (void)getMp3InfoWithAVURLAsset:(NSString *)name;

// 获取手机本地音乐信息
+ (NSDictionary *)getMp3InfoWithURL:(NSURL *)url;

@end
