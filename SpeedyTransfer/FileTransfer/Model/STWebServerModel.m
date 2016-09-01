//
//  STWebServerModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STWebServerModel.h"
#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerErrorResponse.h>
#import <GCDWebServerDataRequest.h>
#import <GCDWebServerFileResponse.h>
#import <GCDWebServerFunctions.h>
#import <GCDWebServerHTTPStatusCodes.h>
#import <GCDWebServer/GCDWebServerMultiPartFormRequest.h>
#import "STWebServerConnection.h"
#import "STDeviceInfo.h"
#import <Photos/Photos.h>
#import <AddressBook/AddressBook.h>
#import <MediaPlayer/MediaPlayer.h>

@interface STWebServerModel ()

@property (nonatomic, strong) GCDWebServer *webServer;
@property (nonatomic) ABAddressBookRef addressBook;

@property (nonatomic, strong) GCDWebServer *webServer2;
@property (nonatomic, strong) NSDictionary *constVariable;
@property (nonatomic, strong) NSDictionary *variables;
@property (nonatomic, strong) NSMutableArray *transferFiles;

@end

@implementation STWebServerModel

HT_DEF_SINGLETON(STWebServerModel, shareInstant);

- (NSString *)apiInfos {
    NSString *apiInfoStr = nil;
    NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
    if (address.length == 0) {
        address = [UIDevice hotspotAddress];
    }
    if (address.length > 0) {
        NSString *devInfoUrl = [NSString stringWithFormat:@"http://%@:%@/info", address, @(KSERVERPORT)];
        NSString *portraitUrl = [NSString stringWithFormat:@"http://%@:%@/portrait", address, @(KSERVERPORT)];
        NSString *recvUrl = [NSString stringWithFormat:@"http://%@:%@/recv", address, @(KSERVERPORT)];
        NSDictionary *apiInfos = @{@"dev_info":@{@"href": devInfoUrl, @"rel": @"info"}, @"portrait": @{@"href": portraitUrl, @"rel": @"portrait"}, @"recv": @{@"href": recvUrl, @"rel": @"recv"}};
        apiInfoStr = [apiInfos jsonString];
    }
    
    return apiInfoStr;
}

- (NSString *)deviceInfos {
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* versionNum =[infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *deviceName = [[UIDevice currentDevice] name];
    if (deviceName.length == 0) {
		deviceName = [[UIDevice currentDevice] model];
		if (deviceName.length == 0) {
			deviceName = @"未知设备";
		}
    }
    NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
    if (address.length == 0) {
        address = [UIDevice hotspotAddress];
    }
    
    if (!address) {
        address = @"";
    }
	
    return [@{@"version_code": @(1).stringValue,
              @"version_name": versionNum,
              @"device_name": deviceName,
              @"device_addr": address,
              @"user_nick": deviceName} jsonString];
}

- (NSString*)uniquePathForPath:(NSString*)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString* directory = [path stringByDeletingLastPathComponent];
        NSString* file = [path lastPathComponent];
        NSString* base = [file stringByDeletingPathExtension];
        NSString* extension = [file pathExtension];
        int retries = 0;
        do {
            if (extension.length) {
                path = [directory stringByAppendingPathComponent:[[base stringByAppendingFormat:@" (%i)", ++retries] stringByAppendingPathExtension:extension]];
            } else {
                path = [directory stringByAppendingPathComponent:[base stringByAppendingFormat:@" (%i)", ++retries]];
            }
        } while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
    }
    return path;
}

- (BOOL)checkSandboxedPath:(NSString*)path {
    return [[path stringByStandardizingPath] hasPrefix:[ZZPath tmpReceivedPath]];
}

