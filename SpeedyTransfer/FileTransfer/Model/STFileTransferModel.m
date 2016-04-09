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
#import "STWebServerModel.h"
#import <AddressBook/AddressBook.h>

#define ALBUM_TITLE @"点传"

NSString *const KDeviceNotConnectedNotification = @"DeviceNotConnectedNotification"; // 设备退出共享网络通知

@interface STFileTransferModel ()<GCDAsyncUdpSocketDelegate>
{
    NSTimer *timeoutTimer;
    HTFMDatabase *database;
    NSTimeInterval downloadStartTimestamp;
    NSTimeInterval lastTimestamp;
    float lastProgress;
    
    __block PHAssetCollection *toSaveCollection;
    NSURLSessionDownloadTask *thumbDownloadTask; // 当前缩略图下载任务
    NSURLSessionDownloadTask *origindownloadTask; // 当前大图下载任务
}

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

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
        
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(timeout) userInfo:nil repeats:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
	
    return self;
}

- (GCDAsyncUdpSocket *)udpSocket {
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_udpSocket setIPv4Enabled:YES];
        [_udpSocket setIPv6Enabled:NO];
    }
    
    return _udpSocket;
}

- (void)didEnterBackgroundNotification {
    [self.udpSocket close];
    _udpSocket = nil;
}

