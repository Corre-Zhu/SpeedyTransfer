//
//  STFileTransferModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferModel.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import <Photos/Photos.h>
#import <GCDWebServerFunctions.h>
#import "STDeviceInfo.h"
#import "HTFMDatabase.h"
#import "HTSQLBuffer.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>

@interface STFileTransferModel ()<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *udpSocket;
    NSTimer *timeoutTimer;
    HTFMDatabase *database;
    NSTimeInterval lastTimestamp;
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
        
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [udpSocket setIPv4Enabled:YES];
        [udpSocket setIPv6Enabled:NO];
        
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(timeout) userInfo:nil repeats:YES];
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

- (void)startListenBroadcast {
    NSError *error = nil;
    if (![udpSocket bindToPort:KUDPPORT error:&error]) {
        NSLog(@"bind to port error: %@", error);
    };
    
    if (![udpSocket beginReceiving:&error]) {
        NSLog(@"Error starting server (recv): %@", error);
    }
}

- (void)timeout {
    [[GCDQueue backgroundPriorityGlobalQueue] queueBlock:^{
        @synchronized(self) {
            @autoreleasepool {
                NSArray *tempArr = [NSArray arrayWithArray:self.devicesArray];
                NSMutableArray *tempMutableArry = [NSMutableArray arrayWithArray:self.devicesArray];
                BOOL timeout = NO;
                for (STDeviceInfo *userInfo in tempArr) {
                    if ([[NSDate date] timeIntervalSince1970] - userInfo.lastUpdateTimestamp > 15) {
                        // 15秒之内没有收到udp广播，默认当做离线处理
                        timeout = YES;
                        [tempMutableArry removeObject:userInfo];
                        NSLog(@"timeout: %@, %@", userInfo.ip, @(userInfo.port).stringValue);
                    }
                }
                
                if (timeout) {
                    self.devicesArray = [NSArray arrayWithArray:tempMutableArry];
                }
            }
        }

    }];
    
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
    [[GCDQueue backgroundPriorityGlobalQueue] queueBlock:^{
        @synchronized(self) {
            @autoreleasepool {
                NSString *host = nil;
                NSInteger port = 0;
                NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSArray *arr = [dataString componentsSeparatedByString:@":"];
                if (arr.count == 3) {
                    port = [[arr objectAtIndex:1] integerValue];
                }
                [GCDAsyncUdpSocket getHost:&host port:NULL fromAddress:address];
                if (host.length > 0 && port > 0 && ![[UIDevice getIpAddresses] containsObject:host]) {
                    
//                    NSLog(@"%@, %@, %@", dataString, host, @(port).stringValue);
                    
                    BOOL find = NO;
                    NSArray *tempArr = [NSArray arrayWithArray:self.devicesArray];
                    for (STDeviceInfo *userInfo in tempArr) {
                        if ([userInfo.ip isEqualToString:host]) {
                            userInfo.lastUpdateTimestamp = [[NSDate date] timeIntervalSince1970];
                            find = YES;
                            break;
                        }
                    }
                    
                    if (!find) {
                        STDeviceInfo *userInfo = [[STDeviceInfo alloc] init];
                        userInfo.ip = host;
                        userInfo.port = port;
                        userInfo.lastUpdateTimestamp = [[NSDate date] timeIntervalSince1970];
                        [userInfo setup];
                        self.devicesArray = [tempArr arrayByAddingObject:userInfo];
                    }
                }
            }
        }
    }];
    
}

#pragma mark - Send file

- (PHAsset *)firstPhotoAsset {
    for (NSDictionary *dic in _selectedAssetsArr) {
        NSMutableArray *arr = [dic.allValues firstObject];
        if (arr.count > 0) {
            PHAsset *asset = arr.firstObject;
            [arr removeObject:asset];
            self.selectedFilesCount -= 1;
            self.photosCountChanged = YES;
            return asset;
        }
    }
    
    return nil;
}

