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

- (STFileType)fileTypeWithPathExtension:(NSString *)pathExtension {
    if ([pathExtension.lowercaseString isEqualToString:@"png"] ||
        [pathExtension.lowercaseString isEqualToString:@"jpg"] ||
        [pathExtension.lowercaseString isEqualToString:@"jpeg"]) {
        return STFileTypePicture;
    } else if ([pathExtension.lowercaseString isEqualToString:@"mov"] ||
               [pathExtension.lowercaseString isEqualToString:@"3gp"] ||
               [pathExtension.lowercaseString isEqualToString:@"mp4"]) {
        return STFileTypeVideo;
    } else if ([pathExtension.lowercaseString isEqualToString:@"vcard"]) {
        return STFileTypeContact;
    } else if ([pathExtension.lowercaseString isEqualToString:@"mp3"] ||
               [pathExtension.lowercaseString isEqualToString:@"mp3"]) {
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
                                            completionBlock([GCDWebServerFileResponse responseWithFile:path]);
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
                                    completionBlock([GCDWebServerFileResponse responseWithFile:path]);
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
									 completionBlock([GCDWebServerFileResponse responseWithFile:exportPath]);
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
			NSArray *items = [dataString jsonArray];
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
				
				STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
				entity.identifier = [NSString uniqueID];
				entity.transferType = STFileTransferTypeReceive;
				entity.transferStatus = STFileTransferStatusReceiving;
				entity.url = file_url;
				entity.thumbnailUrl = thumbnailUrl;
				entity.fileName = [fileInfo stringForKey:FILE_NAME];
				entity.fileSize = [fileInfo doubleForKey:FILE_SIZE];
				entity.pathExtension = [fileInfo stringForKey:FILE_TYPE];
				entity.dateString = [[NSDate date] dateString];
				entity.deviceName = deviceInfo.deviceName;
				entity.headImage = deviceInfo.headImage;
				
                STFileType fileType = [weakSelf fileTypeWithPathExtension:entity.pathExtension];
                if (fileType < 0) {
                    continue;
                } else {
                    entity.fileType = fileType;
                }
				
				[tempArry addObject:entity];
			}
			
			[[STFileTransferModel shareInstant] receiveItems:tempArry];
			
			return [GCDWebServerResponse responseWithStatusCode:200];
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
        return [GCDWebServerResponse responseWithStatusCode:200];
    }];

    
    // Start server on port 8080
    NSDictionary *options = @{GCDWebServerOption_ConnectionClass: [STWebServerConnection class], GCDWebServerOption_Port: @(KSERVERPORT)};
    [_webServer startWithOptions:options error:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
}

- (void)stopWebServer {
	[self.webServer stop];
}

- (void)startWebServer2 {
	if (!self.constVariable) {
		self.constVariable = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"", nil), @"title", NSLocalizedString(@"接收", nil), @"recv", NSLocalizedString(@"传送", nil), @"send", NSLocalizedString(@"更多", nil), @"more", NSLocalizedString(@"选择文件发给好友", nil), @"selectFiles", nil];
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
            if (([file.fileName hasPrefix:@"."]) || ![weakSelf checkFileExtension:file.fileName]) {
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
	[self.webServer2 stop];
	self.variables = nil;
}

@end
