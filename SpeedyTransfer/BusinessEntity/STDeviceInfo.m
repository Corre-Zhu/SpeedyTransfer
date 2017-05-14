//
//  STDeviceInfo.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STDeviceInfo.h"
#import "ZZFileUtility.h"

#define KConcurrentSendFilesCount 2 // 同时最多post两个文件

@implementation STDeviceInfo

HT_DEF_SINGLETON(STDeviceInfo, shareInstant);

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileWrittenProgressNotification:) name:KFileWrittenProgressNotification object:nil];
    }
    
    return self;
}

- (BOOL)setup {
    if (self.ip.length > 0 && self.port > 0) {
        // 访问api总接口
        NSString *apiUrl = [NSString stringWithFormat:@"http://%@:%@/api", self.ip, @(self.port)];
        NSLog(@"apiUrl: %@", apiUrl);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiUrl]];
        request.timeoutInterval = 3.0f;
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (error || dataString.length == 0) {
            NSLog(@"apiUrl: %@, error: %@", apiUrl, error);
            return NO;
        }
        
        NSDictionary *apiInfo = [dataString jsonDictionary];
        
        // 访问dev_info接口
        NSDictionary *devInfo = [apiInfo dictionaryForKey:@"dev_info"];
        NSString *devInfoUrl = [devInfo stringForKey:@"href"];
        if (devInfoUrl.length > 0) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:devInfoUrl]];
            request.timeoutInterval = 3.0f;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (error || dataString.length == 0) {
                NSLog(@"devInfoUrl: %@, error: %@", devInfoUrl, error);
                return NO;
            } else {
                NSDictionary *devInfo = [dataString jsonDictionary];
                NSString *deviceName = [devInfo stringForKey:@"device_name"];
                if (deviceName.length == 0) {
                    deviceName = @"未知设备";
                }
                self.deviceName = deviceName;
            }
            
        } else {
            return NO;
        }
        
        // 访问设备头像
        NSDictionary *portraitInfo = [apiInfo dictionaryForKey:@"portrait"];
        NSString *portraitUrl = [portraitInfo stringForKey:@"href"];
        if (portraitUrl.length > 0) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:portraitUrl]];
            request.timeoutInterval = 3.0f;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (error || !image) {
                NSLog(@"devInfoUrl: %@, error: %@", devInfoUrl, error);
                self.headImage = nil;
//                return NO;
            } else {
                NSString *headPath = [[ZZPath headImagePath] stringByAppendingFormat:@"/%@", self.deviceName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:headPath isDirectory:NULL]) {
                    [[NSFileManager defaultManager] removeItemAtPath:headPath error:NULL];
                }
                [data writeToFile:headPath atomically:YES];
                self.headImage = image;
            }
        } else {
            return NO;
        }
        
        //
        NSDictionary *recvInfo = [apiInfo dictionaryForKey:@"recv"];
        NSString *recvUrl = [recvInfo stringForKey:@"href"];
        if (recvUrl.length == 0) {
            NSLog(@"recvUrl is nil");
            return NO;
        }
        self.recvUrl = recvUrl;
        self.cancelUrl = [recvUrl stringByReplacingOccurrencesOfString:@"recv" withString:@"cancel"];

        return YES;
    }
    
    return NO;
}

- (void)setDeviceName:(NSString *)deviceName {
    _deviceName = deviceName;
    
    if (deviceName.length == 0) {
        return;
    }
}

- (NSString *)_tableName {
	return @"STDeviceInfo";
}

- (NSString *)_deviceName {
	return @"DeviceName";
}

#pragma mark - Send file

- (NSArray *)popSendingItems {
    if (self.sendingTransferInfos.count >= KConcurrentSendFilesCount) {
        return nil;
    }
    
    @synchronized(_prepareToSendFiles) {
        if (_prepareToSendFiles.count == 0) {
            return nil;
        }
        
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:KConcurrentSendFilesCount];
        
        do {
            id object = _prepareToSendFiles.firstObject;
            [resultArray addObject:object];
            [_prepareToSendFiles removeObject:object];
        } while ((self.sendingTransferInfos.count + resultArray.count) < KConcurrentSendFilesCount && _prepareToSendFiles.count > 0);
        
        return resultArray;
    }
}

- (void)addSendItems:(NSArray *)files {
    if (!_prepareToSendFiles) {
        _prepareToSendFiles = [NSMutableArray array];
        _sendingTransferInfos = [NSMutableArray array];
    }
    
    @synchronized(_prepareToSendFiles) {
        [_prepareToSendFiles addObjectsFromArray:files];
    }
}