- (void)addTransferFile:(STFileTransferInfo *)info {
    if (!info) {
        return;
    }
    
    if (!_transferFiles) {
        self.transferFiles = [NSArray arrayWithObject:info];
    } else {
        @autoreleasepool {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:_transferFiles];
            [arr insertObject:info atIndex:0];
            self.transferFiles = [NSArray arrayWithArray:arr];
        }
    }
}

- (STFileTransferInfo *)insertPhotoToDbWithDeviceInfo:(STDeviceInfo *)deviceInfo fileInfo:(NSDictionary *)fileInfo {
    STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
    entity.identifier = [NSString uniqueID];
    entity.fileType = STFileTypePicture;
    entity.transferType = STFileTransferTypeSend;
    entity.transferStatus = STFileTransferStatusSending;
    entity.url = [fileInfo stringForKey:ASSET_ID];
    entity.fileName = [fileInfo stringForKey:FILE_NAME];
    entity.dateString = [[NSDate date] dateString];
    entity.fileSize = [fileInfo doubleForKey:FILE_SIZE];
	
    entity.deviceName = deviceInfo.deviceName;
    entity.headImage = deviceInfo.headImage;
    
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
    
    sql = [[HTSQLBuffer alloc] init];
    sql.REPLACE(DBDeviceInfo._tableName)
    .SET(DBDeviceInfo._deviceName, deviceInfo.deviceName);
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
    
    [self addTransferFile:entity];
    
    return entity;
}

- (void)updateTransferStatus:(STFileTransferStatus)status withIdentifier:(NSString *)identifier {
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.UPDATE(DBFileTransfer._tableName)
    .WHERE(SQLStringEqual(DBFileTransfer._identifier, identifier))
    .SET(DBFileTransfer._transferStatus, @(status));
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
}

- (void)startSendFile {
    // 发送图片
    PHAsset *photoAsset = [self firstPhotoAsset];
    if (photoAsset) {
        NSString *localIdentifier = photoAsset.localIdentifier;
        [[PHImageManager defaultManager] requestImageDataForAsset:photoAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
            NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
            if (url.absoluteString.length > 0 && imageData.length > 0 && address.length > 0) {
                NSString *fileName = [url.absoluteString lastPathComponent];
                NSUInteger fileSize = imageData.length;
                NSString *fileType = [url.absoluteString pathExtension];
                NSString *fileUrl = [NSString stringWithFormat:@"http://%@:%@/image/origin/%@", address, @(KSERVERPORT), localIdentifier];
                NSString *thumbnailUrl = [NSString stringWithFormat:@"http://%@:%@/image/thumbnail/%@", address, @(KSERVERPORT), localIdentifier];
                
                NSDictionary *fileInfo = @{FILE_NAME: fileName,
                                           FILE_TYPE: fileType,
                                           FILE_SIZE: @(fileSize),
                                           FILE_URL: fileUrl,
                                           ICON_URL: thumbnailUrl,
                                           ASSET_ID: localIdentifier};
                NSString *itemsString = [@[fileInfo] jsonString];
                
                NSArray *tempDevices = [NSArray arrayWithArray:self.selectedDevicesArray];
                for (STDeviceInfo *info in tempDevices) {
                    if (info.recvUrl.length > 0) {
                        // 写数据库
                        STFileTransferInfo *transferInfo = [self insertPhotoToDbWithDeviceInfo:info fileInfo:fileInfo];
                        self.curentTransferFiles = [NSArray arrayWithObject:transferInfo];
                        
                        NSData *postData = [itemsString dataUsingEncoding:NSUTF8StringEncoding];
                        NSString *postLength = @(postData.length).stringValue;

                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:info.recvUrl]];
                        request.HTTPMethod = @"POST";
                        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                        [request setHTTPBody:postData];
                        
                        NSHTTPURLResponse *response = nil;
                        NSError *error = nil;
                        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        if (response.statusCode != 200) {
                            transferInfo.transferStatus = STFileTransferStatusSendFailed;
                            [self updateTransferStatus:STFileTransferStatusSendFailed withIdentifier:transferInfo.identifier];
                        }
                    }
                   
                }
                
                
            } else {
                [self startSendFile];
            }

            
            
            
//            NSString *path = [[ZZPath picturePath] stringByAppendingPathComponent:[url.absoluteString lastPathComponent]];
//            [imageData writeToFile:path atomically:YES];
           
            
        }];
        return;
    }
}

