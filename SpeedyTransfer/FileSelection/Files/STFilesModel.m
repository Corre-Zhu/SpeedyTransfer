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
    sql.SELECT(@"*").FROM(DBFileTransfer._tableName).ORDERBY(DBFileTransfer._id, @"DESC").WHERE(SQLFieldEqual(DBFileTransfer._transferStatus, @(STFileTransferStatusReceived))).AND(SQLFieldEqual(DBFileTransfer._transferType, @(STFileTransferTypeReceive))).AND(SQLNumberIn(DBFileTransfer._fileType, fileType)).GROUPBY(DBFileTransfer._identifier);
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

- (void)deleteFiles:(NSArray *)files {
    NSMutableArray *fileIdArr = [NSMutableArray arrayWithCapacity:files.count];
    for (STFileInfo *info in files) {
        [fileIdArr addObject:@(info.fileId)];
    }
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.DELELTE(DBFileTransfer._tableName).WHERE(SQLNumberIn(DBFileTransfer._id, fileIdArr));
    BOOL result = [database executeUpdate:sql.sql];
    if (!result) {
        
    }

}

@end
