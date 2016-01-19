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

#define PORT 8081

@interface STWebServerModel ()

@property (nonatomic, strong) GCDWebServer *webServer;

@end

@implementation STWebServerModel

- (NSString *)apiInfos {
    NSString *apiInfoStr = nil;
    NSString *address = GCDWebServerGetPrimaryIPAddress(NO);
    if (address.length > 0) {
        NSString *devInfoUrl = [NSString stringWithFormat:@"%@:%@/info", address, @(PORT)];
        NSString *portraitUrl = [NSString stringWithFormat:@"%@:%@/portrait", address, @(PORT)];
        NSString *recvUrl = [NSString stringWithFormat:@"%@:%@/recv", address, @(PORT)];
        
        NSArray *apiInfos = @[@{@"dev_info": @{@"href": devInfoUrl, @"rel": @"dev_info"}},
                              @{@"portrait": @{@"href": portraitUrl, @"rel": @"portrait"}},
                              @{@"recv": @{@"href": recvUrl, @"rel": @"recv"}}];
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
              @"user_nick": deviceName} jsonString];
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
        NSLog(@"%@", [[NSString alloc] initWithData:dataRequest.data encoding:NSUTF8StringEncoding]);
        return [GCDWebServerResponse responseWithStatusCode:200];
    }];
    
    // Start server on port 8080
    NSDictionary *options = @{GCDWebServerOption_ConnectionClass: [STWebServerConnection class], GCDWebServerOption_Port: @(PORT)};
    [_webServer startWithOptions:options error:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
}

@end
