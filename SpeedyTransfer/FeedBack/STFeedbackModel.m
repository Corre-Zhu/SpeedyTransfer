//
//  STFeedbackModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STFeedbackModel.h"
#import "AppDelegate.h"
#import "HTFMDatabase.h"
#import "HTSQLBuffer.h"

@interface STFeedbackModel ()
{
    HTFMDatabase *database;
}

@property (nonatomic, strong) NSArray *tempDataSource;

@end

@implementation STFeedbackModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *defaultDbPath = [[ZZPath documentPath] stringByAppendingPathComponent:dbName];
        database = [[HTFMDatabase alloc] initWithPath:defaultDbPath];
        [database open];
        
        HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
        sql.SELECT(@"*").FROM(DBFeedbackMessages._tableName).ORDERBY(DBFeedbackMessages._id, @"ASC");
        FMResultSet *result = [database executeQuery:sql.sql];
        if (result) {
            NSMutableArray *tempArr = [NSMutableArray array];
            while ([result next]) {
                if (result.resultDictionary) {
                    [tempArr addObject:[[STFeedbackInfo alloc] initWithDic:result.resultDictionary]];
                }
            }
            _tempDataSource = [NSArray arrayWithArray:tempArr];
            
            [self setupTimeStr];
        }
    }
    
    return self;
}

- (void)setupTimeStr {
    if (_tempDataSource.count == 0) {
        return;
    }
    
    __block long long lastTime = 0;
    NSMutableArray *temp = [NSMutableArray array];
    [_tempDataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STFeedbackInfo *info = obj;
        NSString *timeStr = [info.time trim];
        if (timeStr.length > 0) {
            long long time = [[[[timeStr componentsSeparatedByString:@" "] lastObject] stringByReplacingOccurrencesOfString:@":" withString:@""] longLongValue];
            if (time - lastTime >= 500) {
                [temp addObject:timeStr];
                lastTime = time;
            }
        }
        
        [temp addObject:obj];
    }];
    
    _dataSource = temp;
}

- (void)addTransferFile:(STFeedbackInfo *)info {
    if (!info) {
        return;
    }
    
    if (!_tempDataSource) {
        _tempDataSource = [NSArray arrayWithObject:info];
    } else {
        @autoreleasepool {
            _tempDataSource = [_tempDataSource arrayByAddingObject:info];
        }
    }
    
    [self setupTimeStr];
}

- (void)sendFeedback:(NSString *)feedback email:(NSString *)email {
    STFeedbackInfo *entity = [[STFeedbackInfo alloc] init];
    entity.messageID = [NSString uniqueID];
    entity.messageType = STFeedbackMessageTypeText;
    entity.transferStatus = STFeedbackTransferStatusSending;
    entity.content = feedback;
    entity.time = [[NSDate date] dateString];
    [entity setup];
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.INSERT(DBFeedbackMessages._tableName)
    .SET(DBFeedbackMessages._messageID, entity.messageID)
    .SET(DBFeedbackMessages._messageType, @(entity.messageType))
    .SET(DBFeedbackMessages._transferStatus , @(entity.transferStatus))
    .SET(DBFeedbackMessages._content, entity.content)
    .SET(DBFeedbackMessages._time, entity.time);
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
    
    [self addTransferFile:entity];
    
    // post
    NSMutableDictionary *itemsDic = [NSMutableDictionary dictionary];
    [itemsDic setObject:feedback forKey:@"content"];
    if (email.length > 0) {
        [itemsDic setObject:email forKey:@"email"];
    }
    NSString *itemsString = [itemsDic jsonString];
    NSData *postData = [itemsString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = @(postData.length).stringValue;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dianchuan.3tkj.cn:8087/dcshare/api/feedback.php?hl=zh&cp=IS001"]];
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error = nil;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            NSLog(@"post feedback error: %@", error);
        }
    }];
}

@end