- (void)removeAllSelectedFiles {
    _selectedAssetsArr = nil;
//    _selectedMusicsArr = nil;
//    _selectedVideoAssetsArr = nil;
//    _selectedContactsArr = nil;
    
    self.selectedFilesCount = 0;
    self.photosCountChanged = YES;
    self.musicsCountChanged = YES;
    self.videosCountChanged = YES;
    self.contactsCountChanged = YES;
}

#pragma mark - Receive file

- (void)receiveItems:(NSArray *)items {
	if (!self.currentReceiveFiles) {
		self.currentReceiveFiles = [NSMutableArray array];
	}
	
	@synchronized(self.currentReceiveFiles) {
		[self.currentReceiveFiles addObjectsFromArray:items];
	}
	
	[self startDownload];
}

// 开始下载接收的文件
- (void)startDownload {
	if (self.currentReceivingInfo || self.currentReceiveFiles.count == 0) {
		return;
	}
	
	@synchronized(self.currentReceiveFiles) {
		self.currentReceivingInfo = [self.currentReceiveFiles firstObject];
		[self.currentReceiveFiles removeObject:self.currentReceivingInfo];
	}
	
	// 写入数据库
	HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
	sql.INSERT(DBFileTransfer._tableName)
	.SET(DBFileTransfer._identifier, _currentReceivingInfo.identifier)
	.SET(DBFileTransfer._deviceName, _currentReceivingInfo.deviceName)
	.SET(DBFileTransfer._fileType, @(_currentReceivingInfo.fileType))
	.SET(DBFileTransfer._transferType , @(_currentReceivingInfo.transferType))
	.SET(DBFileTransfer._transferStatus , @(_currentReceivingInfo.transferStatus))
	.SET(DBFileTransfer._fileName, _currentReceivingInfo.fileName)
	.SET(DBFileTransfer._fileSize, @(_currentReceivingInfo.fileSize))
	.SET(DBFileTransfer._date, _currentReceivingInfo.dateString);
	if (![database executeUpdate:sql.sql]) {
		NSLog(@"%@", database.lastError);
	}
	sql = [[HTSQLBuffer alloc] init];
	sql.REPLACE(DBDeviceInfo._tableName)
	.SET(DBDeviceInfo._deviceName, _currentReceivingInfo.deviceName);
	if (![database executeUpdate:sql.sql]) {
		NSLog(@"%@", database.lastError);
	}
	[self addTransferFile:_currentReceivingInfo];
	
    // 下载缩略图
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *thumbURL = [NSURL URLWithString:_currentReceivingInfo.thumbnailUrl];
    NSURLRequest *thumbRequest = [NSURLRequest requestWithURL:thumbURL];
    
    NSURLSessionDownloadTask *thumbDownloadTask = [manager downloadTaskWithRequest:thumbRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *path = [[ZZPath picturePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_thumb", _currentReceivingInfo.identifier]];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSHTTPURLResponse *httpURLResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpURLResponse = (NSHTTPURLResponse *)response;
        }
        if (error || httpURLResponse.statusCode != 200) {
            NSLog(@"thumbnail download failed");
        } else {
            _currentReceivingInfo.thumbnailProgress = 1.0f;
        }
    }];
    [thumbDownloadTask resume];
    
    // 下载原图
    NSURL *originURL = [NSURL URLWithString:_currentReceivingInfo.url];
    NSURLRequest *originRequest = [NSURLRequest requestWithURL:originURL];
    
    __block NSProgress *progress = nil;
    NSURLSessionDownloadTask *origindownloadTask = [manager downloadTaskWithRequest:originRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        progress = downloadProgress;
        [downloadProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *path = [[ZZPath picturePath] stringByAppendingPathComponent:_currentReceivingInfo.identifier];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [progress removeObserver:self forKeyPath:@"fractionCompleted"];
        
        NSHTTPURLResponse *httpURLResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpURLResponse = (NSHTTPURLResponse *)response;
        }
        if (error || httpURLResponse.statusCode != 200) {
            [self updateTransferStatus:STFileTransferStatusReceiveFailed withIdentifier:_currentReceivingInfo.identifier];
            _currentReceivingInfo.transferStatus = STFileTransferStatusReceiveFailed;
        } else {
            [self updateTransferStatus:STFileTransferStatusReceived withIdentifier:_currentReceivingInfo.identifier];
            _currentReceivingInfo.transferStatus = STFileTransferStatusReceived;
        }
        [self startDownload];
        _currentReceivingInfo = nil;
        NSLog(@"File downloaded to: %@", filePath);
    }];
    
    [origindownloadTask resume];
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        if (progress.fractionCompleted - _currentReceivingInfo.progress > 0.02f || progress.fractionCompleted == 1.0f) {
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval timeInterval = now - lastTimestamp;
            if (timeInterval != 0.0f) {
                _currentReceivingInfo.downloadSpeed = 1 / timeInterval * (progress.fractionCompleted - _currentReceivingInfo.progress) * _currentReceivingInfo.fileSize;
            }
            _currentReceivingInfo.progress = progress.fractionCompleted;
            lastTimestamp = now;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Picture

- (void)addAsset:(PHAsset *)asset inCollection:(NSString *)collection {
    if (!asset || !collection) {
        return;
    }
    
    if (!_selectedAssetsArr) {
        _selectedAssetsArr = [NSMutableArray array];
    }
    
    BOOL collectionExist = NO;
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            if (![arr containsObject:asset]) {
                [arr addObject:asset];
                self.selectedFilesCount += 1;
            }
            collectionExist = YES;
            break;
        }
    }
    
    if (!collectionExist) {
        [_selectedAssetsArr addObject:@{collection: [NSMutableArray arrayWithObject:asset]}];
        self.selectedFilesCount += 1;
    }
    
}