- (void)startSend {
    if (self.sendingTransferInfos.count >= KConcurrentSendFilesCount) {
        return;
    }
    
    NSArray *items = [self popSendingItems];
    if (items.count == 0) {
        return;
    }
    
    ZZFileUtility *fileUtility = [[ZZFileUtility alloc] init];
    [fileUtility fileInfoWithItems:items completionBlock:^(NSArray *fileInfos) {
        // 写数据库
        NSArray *fileTransferInfos = [[STFileTransferModel shareInstant] insertItemsToDbWithDeviceInfo:self fileInfos:fileInfos];
        @synchronized(_prepareToSendFiles) {
            [self.sendingTransferInfos addObjectsFromArray:fileTransferInfos];
        }
        
        // 兼容安卓处理：联系人文件名固定 contacts.json
        
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSDictionary *dic in fileInfos) {
            if ([[dic stringForKey:FILE_URL] containsString:@"/contact/"]) {
                NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [tempDic setObject:@"contacts.json" forKey:FILE_NAME];
                
                [tempArr addObject:tempDic];
            } else {
                [tempArr addObject:dic];
            }
        }
		
		if (!self.isBrowser) {
			NSDictionary *itemsDic = @{@"items": tempArr};
			NSString *itemsString = [itemsDic jsonString];
			NSData *postData = [itemsString dataUsingEncoding:NSUTF8StringEncoding];
			NSString *postLength = @(postData.length).stringValue;
			
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.recvUrl]];
			request.HTTPMethod = @"POST";
			[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
			[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
			[request setHTTPBody:postData];
			
			NSHTTPURLResponse *response = nil;
			NSError *error = nil;
			NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"post files: %@", responseStr);
			if (response.statusCode != 200) {
				for (STFileTransferInfo *transferInfo in fileTransferInfos) {
					transferInfo.transferStatus = STFileTransferStatusSendFailed;
					[[STFileTransferModel shareInstant] updateTransferStatus:STFileTransferStatusSendFailed withIdentifier:transferInfo.identifier];
					
					@synchronized(_prepareToSendFiles) {
						[self.sendingTransferInfos removeObject:transferInfo];
					}
				}
				
				if (self.sendingTransferInfos.count == 0) {
					[self startSend];
				}
				
			}
		}
		
    }];
	
}

- (void)fileWrittenProgressNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    @synchronized(_prepareToSendFiles) {
        BOOL succeed = NO;
        STFileTransferInfo *tempInfo = nil;
        for (STFileTransferInfo *info in self.sendingTransferInfos) {
            if (info.isCanceled) {
                continue;
            }
            
            double fileSize = info.fileSize;
            if (info.contactSizeAndroid > 0) {
                fileSize = info.contactSizeAndroid;
            }
            
            NSString *requestPath = [userInfo stringForKey:REQUEST_PATH];
            if (info.url.length > 0 && [requestPath containsString:info.url]) {
                NSUInteger totalBytesWritten = [userInfo integerForKey:TOTAL_BYTES_WRITTEN];
                float progress = MIN(1.0f, (totalBytesWritten + 248) / fileSize);
                
                double startTimestamp = [userInfo doubleForKey:START_TIMESTAMP];
                if (info.lastProgressTimeStamp == 0.0f) {
                    info.lastProgressTimeStamp = startTimestamp;
                }
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval timeInterval = now - info.lastProgressTimeStamp;
                if (timeInterval > 0.3f) { // 每隔0.3秒更新一次速度
                    info.downloadSpeed = 1 / timeInterval * (progress - info.lastProgress) * fileSize;
                    info.lastProgressTimeStamp = now;
                    info.lastProgress = progress;
                }
                info.progress = progress;
                
                // 文件发送成功
                if (info.progress == 1.0f) {
                    [[STFileTransferModel shareInstant] updateTransferStatus:STFileTransferStatusSent withIdentifier:info.identifier];
                    info.transferStatus = STFileTransferStatusSent;
                    
                    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                    float downloadSpeed = 1 / (now - startTimestamp) * fileSize;
                    [[STFileTransferModel shareInstant] updateDownloadSpeed:downloadSpeed withIdentifier:info.identifier];
                    info.downloadSpeed = downloadSpeed;
                    
                    succeed = YES;
                    tempInfo = info;
                }
            }
        }
        
        if (succeed) {
            [self.sendingTransferInfos removeObject:tempInfo];
            [self startSend];
        }
    }
}


- (void)cancelSendItemsAndPostCancel:(BOOL)postCancel {
    @synchronized(_prepareToSendFiles) {
        [_prepareToSendFiles removeAllObjects];
        
        if (self.sendingTransferInfos.count > 0) {
            for (STFileTransferInfo *info in self.sendingTransferInfos) {
                info.isCanceled = YES;
                info.transferStatus = STFileTransferStatusSendFailed;
                
                [[STFileTransferModel shareInstant] updateTransferStatus:STFileTransferStatusSendFailed withIdentifier:info.identifier];
            }
            
            if (postCancel) {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.cancelUrl]];
                request.HTTPMethod = @"POST";
                
                NSHTTPURLResponse *response = nil;
                NSError *error = nil;
                [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (response.statusCode != 200) {
                    NSLog(@"cancel error: %@", error);
                }
            }
        }
        
        [self.sendingTransferInfos removeAllObjects];
    }
    
    
}

@end