- (STFileType)fileTypeWithPathExtension:(NSString *)fileType {
    if ([fileType.lowercaseString isEqualToString:@"png"] ||
        [fileType.lowercaseString isEqualToString:@"jpg"] ||
        [fileType.lowercaseString isEqualToString:@"jpeg"] ||
        [fileType.lowercaseString isEqualToString:@"gif"] ||
		[fileType.lowercaseString isEqualToString:@"photo"]) {
        return STFileTypePicture;
    } else if ([fileType.lowercaseString isEqualToString:@"mov"] ||
               [fileType.lowercaseString isEqualToString:@"3gp"] ||
               [fileType.lowercaseString isEqualToString:@"mp4"] ||
			   [fileType.lowercaseString isEqualToString:@"video"]) {
        return STFileTypeVideo;
    } else if ([fileType.lowercaseString isEqualToString:@"vcard"]) {
        return STFileTypeContact;
    } else if ([fileType.lowercaseString isEqualToString:@"mp3"] ||
			   [fileType.lowercaseString isEqualToString:@"audio"] ||
               [fileType.lowercaseString isEqualToString:@"wav"] ||
               [fileType.lowercaseString isEqualToString:@"wma"] ||
               [fileType.lowercaseString isEqualToString:@"ogg"] ||
               [fileType.lowercaseString isEqualToString:@"ape"] ||
               [fileType.lowercaseString isEqualToString:@"acc"] ||
               [fileType.lowercaseString isEqualToString:@"aac"]) {
        return STFileTypeMusic;
    } else {
        NSLog(@"未知文件类型");
        return -1;
    }
}

- (BOOL)checkFileExtension:(NSString*)fileName {
    if ([self fileTypeWithPathExtension:fileName.pathExtension] >= 0) {
        return YES;
    }
    
    return NO;
}

