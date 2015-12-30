//
//  ZZMacros.h
//
//
//  Created by ZZ.
//
//

#ifndef ZZ_Macros_h
#define ZZ_Macros_h

#define IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640.0f, 1136.0f), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750.0f, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242.0f, 2208.0f), [[UIScreen mainScreen] currentMode].size) : NO)

//动态获取设备高度
#define IPHONE_STATUSBAR_WIDTH          [[UIDevice currentDevice] statusbarWidth]
#define IPHONE_STATUSBAR_HEIGHT         [[UIDevice currentDevice] statusbarHeight]
#define IPHONE_WIDTH                    [[UIDevice currentDevice] screenWidth]
#define IPHONE_HEIGHT                   [[UIDevice currentDevice] screenHeight]
#define IPHONE_HEIGHT_WITHOUTSTATUSBAR  IPHONE_HEIGHT - IPHONE_STATUSBAR_HEIGHT
#define IPHONE_HEIGHT_WITHOUTTOPBAR     IPHONE_HEIGHT - 44 - IPHONE_STATUSBAR_HEIGHT

#define MINWIDTH MIN(IPHONE_WIDTH, IPHONE_HEIGHT)
#define MAXHEIGHT MAX(IPHONE_WIDTH, IPHONE_HEIGHT)

#define IPHONE_WIDTHDIFF                IPHONE_WIDTH - 320.0f
#define IPHONE_HEIGHTDIFF               IPHONE_HEIGHT - 480.0f
#define IPHONE_WIDTHDIFF_HALF           (IPHONE_WIDTH - 320.0f) / 2.0f
#define IPHONE_HEIGHTDIFF_HALF          (IPHONE_HEIGHT - 480.0f) / 2.0f

#define AutoImportPhoto @"AutoImportPhoto"
#define AutoImportVideo @"AutoImportVideo"

#endif
