//
//  STFileTransferBaseModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/3/5.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STFileTransferBaseModel.h"

#define ALBUM_TITLE @"点传"

@implementation STFileTransferBaseModel

- (void)dealloc {
    [database close];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *defaultDbPath = [[ZZPath documentPath] stringByAppendingPathComponent:dbName];
        database = [[HTFMDatabase alloc] initWithPath:defaultDbPath];
        [database open];
        
        // 发送中的或者接收中的状态置为传输失败
        HTSQLBuffer *sqlBuffer = [[HTSQLBuffer alloc] init];
        sqlBuffer.UPDATE(DBFileTransfer._tableName).SET(DBFileTransfer._transferStatus, @(STFileTransferStatusSendFailed)).WHERE(SQLFieldEqual(DBFileTransfer._transferStatus, @(STFileTransferStatusSending)));
        [database executeUpdate:sqlBuffer.sql];
        
        sqlBuffer = [[HTSQLBuffer alloc] init];
        sqlBuffer.UPDATE(DBFileTransfer._tableName).SET(DBFileTransfer._transferStatus, @(STFileTransferStatusReceiveFailed)).WHERE(SQLFieldEqual(DBFileTransfer._transferStatus, @(STFileTransferStatusReceiving)));
        [database executeUpdate:sqlBuffer.sql];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ LEFT JOIN %@ ON %@.%@=%@.%@ ORDER BY %@ DESC", DBFileTransfer._tableName, DBDeviceInfo._tableName, DBFileTransfer._tableName, DBFileTransfer._deviceName, DBDeviceInfo._tableName, DBDeviceInfo._deviceName, DBFileTransfer._id];
        FMResultSet *result = [database executeQuery:sql];
        if (result) {
            NSMutableArray *tempArr = [NSMutableArray array];
            while ([result next]) {
                if (result.resultDictionary) {
                    [tempArr addObject:[[STFileTransferInfo alloc] initWithDictionary:result.resultDictionary]];
                }
            }
            
            _transferFiles = [NSArray arrayWithArray:tempArr];
            _sectionTransferFiles = [self sortTransferInfo:_transferFiles];
        }
        
    }
    
    return self;
}

- (NSArray *)sortTransferInfo:(NSArray *)infos {
    NSMutableArray *resultArr = [NSMutableArray array];
    NSMutableArray *tempArr = [NSMutableArray array];
    STFileTransferInfo *lastInfo = nil;
    for (STFileTransferInfo *info in infos) {
        if (!lastInfo || ([info.deviceName isEqualToString:lastInfo.deviceName] && info.transferType == lastInfo.transferType)) {
            [tempArr addObject:info];
        } else {
            [resultArr addObject:tempArr];
            
            tempArr = [NSMutableArray array];
            [tempArr addObject:info];
        }
        
        lastInfo = info;
    }
    
    if (tempArr.count > 0) {
        [resultArr addObject:tempArr];
    }
    
    return [NSArray arrayWithArray:resultArr];
}

- (void)addTransferFile:(STFileTransferInfo *)info {
    if (!info) {
        return;
    }
    
    if (!self.transferFiles) {
        self.transferFiles = [NSArray arrayWithObject:info];
    } else {
        @autoreleasepool {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.transferFiles];
            [arr insertObject:info atIndex:0];
            self.transferFiles = [NSArray arrayWithArray:arr];
        }
    }
}

- (void)sendItems:(NSArray *)items {
    
}

- (void)updateTransferStatus:(STFileTransferStatus)status withIdentifier:(NSString *)identifier {
    STFileTransferType transferType = STFileTransferTypeSend;
    if (status >= STFileTransferStatusReceiving) {
        transferType = STFileTransferTypeReceive;
    }
    
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.UPDATE(DBFileTransfer._tableName)
    .WHERE(SQLStringEqual(DBFileTransfer._identifier, identifier))
    .SET(DBFileTransfer._transferStatus, @(status))
    .WHERE(SQLFieldEqual(DBFileTransfer._transferType, @(transferType)));
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
}

- (void)insertTransferInfo:(STFileTransferInfo *)entity {
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.INSERT(DBFileTransfer._tableName)
    .SET(DBFileTransfer._identifier, entity.identifier)
    .SET(DBFileTransfer._deviceName, entity.deviceName)
    .SET(DBFileTransfer._fileType, @(entity.fileType))
    .SET(DBFileTransfer._transferType , @(entity.transferType))
    .SET(DBFileTransfer._transferStatus , @(entity.transferStatus))
    .SET(DBFileTransfer._fileName, entity.fileName)
    .SET(DBFileTransfer._fileSize, @(entity.fileSize))
    .SET(DBFileTransfer._date, entity.dateString)
    .SET(DBFileTransfer._url, entity.url);
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
    
    HTSQLBuffer *sql2 = [[HTSQLBuffer alloc] init];
    sql2.REPLACE(DBDeviceInfo._tableName)
    .SET(DBDeviceInfo._deviceName, entity.deviceName);
    if (![database executeUpdate:sql2.sql]) {
        NSLog(@"%@", database.lastError);
    }
}

- (void)updateAssetIdentifier:(NSString *)assetIdentifier withIdentifier:(NSString *)identifier {
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.UPDATE(DBFileTransfer._tableName)
    .WHERE(SQLStringEqual(DBFileTransfer._identifier, identifier))
    .SET(DBFileTransfer._url, assetIdentifier);
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
}

- (void)createToSaveCollectionIfNeeded:(void(^)(PHAssetCollection *assetCollection))completionHandler {
    // 创建相册
    __block PHObjectPlaceholder *placeholder;
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", ALBUM_TITLE];
    toSaveCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                subtype:PHAssetCollectionSubtypeAny
                                                                options:fetchOptions].firstObject;
    
    if (!toSaveCollection)
    {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *createAlbum = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:ALBUM_TITLE];
            placeholder = [createAlbum placeholderForCreatedAssetCollection];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success)
            {
                PHFetchResult *collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[placeholder.localIdentifier]
                                                                                                            options:nil];
                toSaveCollection = collectionFetchResult.firstObject;
                completionHandler(toSaveCollection);
            } else {
                completionHandler(nil);
                NSLog(@"create albumn failed");
            }
        }];
    } else {
        completionHandler(toSaveCollection);
    }
}

- (BOOL)shouldReceiveFile {
    long long freeDiskSpace = [UIDevice longFreeDiskSpace];
    if (freeDiskSpace > 200 * 1024 * 1024) { // 有时候读出来的会有200M的偏差
        freeDiskSpace -= 200 * 1024 * 1024;
    }
    NSLog(@"Free disk space: %@", [NSString formatSize:freeDiskSpace]);
    
#if DEBUG
    if (freeDiskSpace > 0 && freeDiskSpace < 8 * 1024 * 1024 * 1024.0) {
#else
    if (freeDiskSpace > 0 && freeDiskSpace < 300 * 1024 * 1024.0) {
#endif
        [self.delegate shouldReceiveFile:NO];
        return NO;
    }

    [self.delegate shouldReceiveFile:YES];
    return YES;
}

@end