- (void)startWebServer {
    if (_webServer.isRunning) {
        return;
    }
    
	if (!_webServer) {
		// Create server
		_webServer = [[GCDWebServer alloc] init];
		
		// Add a handler to respond to GET requests on any URL
		DECLARE_WEAK_SELF;
		
		[_webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
			if ([request.path isEqualToString:@"/api"]) {
				NSString *apiString = [weakSelf apiInfos];
				if (apiString.length > 0) {
					completionBlock([GCDWebServerDataResponse responseWithText:apiString]);
					return;
				}
			} else if ([request.path isEqualToString:@"/info"]) {
				NSString *infoString = [weakSelf deviceInfos];
				if (infoString.length > 0) {
					completionBlock([GCDWebServerDataResponse responseWithText:infoString]);
					return;
				}
			} else if ([request.path isEqualToString:@"/portrait"]) {
				NSString *headImage = [[NSUserDefaults standardUserDefaults] stringForKey:HeadImage];
				UIImage *image = nil;
				if ([headImage isEqualToString:CustomHeadImage]) {
					image = [[UIImage alloc] initWithContentsOfFile:[[ZZPath documentPath] stringByAppendingPathComponent:CustomHeadImage]];
				} else {
					headImage = [[NSUserDefaults standardUserDefaults] stringForKey:HeadImage_];
					image = [UIImage imageNamed:headImage];
				}
				if (image) {
					completionBlock([GCDWebServerDataResponse responseWithData:UIImageJPEGRepresentation(image, 1.0f) contentType:@"image/jpeg"]);
					return;
				}
				
			} else if ([request.path hasPrefix:@"/image/origin/"]) {
				NSInteger loc = [@"/image/origin/" length];
				NSString *assetIdentifier = [request.path substringWithRange:NSMakeRange(loc, request.path.length - loc)];
				if (assetIdentifier.length > 0) {
					PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil];
					if (savedAssets.count > 0) {
						PHAsset *asset = savedAssets.firstObject;
                        if (IOS9 && asset.mediaType == PHAssetMediaTypeVideo) {
                            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                NSString *temp = [info stringForKey:@"PHImageFileSandboxExtensionTokenKey"];
                                NSString *fileName = temp.lastPathComponent;                               NSString *path = [[ZZPath tmpUploadPath] stringByAppendingPathComponent:fileName];
                                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                                    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                                }
                                NSURL *outputURL = [NSURL fileURLWithPath:path];
                                AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
                                session.outputURL = outputURL;
                                session.outputFileType = AVFileTypeQuickTimeMovie;
                                [session exportAsynchronouslyWithCompletionHandler:^(void) {
                                    switch (session.status) {
                                        case AVAssetExportSessionStatusCompleted:
                                            completionBlock([GCDWebServerFileResponse responseWithFile:path isAttachment:YES]);
                                            break;
                                        default:
                                            completionBlock([GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound]);
                                            break;
                                    }
                                }];
                            }];
                        } else {
                            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                if (imageData.length > 0) {
                                    NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                                    NSString *path = [[ZZPath tmpUploadPath] stringByAppendingPathComponent:[url.absoluteString lastPathComponent]];
                                    [imageData writeToFile:path atomically:YES];
                                    completionBlock([GCDWebServerFileResponse responseWithFile:path isAttachment:YES]);
                                } else {
                                    completionBlock([GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound]);
                                }
                            }];
                        }
						return;
					}
				}
				
				completionBlock([GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound]);
				
			} else if ([request.path hasPrefix:@"/image/thumbnail/"]) {
				NSInteger loc = [@"/image/thumbnail/" length];
				NSString *assetIdentifier = [request.path substringWithRange:NSMakeRange(loc, request.path.length - loc)];
				if (assetIdentifier.length > 0) {
					PHFetchResult *savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil];
					if (savedAssets.count > 0) {
						PHAsset *asset = savedAssets.firstObject;
						PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
						options.resizeMode = PHImageRequestOptionsResizeModeExact;
						options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
						options.synchronous = YES;
						[[PHImageManager defaultManager] requestImageForAsset:asset
																   targetSize:CGSizeMake([UIScreen mainScreen].scale * 72.0f, [UIScreen mainScreen].scale * 72.0f)
																  contentMode:PHImageContentModeAspectFill
																	  options:options
																resultHandler:^(UIImage *result, NSDictionary *info) {
																	if (result) {
																		completionBlock([GCDWebServerDataResponse responseWithData:UIImageJPEGRepresentation(result, 1.0f) contentType:@"image/jpeg"]);
																	} else {
																		completionBlock([GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound]);
																	}
																	
																}];
						return;
					}
				}
			} else if ([request.path hasPrefix:@"/contact/"]) {
				NSInteger loc = [@"/contact/" length];
				NSString *recordId = [request.path substringWithRange:NSMakeRange(loc, request.path.length - loc)];
				if (recordId.length > 0) {
					if (!weakSelf.addressBook) {
						weakSelf.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
					}
					ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(weakSelf.addressBook, (ABRecordID)recordId.integerValue);
					CFArrayRef cfArrayRef =  (__bridge CFArrayRef)@[(__bridge id)recordRef];
					CFDataRef vcards = (CFDataRef)ABPersonCreateVCardRepresentationWithPeople(cfArrayRef);
					completionBlock([GCDWebServerDataResponse responseWithData:(__bridge NSData *)vcards contentType:@"contact/vcard"]);
					return;
				}
				
			} else if ([request.path hasPrefix:@"/music/"]) {
				NSInteger loc = [@"/music/" length];
				NSString *recordId = [request.path substringWithRange:NSMakeRange(loc, request.path.length - loc)];
				if (recordId.length > 0) {
					MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] init];
					MPMediaPropertyPredicate *predicate =[MPMediaPropertyPredicate predicateWithValue:recordId forProperty:MPMediaEntityPropertyPersistentID];
					[mediaQuery addFilterPredicate:predicate];
					NSArray *items = [mediaQuery items];
					MPMediaItem *item = items.firstObject;
					NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
					if (url) {
						// 导出音乐到本地
						AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
						AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
														  initWithAsset:songAsset
														  presetName: AVAssetExportPresetAppleM4A];
						exporter.outputFileType = @"com.apple.m4a-audio";
						NSString *exportPath = [[ZZPath tmpUploadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",[item valueForProperty:MPMediaEntityPropertyPersistentID]]];
						if([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
							[[NSFileManager defaultManager] removeItemAtPath:exportPath error:NULL];
						}
						
						NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
						exporter.outputURL = exportURL;
						[exporter exportAsynchronouslyWithCompletionHandler:^
						 {
							 switch (exporter.status) {
								 case AVAssetExportSessionStatusCompleted: {
									 completionBlock([GCDWebServerFileResponse responseWithFile:exportPath isAttachment:YES]);
									 NSLog (@"AVAssetExportSessionStatusCompleted");
									 break;
								 }
								 
								 default: {
									 completionBlock([GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound]);
									 NSLog (@"AVAssetExportSessionStatusFailed");
									 break;
								 }
							 }
						 }];
						return;
					}
				}
				
			}
			
			completionBlock([GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound]);
		}];
		
		[_webServer addHandlerForMethod:@"POST" path:@"/recv" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
			GCDWebServerDataRequest *dataRequest = (GCDWebServerDataRequest *)request;
            NSString *dataString = [[NSString alloc] initWithData:dataRequest.data encoding:NSUTF8StringEncoding];
			NSDictionary *itemsDic = [dataString jsonDictionary];
			NSArray *items = [itemsDic arrayForKey:@"items"];
			NSMutableArray *tempArry = [NSMutableArray array];
			for (NSDictionary *fileInfo in items) {
				NSString *file_url = [fileInfo stringForKey:FILE_URL];
				NSString *thumbnailUrl = [fileInfo stringForKey:ICON_URL];
				NSString *host = [[NSURL URLWithString:file_url] host];
				NSInteger port = [[[NSURL URLWithString:file_url] port] integerValue];
				STDeviceInfo *deviceInfo = [[STDeviceInfo alloc] init];
				deviceInfo.ip = host;
				deviceInfo.port = port;
				if (![deviceInfo setup]) {
					NSLog(@"deviceInfo setup error");
					continue;
				}
                [[STFileTransferModel shareInstant] addDevice:deviceInfo];
				
				STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
				entity.identifier = [NSString uniqueID];
				entity.transferType = STFileTransferTypeReceive;
				entity.transferStatus = STFileTransferStatusReceiving;
				entity.url = file_url;
				entity.thumbnailUrl = thumbnailUrl;
				entity.fileName = [fileInfo stringForKey:FILE_NAME];
				entity.fileSize = [fileInfo doubleForKey:FILE_SIZE];
				if (entity.url.pathExtension.length > 0) {
					entity.pathExtension = entity.url.pathExtension;
				} else {
					entity.pathExtension = [fileInfo stringForKey:FILE_TYPE];
	 			}
				entity.dateString = [[NSDate date] dateString];
				entity.deviceName = deviceInfo.deviceName;
				entity.headImage = deviceInfo.headImage;
				
                STFileType fileType = [weakSelf fileTypeWithPathExtension:[fileInfo stringForKey:FILE_TYPE]];
                if (fileType < 0) {
                    continue;
                } else {
                    entity.fileType = fileType;
                }
				
				[tempArry addObject:entity];
			}
			
			[[STFileTransferModel shareInstant] receiveItems:tempArry];
			
//			return [GCDWebServerResponse responseWithStatusCode:200];
			return [GCDWebServerDataResponse responseWithJSONObject:@{@"msg": @"ok"}];
		}];
	}
    
    [_webServer addHandlerForMethod:@"POST" path:@"/cancel" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
        NSString *ip = nil;
        if ([request.remoteAddressString containsString:@":"]) {
            ip = [[request.remoteAddressString componentsSeparatedByString:@":"] firstObject];
        } else {
            ip = request.remoteAddressString;
        }
        
        [[STFileTransferModel shareInstant] cancelSendItemsTo:ip];
        [[STFileTransferModel shareInstant] cancelReceiveItemsFrom:ip];
//        return [GCDWebServerResponse responseWithStatusCode:200];
		return [GCDWebServerDataResponse responseWithJSONObject:@{@"msg": @"ok"}];
    }];

    
    // Start server on port 8080
    NSDictionary *options = @{GCDWebServerOption_ConnectionClass: [STWebServerConnection class], GCDWebServerOption_Port: @(KSERVERPORT)};
    [_webServer startWithOptions:options error:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
}