- (void)addAssets:(NSArray *)assets inCollection:(NSString *)collection {
    if (!assets || !collection) {
        return;
    }
    
    if (!_selectedAssetsArr) {
        _selectedAssetsArr = [NSMutableArray array];
    }
    
    BOOL collectionExist = NO;
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            [arr addObjectsFromArray:assets];
            collectionExist = YES;
            break;
        }
    }
    
    if (!collectionExist) {
        [_selectedAssetsArr addObject:@{collection: [NSMutableArray arrayWithArray:assets]}];
    }
    
    self.selectedFilesCount += assets.count;
    
}

- (void)removeAsset:(PHAsset *)asset inCollection:(NSString *)collection {
    if (!asset || !collection) {
        return;
    }
    
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            [arr removeObject:asset];
            self.selectedFilesCount -= 1;
            return;
        }
    }
    
}

- (void)removeAssets:(NSArray *)assets inCollection:(NSString *)collection {
    if (!assets || !collection) {
        return;
    }
    
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            [arr removeObjectsInArray:assets];
            self.selectedFilesCount -= assets.count;
            return;
        }
    }
}

- (void)removeAllAssetsInCollection:(NSString *)collection {
    if (!collection) {
        return;
    }
    
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            self.selectedFilesCount -= arr.count;
            [arr removeAllObjects];
            return;
        }
    }
}

- (BOOL)isSelectedWithAsset:(PHAsset *)asset inCollection:(NSString *)collection{
    if (!asset || !collection) {
        return NO;
    }
    
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            NSMutableArray *arr = dic.allValues.firstObject;
            return [arr containsObject:asset];
        }
    }
    
    return NO;
}

- (NSInteger)selectedPhotosCountInCollection:(NSString *)collection {
    NSInteger count = 0;
    for (NSDictionary *dic in _selectedAssetsArr) {
        if ([dic.allKeys.firstObject isEqualToString:collection]) {
            count += [dic.allValues.firstObject count];
            break;
        }
    }
    
    return count;
}

@end
