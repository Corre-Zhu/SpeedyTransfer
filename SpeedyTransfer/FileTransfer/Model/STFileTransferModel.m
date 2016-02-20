//
//  STFileTransferModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileTransferModel.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import "STDeviceInfo.h"

@interface STFileTransferModel ()<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *udpSocket;
    NSTimer *timeoutTimer;
}

@end

@implementation STFileTransferModel

HT_DEF_SINGLETON(STFileTransferModel, shareInstant);

- (instancetype)init {
    self = [super init];
    if (self) {
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [udpSocket setIPv4Enabled:YES];
        [udpSocket setIPv6Enabled:NO];
        
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(timeout) userInfo:nil repeats:YES];
    }
	
    return self;
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
                NSArray *tempArr = [NSArray arrayWithArray:self.friendsInfoArray];
                NSMutableArray *tempMutableArry = [NSMutableArray arrayWithArray:self.friendsInfoArray];
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
                    self.friendsInfoArray = [NSArray arrayWithArray:tempMutableArry];
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
                    
                    NSLog(@"%@, %@, %@", dataString, host, @(port).stringValue);
                    
                    BOOL find = NO;
                    NSArray *tempArr = [NSArray arrayWithArray:self.friendsInfoArray];
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
                        self.friendsInfoArray = [tempArr arrayByAddingObject:userInfo];
                    }
                }
            }
        }
    }];
    
}

@end
