//
//  STFeedbackInfo.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STFeedbackInfo.h"

@interface STFeedbackInfo ()
{
}

@end

@implementation STFeedbackInfo

HT_DEF_SINGLETON(STFeedbackInfo, shareInstant);

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.messageID = [dic stringForKey:self._messageID];
        self.content = [dic stringForKey:self._content];
        self.transferStatus = [dic intForKey:self._transferStatus];
        self.messageType = [dic intForKey:self._messageType];
        self.time = [dic stringForKey:self._time];
        
        [self setup];
    }
    
    return self;
}

- (void)setup {
    CGRect rect = [self.content boundingRectWithSize:CGSizeMake(IPHONE_WIDTH - 150.0f, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]} context:nil];
    _textHeight = rect.size.height;
    _textWidth = rect.size.width;
    _cellHeight = _textHeight + 45.0f;
}

- (NSString *)_tableName {
    return @"FeedbackMessages";
}

-(NSString *)_id{return @"ID";}

- (NSString *)_messageID {
    return @"MESSAGEID";
}

- (NSString *)_transferStatus {
    return @"TRANSFERSTATUS";
}

- (NSString *)_content {
    return @"CONTENT";
}

- (NSString *)_messageType {
    return @"MESSAGETYPE";
}

- (NSString *)_time {
    return @"TIME";
}

@end
