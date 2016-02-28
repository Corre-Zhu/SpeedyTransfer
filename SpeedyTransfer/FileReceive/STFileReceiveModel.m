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
    NSTimer *broadcastTimer;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];

    }
    
    return self;
}

- (void)doBroadcast {
	NSString *broadcastAddr = [UIDevice getBroadcastAddress];
	if (broadcastAddr.length == 0) {
		broadcastAddr = @"255.255.255.255";
	}
    NSString *deviceName = [NSString stringWithFormat:@"DCDC:%@:1", @(KSERVERPORT)];
    [udpSocket sendData:[deviceName dataUsingEncoding:NSUTF8StringEncoding] toHost:broadcastAddr port:KUDPPORT withTimeout:-1 tag:0];
}

- (void)startBroadcast {
    broadcastTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(doBroadcast) userInfo:nil repeats:YES];
}

- (void)invalidTimer {
    [broadcastTimer invalidate];
    broadcastTimer = nil;
}

- (void)didEnterBackgroundNotification {
    [self invalidTimer];
}

- (void)willEnterForegroundNotification {
    [self invalidTimer];
    [self startBroadcast];
}

@end
