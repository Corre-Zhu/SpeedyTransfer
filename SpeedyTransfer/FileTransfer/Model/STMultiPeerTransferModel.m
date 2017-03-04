//
//  STMultiPeerTransferModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/26.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STMultiPeerTransferModel.h"

static NSString *STServiceType = @"STServiceZZ";

@interface STMultiPeerTransferModel ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate> {
    
}

@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (copy, nonatomic) NSString *browsingName; // 需要监听的设备

@end

@implementation STMultiPeerTransferModel

HT_DEF_SINGLETON(STMultiPeerTransferModel, shareInstant);

- (MCSession *)session {
    if (!_session) {
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
        _session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionRequired];
        _session.delegate = self;
    }
    
    return _session;
}

- (void)startAdvertising {
    if (!_advertiser) {
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.session.myPeerID discoveryInfo:nil serviceType:STServiceType];
        _advertiser.delegate = self;
    }
    
    [_advertiser startAdvertisingPeer];
}

- (void)startBrowsingForName:(NSString *)name {
    if (!_browser) {
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.session.myPeerID serviceType:STServiceType];
        _browser.delegate = self;
    }
    
    self.browsingName = name;
    self.state = STMultiPeerStateBrowsing;
    [_browser startBrowsingForPeers];
}

- (void)reset {
    [_advertiser stopAdvertisingPeer];
    [_browser stopBrowsingForPeers];
    [_session disconnect];
}

- (NSString *)stringForPeerConnectionState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            return @"Connected";
            
        case MCSessionStateConnecting:
            return @"Connecting";
            
        case MCSessionStateNotConnected:
            return @"Not Connected";
    }
}

#pragma mark - Send files

- (void)sendData:(NSData *)data {
    NSError *error;
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    // Check the error return to know if there was an issue sending data to peers.  Note any peers in the 'toPeers' array argument are not connected this will fail.
    if (error) {
        NSLog(@"Error sending message to peers [%@]", error);
        return;
    }
    else {
        
    }
}

- (void)sendImage:(NSURL *)imageUrl {
    
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
  didReceiveInvitationFromPeer:(MCPeerID *)peerID
                   withContext:(nullable NSData *)context
             invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler {
    invitationHandler(YES, _session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"%s", __func__);
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)        browser:(MCNearbyServiceBrowser *)browser
              foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info {
    NSLog(@"Found peer: %@", peerID.displayName);

    if ([peerID.displayName isEqualToString:_browsingName]) {
        // 找到需要监听的设备
        [browser invitePeer:peerID toSession:_session withContext:nil timeout:20];
    }
}

// A nearby peer has stopped advertising.
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"Lost peer: %@", peerID.displayName);
}

// Browsing did not start due to an error.
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"%s", __func__);
}

#pragma mark - MCSessionDelegate methods

// Override this method to handle changes to peer session state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);
    
    self.state = (STMultiPeerState)state;
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
}

// MCSession delegate callback when we start to receive a resource from a peer in a given session
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Start receiving resource [%@] from peer %@ with progress [%@]", resourceName, peerID.displayName, progress);
    
}

// MCSession delegate callback when a incoming resource transfer ends (possibly with error)
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    // If error is not nil something went wrong
    if (error)
    {
        NSLog(@"Error [%@] receiving resource from peer %@ ", [error localizedDescription], peerID.displayName);
    }
    else
    {
        // No error so this is a completed transfer.  The resources is located in a temporary location and should be copied to a permenant locatation immediately.
        // Write to documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *copyPath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], resourceName];
        if (![[NSFileManager defaultManager] copyItemAtPath:[localURL path] toPath:copyPath error:nil])
        {
            NSLog(@"Error copying resource to documents directory");
        }
        else {
            // Get a URL for the path we just copied the resource to
            NSURL *imageUrl = [NSURL fileURLWithPath:copyPath];
            // Create an image transcript for this received image resource
            
        }
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

@end
