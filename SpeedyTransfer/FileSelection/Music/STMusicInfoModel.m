//
//  STMusicInfoModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/16.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STMusicInfoModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#define LETTER	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"

@implementation STMusicInfoModel

+ (instancetype)musicWithDictionary:(NSDictionary *)dic {
    STMusicInfoModel *model = [[STMusicInfoModel alloc] init];
    model.format = [dic stringForKey:@"format"];
    model.albumName = [dic stringForKey:@"albumName"];
    model.duration = [dic stringForKey:@"duration"];
    model.artist = [dic stringForKey:@"artist"];
    model.title = [dic stringForKey:@"title"];
    if (!model.title) {
        model.title = NSLocalizedString(@"", nil);
    }
    model.url = [dic objectForKey:@"url"];

    return model;
}

+ (NSArray *)musicModelList
{
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] init];
    MPMediaPropertyPredicate *predicate =[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic] forProperty: MPMediaItemPropertyMediaType];
    [mediaQuery addFilterPredicate:predicate];
    NSArray *items = [mediaQuery items];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (MPMediaItem *item in items) {
        NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
        NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
        NSNumber *duration = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                          presetName: AVAssetExportPresetAppleM4A];
        exporter.timeRange = CMTimeRangeMake(kCMTimeZero, songAsset.duration);

        if (!artist) {
            artist = NSLocalizedString(@"未知", nil);
        }
        
        STMusicInfoModel *model = [[STMusicInfoModel alloc] init];
        model.title = title;
        model.url = url;
        model.artist = artist;
        model.duration = [NSString getDuration:duration.integerValue];
        model.fileSize = exporter.estimatedOutputFileLength;
        [tempArray addObject:model];
    }
    
    // 按备注名或者昵称的简拼
    [tempArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        STMusicInfoModel *model1 = obj1;
        STMusicInfoModel *model2 = obj2;
        if (model1.shortTitle.length == 0) {
            model1.shortTitle = [model1.title shortPinYin];
            if (model1.shortTitle.length == 0) {
                model1.shortTitle = model1.title;
            }
        }
        if (model2.shortTitle.length == 0) {
            model2.shortTitle = [model2.title shortPinYin];
            if (model2.shortTitle.length == 0) {
                model2.shortTitle = model2.title;
            }
        }
        
        return [model1.shortTitle compare:model2.shortTitle options:NSCaseInsensitiveSearch];
    }];
    
    NSMutableArray *othersArray = [NSMutableArray array];
    
    NSMutableArray *tempSectionArray = [NSMutableArray array];
    for (STMusicInfoModel *model in tempArray) {
         NSString *letter = nil;
        if ([model.shortTitle length] < 1) {
            letter = @"#";
        }else{
            int unicode = [model.shortTitle characterAtIndex:0];
            if ((unicode>= 0x41 && unicode<= 0x5a) || (unicode>= 0x61 && unicode<= 0x7a)) { //english alphabet
                letter = [[model.shortTitle substringToIndex:1] uppercaseString];
            }else{
                letter = @"#";
            }
        }
        
        if ([letter isEqualToString:@"#"]) {
            [othersArray addObject:model];
            continue;
        }
        
        NSDictionary *dic = tempSectionArray.lastObject;
        if (![dic.allKeys.firstObject isEqualToString:letter]) {
            dic = @{letter: [NSMutableArray array]};
            [tempSectionArray addObject:dic];
        }
        NSMutableArray *arr = dic.allValues.firstObject;
        [arr addObject:model];
    }
    
    if (othersArray.count > 0) {
        [tempSectionArray addObject:@{@"#": othersArray}];
    }

    return tempSectionArray;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[STMusicInfoModel class]]) {
        return NO;
    }
    
    STMusicInfoModel *model = object;
    return [model.url isEqual:self.url];
}

@end