- (void)stopWebServer {
	@autoreleasepool {
		[self.webServer stop];
		[self.webServer removeAllHandlers];
		self.webServer = nil;
	}
	
}

- (BOOL)isWebServerRunning {
	return _webServer.isRunning;
}

// 设置无界传输变量值
- (NSString *)htmlForFileInfo:(NSArray *)fileInfos category:(NSString *)category image:(NSString *)imageName icon:(NSString *)iconName {
	NSMutableString *htmlString = [NSMutableString string];
	
	[htmlString appendFormat:@"<div class=\"container1\"> \
	 <div class=\"container_wj\"> \
	 <div class=\"apk_container\"> \
	 <img src=\"%@\"> \
	 <div class=\"apk_text\">%@(%@)</div> \
	 </div>", imageName, category, @(fileInfos.count)];
	
	for (NSDictionary *fileInfo in fileInfos) {
		NSString *url = [fileInfo stringForKey:FILE_URL];
		NSString *iconUrl = [fileInfo stringForKey:ICON_URL];
		if (!iconUrl) {
			iconUrl = iconName;
		}
		NSString *fileName = [fileInfo stringForKey:FILE_NAME];
		double fileSize = [fileInfo doubleForKey:FILE_SIZE];
		NSString *fileSizeString = [NSString formatSize:fileSize];
		[htmlString appendFormat:@"<a href=\"%@\"> <div class=\"apk_68dp\"> \
		 <div class=\"icon\"><img src=\"%@\"></div> \
		 <div class=\"apk_text1\">%@</div> \
		 <div class=\"xz\"><img src=\"images/xz.png\"></div> \
		 <div class=\"apk_text2\">%@</div> \
		 <div class=\"line\"></div> \
		 </div> \
		 </a>", url, iconUrl, fileName, fileSizeString];
	}
	
	[htmlString appendFormat:@" </div> \
	 <div class=\"jiange\"> \
	 <div class=\"line1\"></div> \
	 <div class=\"jianxi\"></div> \
	 <div class=\"line1\"></div> \
	 </div> \
	 </div>"];
	
	return htmlString;
}

