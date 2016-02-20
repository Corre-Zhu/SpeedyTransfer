//
//  STFileReceiveModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileReceiveModel.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface STFileReceiveModel ()
{
    GCDAsyncUdpSocket *udpSocket;
}

@end

@implementation STFileReceiveModel

HT_DEF_SINGLETON(STFileReceiveModel, shareInstant);

- (instancetype)init {
    self = [super init];
    if (self) {
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [udpSocket setIPv4Enabled:YES];
        [udpSocket setIPv6Enabled:NO];
        NSError *error = nil;
        if ([udpSocket enableBroadcast:YES error:&error] == false) {
            NSLog(@"Failed to enable broadcast, Reason : %@",[error userInfo]);
        }
    }
    
    return self;
}

- (void)doBroadcast {
    NSString *deviceName = [NSString stringWithFormat:@"DCDC:%@:1", @(KSERVERPORT)];
    [udpSocket sendData:[deviceName dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:KUDPPORT withTimeout:-1 tag:0];
}

- (void)startBroadcast {
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(doBroadcast) userInfo:nil repeats:YES];
}

@end
