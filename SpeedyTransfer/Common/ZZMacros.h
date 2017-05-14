//
//  ZZMacros.h
//
//
//  Created by ZZ.
//
//

#ifndef ZZ_Macros_h
#define ZZ_Macros_h

#define DECLARE_WEAK_SELF __typeof(&*self) __weak weakSelf = self
#define DECLARE_STRONG_SELF __typeof(&*self) __strong strongSelf = weakSelf

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
#define HeadImage @"HeadImage"
#define HeadImage_ @"HeadImage_"
#define CustomHeadImage @"CustomHeadImage"

#define DEVICE_NAME @"device_name"

#define FILE_NAME @"file_name"
#define FILE_TYPE @"file_type"
#define FILE_SIZE @"file_size" // 兼容安卓
#define FILE_SIZE_IOS @"file_size_ios" // iOS的文件大小，以字节为单位
#define CONTACT_SIZE_ANDROID @"contact_size_android" // 兼容安卓
#define FILE_URL @"file_url"
#define ICON_URL @"icon_url"
#define ASSET_ID @"asset_id"
#define RECORD_ID @"record_id"
#define FILE_IDENTIFIER @"file_identifier"

#define REQUEST_PATH @"request_path" 
#define TOTAL_BYTES_WRITTEN @"total_bytes_written"
#define START_TIMESTAMP @"start_timestamp"

#define KFileWrittenProgressNotification @"FileWrittenProgressNotification"
#define KReceiveFileNotification @"ReceiveFileNotification"

typedef NS_ENUM(NSInteger, MCPeerConnnectStatus) {
	MCPeerConnnectStatusNormal          = 0,
	MCPeerConnnectStatusConnecting      = 1,
	MCPeerConnnectStatusConnected       = 2,
	MCPeerConnnectStatusDisconnecting   = 3,
};

#endif
