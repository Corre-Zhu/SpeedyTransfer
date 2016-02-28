//
//  STWebServerConnection.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STWebServerConnection.h"

@interface STWebServerConnection ()

@property (nonatomic, strong) NSString *path;
@property (nonatomic) NSTimeInterval startTimeStamp; // 请求开始时间戳

@end

@implementation STWebServerConnection

- (void)processRequest:(GCDWebServerRequest *)request completion:(GCDWebServerCompletionBlock)completion {
    self.path = [request.path copy];
    self.startTimeStamp = [[NSDate date] timeIntervalSince1970];
    NSLog(@"request path: %@", self.path);
    [super processRequest:request completion:completion];
}

- (void)didWriteBytes:(const void *)bytes length:(NSUInteger)length {
    [super didWriteBytes:bytes length:length];
    if ([self.path containsString:@"/image/origin"] ||
        [self.path containsString:@"/contact"]) {
        NSDictionary *info = @{REQUEST_PATH: self.path, TOTAL_BYTES_WRITTEN: @(self.totalBytesWritten), START_TIMESTAMP: @(self.startTimeStamp)};
        [[NSNotificationCenter defaultCenter] postNotificationName:KFileWrittenProgressNotification object:nil userInfo:info];
    } else {
        
    }
}

@end
