//
//  STMusicInfoModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/16.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STMusicInfoModel : NSObject

@property (nonatomic, strong) NSString *format;			// 格式
@property (nonatomic, strong) NSString *title;			// 歌曲名
@property (nonatomic, strong) NSString *shortTitle;     // 歌曲名的简称
@property (nonatomic, strong) NSString *albumName;		// 专辑名
@property (nonatomic, strong) NSString *artist;			// 作者
@property (nonatomic, strong) NSData *artwork;			// 封面图片
@property (nonatomic, assign) NSString *duration;		// 时间
@property (nonatomic, strong) NSURL *url;               // music url path

// 读取手机系统的音乐文件
+ (NSArray *)musicModelList;

@end
