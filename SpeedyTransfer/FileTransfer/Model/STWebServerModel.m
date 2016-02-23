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
#import <GCDWebServerDataRequest.h>
#import <GCDWebServerFileResponse.h>
#import <GCDWebServerFunctions.h>
#import <GCDWebServerHTTPStatusCodes.h>
#import "STWebServerConnection.h"
#import "STDeviceInfo.h"
#import <Photos/Photos.h>

@interface STWebServerModel ()

@property (nonatomic, strong) GCDWebServer *webServer;

@end

@implementation STWebServerModel

- (NSString *)apiInfos {
    NSString *apiInfoStr = nil;
    NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
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
    if (!address) {
        address = @"";
    }
	
    return [@{@"version_code": @(1).stringValue,
              @"version_name": versionNum,
              @"device_name": deviceName,
              @"device_addr": address,
              @"user_nick": deviceName} jsonString];
}

- (void)startWebServer {
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
					[[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
						if (imageData.length > 0) {
							NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
							NSString *path = [[ZZPath picturePath] stringByAppendingPathComponent:[url.absoluteString lastPathComponent]];
							[imageData writeToFile:path atomically:YES];
							completionBlock([GCDWebServerFileResponse responseWithFile:path]);
						} else {
							completionBlock([GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound]);
						}
					}];
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
		}
		
		completionBlock([GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound]);
	}];
	
    [_webServer addHandlerForMethod:@"POST" path:@"/recv" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
        GCDWebServerDataRequest *dataRequest = (GCDWebServerDataRequest *)request;
        NSArray *items = [[[NSString alloc] initWithData:dataRequest.data encoding:NSUTF8StringEncoding] jsonArray];
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
            entity.dateString = [[NSDate date] dateString];
            entity.fileSize = [fileInfo doubleForKey:FILE_SIZE];
            entity.deviceName = deviceInfo.deviceName;
            entity.headImage = deviceInfo.headImage;
            
            NSString *fileType = [fileInfo stringForKey:FILE_TYPE];
            if ([fileType.lowercaseString isEqualToString:@"png"] ||
                [fileType.lowercaseString isEqualToString:@"jpg"] ||
                [fileType.lowercaseString isEqualToString:@"jpeg"]) {
                fileType = STFileTypePicture;
            } else {
                NSLog(@"未知文件类型");
                continue;
            }
            
            [tempArry addObject:entity];
        }
        
        [[STFileTransferModel shareInstant] receiveItems:tempArry];
        
        return [GCDWebServerResponse responseWithStatusCode:200];
    }];
    
    // Start server on port 8080
    NSDictionary *options = @{GCDWebServerOption_ConnectionClass: [STWebServerConnection class], GCDWebServerOption_Port: @(KSERVERPORT)};
    [_webServer startWithOptions:options error:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
}

@end