- (void)willEnterForegroundNotification {
    [self startListenBroadcast];
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

- (void)removeAllSelectedDevices {
    self.selectedDevicesArray = nil;
}

#pragma mark - Broadcast

- (void)startListenBroadcast {
    NSError *error = nil;
    if (![self.udpSocket bindToPort:KUDPPORT error:&error]) {
        NSLog(@"bind to port error: %@", error);
    };
    
    if (![self.udpSocket beginReceiving:&error]) {
        NSLog(@"Error starting server (recv): %@", error);
    }
}

- (void)timeout {
    [[GCDQueue backgroundPriorityGlobalQueue] queueBlock:^{
        @synchronized(self) {
            @autoreleasepool {
                NSArray *tempArr = [NSArray arrayWithArray:self.devicesArray];
                NSMutableArray *tempDevicesArry = [NSMutableArray arrayWithArray:self.devicesArray];
                NSMutableArray *tempSelectedDevicesArray = [NSMutableArray arrayWithArray:self.selectedDevicesArray];
                BOOL timeout = NO;
                BOOL deviceNotConnected = NO;
                for (STDeviceInfo *deviceInfo in tempArr) {
                    if (!deviceInfo.isBrowser && [[NSDate date] timeIntervalSince1970] - deviceInfo.lastUpdateTimestamp > 15) {
                        // 15秒之内没有收到udp广播，默认当做离线处理
                        timeout = YES;
                        [tempDevicesArry removeObject:deviceInfo];
                        
                        if ([tempSelectedDevicesArray containsObject:deviceInfo]) {
                            deviceNotConnected = YES;
                            [tempSelectedDevicesArray removeObject:deviceInfo];
                            NSString *deviceName = deviceInfo.deviceName;
                            if (deviceName.length == 0) {
                                deviceName = NSLocalizedString(@"对方", nil);
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:KDeviceNotConnectedNotification object:nil userInfo:@{DEVICE_NAME: deviceName}];
                        }
                        NSLog(@"timeout: %@, %@", deviceInfo.ip, @(deviceInfo.port).stringValue);
                    }
                }
                
                if (timeout) {
                    self.devicesArray = [NSArray arrayWithArray:tempDevicesArry];
                }
                
                if (deviceNotConnected) {
                    self.selectedDevicesArray = [NSArray arrayWithArray:tempSelectedDevicesArray];
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
                if (host.length > 0 && port > 0 && ![[UIDevice getAllIpAddresses].allValues containsObject:host]) {
                    BOOL find = NO;
                    NSArray *tempArr = [NSArray arrayWithArray:self.devicesArray];
                    for (STDeviceInfo *deviceInfo in tempArr) {
                        if ([deviceInfo.ip isEqualToString:host]) {
                            if (deviceInfo.deviceName.length == 0) {
                                [deviceInfo setup];
                            }
                            deviceInfo.lastUpdateTimestamp = [[NSDate date] timeIntervalSince1970];
                            find = YES;
                            break;
                        }
                    }
                    
                    if (!find) {
                        STDeviceInfo *userInfo = [[STDeviceInfo alloc] init];
                        userInfo.ip = host;
                        userInfo.port = port;
                        userInfo.lastUpdateTimestamp = [[NSDate date] timeIntervalSince1970];
                        if ([userInfo setup]) {
                            self.devicesArray = [tempArr arrayByAddingObject:userInfo];
                        }
                        
                    }
                }
            }
        }
    }];
    
}

#pragma mark - Find new device

- (void)addNewBrowser:(NSString *)host {
		@synchronized(self) {
			@autoreleasepool {
				if (host.length > 0 && ![[UIDevice getAllIpAddresses].allValues containsObject:host]) {
					BOOL find = NO;
					NSArray *tempArr = [NSArray arrayWithArray:self.devicesArray];
					for (STDeviceInfo *deviceInfo in tempArr) {
						if (deviceInfo.isBrowser && [deviceInfo.ip isEqualToString:host]) {
							find = YES;
							break;
						}
					}
					
					if (!find) {
						STDeviceInfo *deviceInfo = [[STDeviceInfo alloc] init];
						deviceInfo.ip = host;
						deviceInfo.isBrowser = YES;
						deviceInfo.deviceName = host;
						deviceInfo.headImage = [UIImage imageNamed:@"head9"];
						self.devicesArray = [tempArr arrayByAddingObject:deviceInfo];
					}
				}
			}
		}
}

- (void)removeAllBrowser {
	@synchronized(self) {
		@autoreleasepool {
			NSArray *tempArr = [NSArray arrayWithArray:self.devicesArray];
			NSMutableArray *tempDevicesArry = [NSMutableArray arrayWithArray:self.devicesArray];
			NSMutableArray *tempSelectedDevicesArray = [NSMutableArray arrayWithArray:self.selectedDevicesArray];
			BOOL findBrowser = NO;
			BOOL deviceNotConnected = NO;
			for (STDeviceInfo *deviceInfo in tempArr) {
				if (deviceInfo.isBrowser) {
					findBrowser = YES;
					[tempDevicesArry removeObject:deviceInfo];
					
					if ([tempSelectedDevicesArray containsObject:deviceInfo]) {
						deviceNotConnected = YES;
						[tempSelectedDevicesArray removeObject:deviceInfo];
					}
				}
			}
			
			if (findBrowser) {
				self.devicesArray = [NSArray arrayWithArray:tempDevicesArry];
			}
			
			if (deviceNotConnected) {
				self.selectedDevicesArray = [NSArray arrayWithArray:tempSelectedDevicesArray];
			}
		}
	}
}

#pragma mark - Send file

- (void)sendItems:(NSArray *)items {
    @synchronized(self) {
        NSArray *selectedDevices = [NSArray arrayWithArray:self.selectedDevicesArray];
        for (STDeviceInfo *info in selectedDevices) {
            [info addSendItems:items];
            [info startSend];
        }
    }
}

- (NSArray *)insertItemsToDbWithDeviceInfo:(STDeviceInfo *)deviceInfo fileInfos:(NSArray *)fileInfos {
	
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:fileInfos.count];
    for (NSDictionary *fileInfo in fileInfos) {
        STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
        entity.identifier = [NSString uniqueID];
        entity.transferType = STFileTransferTypeSend;
        entity.transferStatus = STFileTransferStatusSending;
        entity.fileName = [fileInfo stringForKey:FILE_NAME];
        entity.dateString = [[NSDate date] dateString];
        entity.fileSize = [fileInfo doubleForKey:FILE_SIZE];
        
        NSString *fileUrl = [fileInfo stringForKey:FILE_URL];
        if ([fileUrl containsString:@"/image"]) {
            entity.fileType = STFileTypePicture;
            entity.url = [fileInfo stringForKey:ASSET_ID];
        } else if ([fileUrl containsString:@"/contact"]) {
            entity.fileType = STFileTypeContact;
            entity.url = [fileInfo stringForKey:RECORD_ID];
        } else if ([fileUrl containsString:@"/music"]) {
            entity.fileType = STFileTypeMusic;
            entity.url = [fileInfo stringForKey:RECORD_ID];
        }
         
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
        
        [self addTransferFile:entity];
        [resultArray addObject:entity];
    }
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.REPLACE(DBDeviceInfo._tableName)
    .SET(DBDeviceInfo._deviceName, deviceInfo.deviceName);
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
    
    return resultArray;
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

- (void)updateDownloadSpeed:(float)downloadSpeed withIdentifier:(NSString *)identifier {
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.UPDATE(DBFileTransfer._tableName)
    .WHERE(SQLStringEqual(DBFileTransfer._identifier, identifier))
    .SET(DBFileTransfer._downloadSpeed, @(downloadSpeed));
    
    if (![database executeUpdate:sql.sql]) {
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

#pragma mark - Receive file

- (void)receiveItems:(NSArray *)items {
	if (!self.prepareToReceiveFiles) {
		self.prepareToReceiveFiles = [NSMutableArray array];
	}
	
	@synchronized(self.prepareToReceiveFiles) {
		[self.prepareToReceiveFiles addObjectsFromArray:items];
	}
	
	[self startDownload];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveFileNotification object:nil];
    
}

// 开始下载接收的文件
- (void)startDownload {
	if (self.currentReceivingInfo || self.prepareToReceiveFiles.count == 0) {
		return;
	}
	
	@synchronized(self.prepareToReceiveFiles) {
		self.currentReceivingInfo = [self.prepareToReceiveFiles firstObject];
		[self.prepareToReceiveFiles removeObject:self.currentReceivingInfo];
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
    
    if (_currentReceivingInfo.transferStatus == STFileTransferStatusReceived) {
        // 从无界接收的时候
        [self downloadSucceedWithPath:_currentReceivingInfo.url];
        return;
    }
	
    // 下载缩略图
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    if (_currentReceivingInfo.thumbnailUrl.length > 0) {
        NSURL *thumbURL = [NSURL URLWithString:_currentReceivingInfo.thumbnailUrl];
        NSURLRequest *thumbRequest = [NSURLRequest requestWithURL:thumbURL];
        
        thumbDownloadTask = [manager downloadTaskWithRequest:thumbRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSString *path = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_thumb", _currentReceivingInfo.identifier]];
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
    }
    
    // 下载原图
    NSURL *originURL = [NSURL URLWithString:_currentReceivingInfo.url];
    NSURLRequest *originRequest = [NSURLRequest requestWithURL:originURL];
    
    NSString *pathExtension = _currentReceivingInfo.pathExtension;
    if (pathExtension.length == 0) {
        pathExtension = _currentReceivingInfo.fileName.pathExtension;
    }
    
    if (pathExtension.length == 0) {
        pathExtension = @"unknow";
    }
    
    NSString *downloadPath = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", _currentReceivingInfo.identifier, pathExtension]];
    
    __block NSProgress *progress = nil;
    origindownloadTask = [manager downloadTaskWithRequest:originRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        progress = downloadProgress;
        [downloadProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:downloadPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [progress removeObserver:self forKeyPath:@"fractionCompleted"];
        
        NSHTTPURLResponse *httpURLResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpURLResponse = (NSHTTPURLResponse *)response;
        }
        if (error || httpURLResponse.statusCode != 200) {
            [self updateTransferStatus:STFileTransferStatusReceiveFailed withIdentifier:_currentReceivingInfo.identifier];
            _currentReceivingInfo.transferStatus = STFileTransferStatusReceiveFailed;
            _currentReceivingInfo = nil;
            [self startDownload];
        } else {
            [self downloadSucceedWithPath:downloadPath];
        }
    }];
    
    [origindownloadTask resume];
    
    downloadStartTimestamp = [[NSDate date] timeIntervalSince1970];
    lastTimestamp = downloadStartTimestamp;
    lastProgress = 0.0f;
}

- (void)downloadSucceedWithPath:(NSString *)downloadPath {
    [self updateTransferStatus:STFileTransferStatusReceived withIdentifier:_currentReceivingInfo.identifier];
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    float downloadSpeed = 1 / (now - downloadStartTimestamp) * _currentReceivingInfo.fileSize;
    [self updateDownloadSpeed:downloadSpeed withIdentifier:_currentReceivingInfo.identifier];
    _currentReceivingInfo.downloadSpeed = downloadSpeed;
    _currentReceivingInfo.progress = 1.0f;
    _currentReceivingInfo.transferStatus = STFileTransferStatusReceived;
    
    if (_currentReceivingInfo.fileType == STFileTypePicture && [[NSUserDefaults standardUserDefaults] boolForKey:AutoImportPhoto]) {
        // 导入图片到系统相册
        [self writeToSavedPhotosAlbum:downloadPath isImage:YES];
    } else if (_currentReceivingInfo.fileType == STFileTypeVideo && [[NSUserDefaults standardUserDefaults] boolForKey:AutoImportVideo]) {
        // 导入视频到系统相册
        [self writeToSavedPhotosAlbum:downloadPath isImage:NO];
    } else if (_currentReceivingInfo.fileType == STFileTypeContact) {
        // 导入联系人到通讯录
        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
            NSData *vcard = [[NSData alloc] initWithContentsOfFile:downloadPath];
            if (vcard.length > 0) {
                CFDataRef vCardData = CFDataCreate(NULL, [vcard bytes], [vcard length]);
                if (vCardData) {
                    ABAddressBookRef book = ABAddressBookCreate();
                    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
                    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
                    if (CFArrayGetCount(vCardPeople) > 0) {
                        ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, 0);
                        ABAddressBookAddRecord(book, person, NULL);
                        ABAddressBookSave(book, NULL);
                    }
                }
                
                
            }
        }
        
        _currentReceivingInfo = nil;
        [self startDownload];
    } else {
        _currentReceivingInfo = nil;
        [self startDownload];
    }
}

- (void)writeToSavedPhotosAlbum:(NSString *)path isImage:(BOOL)isImage {
    __block PHFetchResult *photosAsset;
    __block PHObjectPlaceholder *placeholder;
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    
    dispatch_block_t block = ^ {
        // Save to the album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *assetRequest = nil;
            if (isImage) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileUrl];
            } else {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
            }
            
            placeholder = [assetRequest placeholderForCreatedAsset];
            photosAsset = [PHAsset fetchAssetsInAssetCollection:toSaveCollection options:nil];
            PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:toSaveCollection
                                                                                                                          assets:photosAsset];
            [albumChangeRequest addAssets:@[placeholder]];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                _currentReceivingInfo.url = placeholder.localIdentifier;
                [self updateAssetIdentifier:placeholder.localIdentifier withIdentifier:_currentReceivingInfo.identifier];
                _currentReceivingInfo.transferStatus = STFileTransferStatusReceived; // 触发刷新列表
                // 保存相册成功，删除本地缓存
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                }
            } else {
                NSLog(@"%@", error);
            }
            _currentReceivingInfo = nil;
            [self startDownload];
        }];
    };
    
    [self createToSaveCollectionIfNeeded:^(PHAssetCollection *assetCollection) {
        if (!assetCollection) {
            _currentReceivingInfo = nil;
            [self startDownload];
        } else {
            block();
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        if (progress.fractionCompleted - _currentReceivingInfo.progress > 0.02f || progress.fractionCompleted == 1.0f) {
            
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval timeInterval = now - lastTimestamp;
            if (timeInterval > 0.3f) { // 每隔0.3秒更新一次速度
                _currentReceivingInfo.downloadSpeed = 1 / timeInterval * (progress.fractionCompleted - lastProgress) * _currentReceivingInfo.fileSize;
                lastTimestamp = now;
                lastProgress = progress.fractionCompleted;
            }
            _currentReceivingInfo.progress = progress.fractionCompleted;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Cancel transfer

- (void)cancelAllTransferFile {
    [self cancelAllSendItems];
    [self cancelAllReceiveItems];
	[self removeAllBrowser];
	[[STWebServerModel shareInstant] stopWebServer2];
}

- (void)cancelSendItemsTo:(NSString *)ip {
    @synchronized(self) {
        NSArray *selectedDevices = [NSArray arrayWithArray:self.selectedDevicesArray];
        for (STDeviceInfo *info in selectedDevices) {
            if ([info.ip isEqualToString:ip]) {
                [info cancelSendItemsAndPostCancel:NO];
                return;
            }
        }
    }
}

- (void)cancelReceiveItemsFrom:(NSString *)ip {
    @synchronized(self.prepareToReceiveFiles) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.prepareToReceiveFiles];
        for (STFileTransferInfo *info in self.prepareToReceiveFiles) {
            if ([info.url containsString:ip]) {
                [tempArray removeObject:info];
            }
        }
        self.prepareToReceiveFiles = [NSMutableArray arrayWithArray:tempArray];
        
        if ([self.currentReceivingInfo.url containsString:ip]) {
            [thumbDownloadTask cancel];
            [origindownloadTask cancel];
        }
    }

}

// 取消所有发送
- (void)cancelAllSendItems {
    @synchronized(self) {
        NSArray *selectedDevices = [NSArray arrayWithArray:self.selectedDevicesArray];
        for (STDeviceInfo *info in selectedDevices) {
            [info cancelSendItemsAndPostCancel:YES];
        }
    }
}

// 取消所有接收
- (void)cancelAllReceiveItems {
    @synchronized(self.prepareToReceiveFiles) {
        // 找出所有设备来post cancel
        NSMutableArray *tempCancelUrls = [NSMutableArray array];
        for (STFileTransferInfo *info in self.prepareToReceiveFiles) {
            NSString *cancelUrl = info.cancelUrl;
            if (![tempCancelUrls containsObject:cancelUrl] && cancelUrl.length > 0) {
                [tempCancelUrls addObject:cancelUrl];
            }
        }
        
        [self.prepareToReceiveFiles removeAllObjects];
        
        if (self.currentReceivingInfo) {
            NSString *cancelUrl = self.currentReceivingInfo.cancelUrl;
            if (![tempCancelUrls containsObject:cancelUrl] && cancelUrl.length > 0) {
                [tempCancelUrls addObject:cancelUrl];
            }
            
            [thumbDownloadTask cancel];
            [origindownloadTask cancel];
        }
        
        for (NSString *cancelUrl in tempCancelUrls) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:cancelUrl]];
            request.HTTPMethod = @"POST";
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                if (connectionError) {
                    NSLog(@"cancel error: %@", connectionError);
                }
            }];
        }
    }
}

@end
