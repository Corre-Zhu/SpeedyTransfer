//
//  STFileReceiveModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileReceiveModel.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface STFileReceiveModel ()<GCDAsyncUdpSocketDelegate>
{
    NSTimer *broadcastTimer;
}

@property (nonatomic, strong)GCDAsyncUdpSocket *udpSocket;

@end

@implementation STFileReceiveModel

HT_DEF_SINGLETON(STFileReceiveModel, shareInstant);

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];

    }
    
    return self;
}

- (GCDAsyncUdpSocket *)udpSocket {
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_udpSocket setIPv4Enabled:YES];
        [_udpSocket setIPv6Enabled:NO];
        NSError *error = nil;
        if ([_udpSocket enableBroadcast:YES error:&error] == false) {
            NSLog(@"Failed to enable broadcast, Reason : %@",[error userInfo]);
        }
    }
    
    return _udpSocket;
}

- (void)doBroadcast {
	NSString *broadcastAddr = [UIDevice getBroadcastAddress];
	if (broadcastAddr.length > 0) {
        NSString *deviceName = [NSString stringWithFormat:@"DCDC:%@:1", @(KSERVERPORT)];
        [self.udpSocket sendData:[deviceName dataUsingEncoding:NSUTF8StringEncoding] toHost:broadcastAddr port:KUDPPORT withTimeout:-1 tag:0];
        
        NSLog(@"start send Data");
	}
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
    _udpSocket = nil;
}

- (void)willEnterForegroundNotification {
    [self invalidTimer];
    [self startBroadcast];
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"didSendData");
}

@end
