//
//  STFilesModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/4/4.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STFilesModel.h"
#import "STFileInfo.h"

@interface STFilesModel () {
    HTFMDatabase *database;
}

@end

@implementation STFilesModel

- (void)dealloc {
    [database close];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *defaultDbPath = [[ZZPath documentPath] stringByAppendingPathComponent:dbName];
        database = [[HTFMDatabase alloc] initWithPath:defaultDbPath];
        [database open];
        
        [self initData];
    }
    
    return self;
}

- (void)initData {
    NSArray *fileType = @[@(STFileTypeOther), @(STFileTypeMusic)];
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.SELECT(@"*").FROM(DBFileTransfer._tableName).ORDERBY(DBFileTransfer._id, @"DESC").WHERE(SQLFieldEqual(DBFileTransfer._transferStatus, @(STFileTransferStatusReceived))).AND(SQLFieldEqual(DBFileTransfer._transferType, @(STFileTransferTypeReceive))).AND(SQLNumberIn(DBFileTransfer._fileType, fileType));
    FMResultSet *result = [database executeQuery:sql.sql];
    if (result) {
        NSMutableArray *tempArr = [NSMutableArray array];
        while ([result next]) {
            if (result.resultDictionary) {
                STFileInfo *info = [[STFileInfo alloc] initWithDictionary:result.resultDictionary];
                if (info.fileExist) {
                    [tempArr addObject:info];
                }
            }
        }
        
        _dataSource = [NSArray arrayWithArray:tempArr];
    }
}

@end
