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
            _dataSource = [NSArray arrayWithArray:tempArr];
        }
    }
    
    return self;
}

- (void)addTransferFile:(STFeedbackInfo *)info {
    if (!info) {
        return;
    }
    
    if (!_dataSource) {
        _dataSource = [NSArray arrayWithObject:info];
    } else {
        @autoreleasepool {
            _dataSource = [_dataSource arrayByAddingObject:info];
        }
    }
}

- (void)sendFeedback:(NSString *)feedback {
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
}

@end