- (void)setupVariables {
	NSMutableArray *picArray = [NSMutableArray arrayWithCapacity:self.transferFiles.count];
	NSMutableArray *musicArray = [NSMutableArray arrayWithCapacity:self.transferFiles.count];
	NSMutableArray *videoArray = [NSMutableArray arrayWithCapacity:self.transferFiles.count];
	NSMutableArray *contactArray = [NSMutableArray arrayWithCapacity:self.transferFiles.count];
	for (NSDictionary *fileInfo in self.transferFiles) {
		NSString *url = [fileInfo stringForKey:FILE_URL];
		NSString *fileType = [fileInfo stringForKey:FILE_TYPE];
		if ([url containsString:@"/image/"]) {
			if ([fileType.lowercaseString isEqualToString:@"mov"] ||
				[fileType.lowercaseString isEqualToString:@"3gp"] ||
				[fileType.lowercaseString isEqualToString:@"mp4"]) {
				[videoArray addObject:fileInfo];
			} else {
				[picArray addObject:fileInfo];
			}
		} else if ([url containsString:@"/contact/"]) {
			[contactArray addObject:fileInfo];
		} else if ([url containsString:@"/music/"]) {
			[musicArray addObject:fileInfo];
		}
	}
	
	NSMutableString *htmlString = [NSMutableString string];
	
	if (picArray.count > 0) {
		[htmlString appendString:[self htmlForFileInfo:picArray category:@"图片" image:@"images/ic_picture_red_24dp.png" icon:nil]];
	}
	
	if (musicArray.count > 0) {
		[htmlString appendString:[self htmlForFileInfo:musicArray category:@"音乐" image:@"images/ic_picture_green_12dp.png" icon:@"images/ic_music_purple_40dp.png"]];
	}
	
	if (videoArray.count > 0) {
		[htmlString appendString:[self htmlForFileInfo:videoArray category:@"视频" image:@"images/ic_picture_green_12dp.png" icon:nil]];
	}
	
	if (contactArray.count > 0) {
		[htmlString appendString:[self htmlForFileInfo:contactArray category:@"联系人" image:@"images/ic_picture_green_12dp.png" icon:@"images/wendang.png"]];
	}
	
	NSString *summary = [NSString stringWithFormat:@"%@给您发送了%@个文件", [UIDevice currentDevice].name, @(self.transferFiles.count)];
	[[STWebServerModel shareInstant] setVariables:@{@"summary": summary,
													@"fileInfo": htmlString}];
	
}

