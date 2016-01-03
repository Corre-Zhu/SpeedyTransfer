//
//  STFeedbackInfo.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSingleton.h"

#define DBFeedbackMessages [STFeedbackInfo shareInstant]

typedef NS_ENUM(NSInteger, STFeedbackMessageType) {
    STFeedbackMessageTypeText          = 0,
    STFeedbackMessageTypeDate
};

typedef NS_ENUM(NSInteger, STFeedbackTransferStatus) {
    STFeedbackTransferStatusSending          = 0,
    STFeedbackTransferStatusSended
};

@interface STFeedbackInfo : NSObject

HT_AS_SINGLETON(STFeedbackInfo, shareInstant)

@property(nonatomic,copy)NSString *messageID;
@property(nonatomic,assign)NSInteger transferStatus;
@property(nonatomic,assign)NSInteger messageType;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,assign)NSString *time;

@property (nonatomic) CGFloat textHeight;
@property (nonatomic) CGFloat textWidth;
@property (nonatomic) CGFloat cellHeight;

- (void)setup;

@property(nonatomic,readonly)NSString *_id;
@property(nonatomic,readonly)NSString *_tableName;
@property(nonatomic,readonly)NSString *_messageID;
@property(nonatomic,readonly)NSString *_transferStatus;
@property(nonatomic,readonly)NSString *_messageType;
@property(nonatomic,readonly)NSString *_content;
@property(nonatomic,readonly)NSString *_time;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
