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
#import "STWebServerConnection.h"
#import "STDeviceInfo.h"

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
    if (!deviceName) {
        deviceName = @"";
    }
    NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
    if (!address) {
        address = @"";
    }
    return [@{@"version_code": @(1).stringValue,
              @"version_name": versionNum,
              @"device_name": deviceName,
              @"device_addr": address,
              @"user_nick": deviceName,
              @"device_id": [[UIDevice currentDevice] openUDID]} jsonString];
}

- (void)startWebServer {
    // Create server
    _webServer = [[GCDWebServer alloc] init];
    
    // Add a handler to respond to GET requests on any URL
    DECLARE_WEAK_SELF;
    [_webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                  
                                  if ([request.path isEqualToString:@"/api"]) {
                                      NSString *apiString = [weakSelf apiInfos];
                                      if (apiString.length > 0) {
                                          return [GCDWebServerDataResponse responseWithText:apiString];
                                      }
                                  } else if ([request.path isEqualToString:@"/info"]) {
                                      NSString *infoString = [weakSelf deviceInfos];
                                      if (infoString.length > 0) {
                                          return [GCDWebServerDataResponse responseWithText:infoString];
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
                                          return [GCDWebServerDataResponse responseWithData:UIImageJPEGRepresentation(image, 1.0f) contentType:@"image/jpeg"];
                                      }
                                      
                                  } else if ([request.path hasPrefix:@"/file"]) {
                                      return [GCDWebServerFileResponse responseWithFile:[[NSBundle mainBundle] pathForResource:@"IMG_7551" ofType:@"JPG"]];
                                  }
                                  
                                  return nil;
                              }];
    
    [_webServer addHandlerForMethod:@"POST" path:@"/recv" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
        GCDWebServerDataRequest *dataRequest = (GCDWebServerDataRequest *)request;
        NSArray *items = [[[NSString alloc] initWithData:dataRequest.data encoding:NSUTF8StringEncoding] jsonArray];
        NSMutableArray *tempArry = [NSMutableArray array];
        for (NSDictionary *fileInfo in items) {
            NSString *file_url = [fileInfo stringForKey:FILE_URL];
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
            entity.fileName = [fileInfo stringForKey:FILE_NAME];
            entity.dateString = [[NSDate date] dateString];
            entity.fileSize = [fileInfo doubleForKey:FILE_SIZE];
            entity.deviceId = deviceInfo.deviceId;
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