- (void)addTransferFiles:(NSArray *)files {
	if (!self.transferFiles) {
		self.transferFiles = [NSMutableArray array];
	}
	
	[self.transferFiles addObjectsFromArray:files];
	
	[self setupVariables];
}

- (void)startWebServer2 {
	if (!self.constVariable) {
		self.constVariable = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"无界传送", nil), @"title", NSLocalizedString(@"接收", nil), @"recv", NSLocalizedString(@"传送", nil), @"send", NSLocalizedString(@"更多", nil), @"more", NSLocalizedString(@"选择文件发给好友", nil), @"selectFiles", NSLocalizedString(@"关于", nil), @"about", NSLocalizedString(@"常见问题", nil), @"faq", NSLocalizedString(@"邀请安装", nil), @"zero_mobile_data", NSLocalizedString(@"邀请安装", nil), @"yqaz", NSLocalizedString(@"无界互传是一种灵活的，不受操作系统限制的文件传输方式。通过无界互传，可以在Android、IOS、Windows等系统的设备之间极速互传文件。", nil), @"adword", NSLocalizedString(@"1.传输速度慢？", nil), @"q1", NSLocalizedString(@"尽量在网络环境简单的地方使用，如果附近的wifi比较多，可能会造成干扰。<br>尽量少使用UC等浏览器来传输，建议使用为chrome浏览器来传输。<br>将设备的扩展卡更换为速度更快的扩展卡。", nil), @"a1", NSLocalizedString(@"2.启动VPN后无法进行发送接收？", nil), @"q2", NSLocalizedString(@"设备开启VPN后，会导致双方无法连接并互传资料，请在进行文件传输前退出VPN。", nil), @"a2", NSLocalizedString(@"3.找不到接收到的文件保存位置？", nil), @"q3", NSLocalizedString(@"Chrome浏览器接收的文件默认保存在设备的Download文件夹中。<br>其它浏览器接收的文件保存在该浏览器默认的下载目录中,可在该浏览器的设置中查看具体的下载目录。", nil), @"a3", NSLocalizedString(@"4.发送文件时每次只能选择一个？", nil), @"q4", NSLocalizedString(@"每次只能选择一个文件发送，是因为浏览器的限制，如需批量发送文件请安装点传。", nil), @"a4", NSLocalizedString(@"5.接收文件时每个文件都需要点击下载？", nil), @"q5", NSLocalizedString(@"浏览器无法支持批量下载，只能单独点击文件下载。如需批量发送文件请安装点传。", nil), @"a5", NSLocalizedString(@"6.IOS常见问题", nil), @"q6", NSLocalizedString(@"因IOS系统限制，音乐和视频可播放但不能下载，图片可保存至本地。", nil), @"a6", NSLocalizedString(@"好友联网扫描二维码直接下载<br>或在浏览器输入网址<br>http://www.3tkj.cn", nil), @"invite_desc", nil];
	}
	
	if (!_webServer2) {
		// Get the path to the website directory
		NSString* websitePath = [[NSBundle mainBundle] pathForResource:@"Website" ofType:nil];
		
		self.webServer2 = [[GCDWebServer alloc] init];
		
		// Add a default handler to serve static files (i.e. anything other than HTML files)
		[self.webServer2 addGETHandlerForBasePath:@"/" directoryPath:websitePath indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
		
		__weak typeof(self) weakSelf = self;
		// Add an override handler for all requests to "*.html" URLs to do the special HTML templatization
		[self.webServer2 addHandlerForMethod:@"GET"
								   pathRegex:@"/.*\\.html"
								requestClass:[GCDWebServerRequest class]
								processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
									NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", request.remoteAddressString]];
									[[STFileTransferModel shareInstant] addNewBrowser:url.host];
									
									NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithDictionary:weakSelf.constVariable];
									if (weakSelf.variables.count > 0) {
										[variables addEntriesFromDictionary:weakSelf.variables];
									}
									return [GCDWebServerDataResponse responseWithHTMLTemplate:[websitePath stringByAppendingPathComponent:request.path]
																					variables:variables];
								}];
		
		// Add an override handler to redirect "/" URL to "/recive.html"
		[self.webServer2 addHandlerForMethod:@"GET"
										path:@"/"
								requestClass:[GCDWebServerRequest class]
								processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
									// 默认跳转到接收页面
									NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", request.remoteAddressString]];
									[[STFileTransferModel shareInstant] addNewBrowser:url.host];
									
									NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithDictionary:weakSelf.constVariable];
									if (weakSelf.variables.count > 0) {
										[variables addEntriesFromDictionary:weakSelf.variables];
									}
									return [GCDWebServerDataResponse responseWithHTMLTemplate:[websitePath stringByAppendingPathComponent:@"recive.html"]
																					variables:variables];
								}];
		
        // File upload
        [self.webServer2 addHandlerForMethod:@"POST" path:@"/upload" requestClass:[GCDWebServerMultiPartFormRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
            GCDWebServerMultiPartFormRequest *multiPartFormRequest = (GCDWebServerMultiPartFormRequest *)request;
            
            NSRange range = [[request.headers objectForKey:@"Accept"] rangeOfString:@"application/json" options:NSCaseInsensitiveSearch];
            NSString* contentType = (range.location != NSNotFound ? @"application/json" : @"text/plain; charset=utf-8");  // Required when using iFrame transport (see https://github.com/blueimp/jQuery-File-Upload/wiki/Setup)
            
            GCDWebServerMultiPartFile *file = [multiPartFormRequest firstFileForControlName:@"fileToUpload"];
			if ([file.fileName hasPrefix:@"."]) { // || ![weakSelf checkFileExtension:file.fileName]) {
                return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_Forbidden message:@"Uploaded file name \"%@\" is not allowed", file.fileName];
            }
			
            NSString* relativePath = [[multiPartFormRequest firstArgumentForControlName:@"path"] string];
            NSString* absolutePath = [weakSelf uniquePathForPath:[[[ZZPath tmpReceivedPath] stringByAppendingPathComponent:relativePath] stringByAppendingPathComponent:file.fileName]];
            if (![weakSelf checkSandboxedPath:absolutePath]) {
                return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_NotFound message:@"\"%@\" does not exist", relativePath];
            }
            
            NSError* error = nil;
            if (![[NSFileManager defaultManager] moveItemAtPath:file.temporaryPath toPath:absolutePath error:&error]) {
                return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError underlyingError:error message:@"Failed moving uploaded file to \"%@\"", relativePath];
            }
            
            // 上传成功
            STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
            entity.identifier = [NSString uniqueID];
            entity.transferType = STFileTransferTypeReceive;
            entity.transferStatus = STFileTransferStatusReceived;
            entity.url = absolutePath;
            entity.fileName = file.fileName;
            entity.fileSize = [request.headers doubleForKey:@"Content-Length"];
            entity.pathExtension = [file.fileName pathExtension];
            entity.dateString = [[NSDate date] dateString];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", request.remoteAddressString]];
            entity.deviceName = url.host;
            
            STFileType fileType = [weakSelf fileTypeWithPathExtension:entity.pathExtension];
            entity.fileType = fileType;
            
            [[STFileTransferModel shareInstant] receiveItems:@[entity]];
            
            return [GCDWebServerDataResponse responseWithJSONObject:@{} contentType:contentType];
        }];

	}
	
	NSDictionary *options = @{GCDWebServerOption_Port: @(KSERVERPORT2)};
	[self.webServer2 startWithOptions:options error:nil];
	NSLog(@"Visit %@ in your web browser", self.webServer2.serverURL);
}

- (void)stopWebServer2 {
	@autoreleasepool {
		[self.webServer2 stop];
		[self.webServer2 removeAllHandlers];
		self.webServer2 = nil;
		
		[self.transferFiles removeAllObjects];
		self.variables = nil;
	}
	
}

- (BOOL)isWebServer2Running {
    return _webServer2.isRunning;
}

@end
