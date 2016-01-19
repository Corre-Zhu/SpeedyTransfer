//
//  STWebServerConnection.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STWebServerConnection.h"

@implementation STWebServerConnection

- (void)processRequest:(GCDWebServerRequest *)request completion:(GCDWebServerCompletionBlock)completion {
    [super processRequest:request completion:completion];
}

- (void)didWriteBytes:(const void *)bytes length:(NSUInteger)length {
    [super didWriteBytes:bytes length:length];
    NSLog(@"%@, didWriteBytes: %@", self,  @(self.totalBytesWritten));
}

@end
