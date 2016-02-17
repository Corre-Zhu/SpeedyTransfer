//
//  STFileTransferModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferModel.h"
#import "STContactInfo.h"
#import "HTSQLBuffer.h"
#import "HTFMDatabase.h"
#import "AppDelegate.h"

@interface STFileTransferModel ()
{
    HTFMDatabase *database;
}

@end

@implementation STFileTransferModel

HT_DEF_SINGLETON(STFileTransferModel, shareInstant);

- (void)dealloc {
    [database close];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *defaultDbPath = [[ZZPath documentPath] stringByAppendingPathComponent:dbName];
        database = [[HTFMDatabase alloc] initWithPath:defaultDbPath];
        [database open];
        
        HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
        sql.SELECT(@"*").FROM(DBFileTransfer._tableName).ORDERBY(DBFileTransfer._id, @"DESC");
        FMResultSet *result = [database executeQuery:sql.sql];
        if (result) {
            NSMutableArray *tempArr = [NSMutableArray array];
            while ([result next]) {
                if (result.resultDictionary) {
                    [tempArr addObject:[[STFileTransferInfo alloc] initWithDictionary:result.resultDictionary]];
                }
            }
            _transferFiles = [NSArray arrayWithArray:tempArr];
        }
		
    }
	
    return self;
}

- (void)addTransferFile:(STFileTransferInfo *)info {
    if (!info) {
        return;
    }
    
    if (!_transferFiles) {
        _transferFiles = [NSArray arrayWithObject:info];
    } else {
        @autoreleasepool {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:_transferFiles];
            [arr insertObject:info atIndex:0];
            _transferFiles = [NSArray arrayWithArray:arr];
        }
    }
}

- (STFileTransferInfo *)setContactInfo:(STContactInfo *)object forKey:(NSString *)key {
    STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
    if (key.length > 0) {
        entity.identifier = [key copy];
    } else {
        entity.identifier = [NSString uniqueID];
    }
    entity.fileType = STFileTypeContact;
    entity.transferStatus = STFileTransferStatusSending;
    entity.url = @"";
    entity.fileName = object.name;
    entity.dateString = [[NSDate date] dateString];
    entity.fileSize = object.size;
    entity.vcardString = object.vcardString;
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.INSERT(DBFileTransfer._tableName)
    .SET(DBFileTransfer._identifier, entity.identifier)
    .SET(DBFileTransfer._fileType, @(entity.fileType))
    .SET(DBFileTransfer._transferStatus , @(entity.transferStatus))
    .SET(DBFileTransfer._fileName, entity.fileName)
    .SET(DBFileTransfer._fileSize, @(entity.fileSize))
    .SET(DBFileTransfer._date, entity.dateString)
    .SET(DBFileTransfer._vcard, entity.vcardString);
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
    
    [self addTransferFile:entity];
    
    return entity;
}

- (STFileTransferInfo *)saveAssetWithIdentifier:(NSString *)identifier fileName:(NSString *)fileName length:(double)length forKey:(NSString *)key {
    STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
    if (key.length > 0) {
        entity.identifier = [key copy];
    } else {
        entity.identifier = [NSString uniqueID];
    }
    entity.fileType = STFileTypePicture;
    entity.transferStatus = STFileTransferStatusSending;
    entity.url = identifier;
    entity.fileName = fileName;
    entity.dateString = [[NSDate date] dateString];
    entity.fileSize = length;
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.INSERT(DBFileTransfer._tableName)
    .SET(DBFileTransfer._identifier, entity.identifier)
    .SET(DBFileTransfer._fileType, @(entity.fileType))
    .SET(DBFileTransfer._transferStatus , @(entity.transferStatus))
    .SET(DBFileTransfer._fileName, entity.fileName)
    .SET(DBFileTransfer._fileSize, @(entity.fileSize))
    .SET(DBFileTransfer._date, entity.dateString)
    .SET(DBFileTransfer._url, entity.url);
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
    
    [self addTransferFile:entity];
    
    return entity;
}

- (void)updateStatus:(STFileTransferStatus)status rate:(double)rate withIdentifier:(NSString *)identifier {
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.UPDATE(DBFileTransfer._tableName)
    .SET(DBFileTransfer._transferStatus , @(status))
    .SET(DBFileTransfer._downloadSpeed, @(rate))
    .WHERE(SQLStringEqual(DBFileTransfer._identifier, identifier));
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
}

@end
