//
//  STMultiPeerTransferModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/26.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STMultiPeerTransferModel.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "STPacket.h"
#import "ZZFunction.h"
#import <Photos/Photos.h>
#import "STWebServerModel.h"

static NSString *STServiceType = @"STServiceZZ";

// KVO path strings for observing changes to properties of NSProgress
static NSString * const kProgressCancelledKeyPath          = @"cancelled";
static NSString * const kProgressCompletedUnitCountKeyPath = @"completedUnitCount";

@interface STMultiPeerTransferModel ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate> {
}

@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) STDeviceInfo *deviceInfo; // 当前连接的设备

@property (nonatomic, strong) NSMutableArray *prepareToSendFiles; // 准备要发送的文件
@property (nonatomic, strong) STFileTransferInfo *sendingTransferInfo; // 正在发送的文件
@property (nonatomic, strong) id sendingItem; // 正在发送的文件
@property (nonatomic, strong) NSProgress *sendingProgress; // 发送进度

// 文件接收
@property (nonatomic, strong) NSMutableArray *prepareToReceiveFiles; // 收到的的所有文件

@end

@implementation STMultiPeerTransferModel

HT_DEF_SINGLETON(STMultiPeerTransferModel, shareInstant);

- (instancetype)init {
    self = [super init];
    if (self) {
        _deviceInfo = [[STDeviceInfo alloc] init];
    }
    
    return self;
}

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
    
    _deviceInfo.deviceName = name;
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

- (void)addSendItems:(NSArray *)items {
    if (!_prepareToSendFiles) {
        _prepareToSendFiles = [NSMutableArray array];
    }
    
    @synchronized(_prepareToSendFiles) {
        [_prepareToSendFiles addObjectsFromArray:items];
    }
    
    [self startSend];
}

- (void)startSend {
    if (_sendingItem) {
        return;
    }
    
    @synchronized (_prepareToSendFiles) {
        if (_prepareToSendFiles.count == 0) {
            return;
        }
        
        _sendingItem = [_prepareToSendFiles firstObject];
        [_prepareToSendFiles removeObject:_sendingItem];
    }
    
    ZZFileUtility *fileUtility = [[ZZFileUtility alloc] init];
    [fileUtility fileInfoWithItems:@[_sendingItem] completionBlock:^(NSArray *fileInfos) {
        NSDictionary *fileInfo = [fileInfos firstObject];
        
        // 写数据库
        _sendingTransferInfo = [self insertItemsToDbWithFileInfo:fileInfo];
        
        // 1、发送info
        if ([self sendData:[STPacket initWithFileInfo:fileInfo]]) {
            if ([_sendingItem isKindOfClass:[PHAsset class]]) {
                PHAsset *asset = (PHAsset *)_sendingItem;

                // 2、发送缩略图
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
                                                                NSData *pngData = UIImageJPEGRepresentation(result, 1.0);
                                                                
                                                                NSString *identi = [fileInfo stringForKey:FILE_IDENTIFIER];
                                                                NSString *filePath = [[ZZPath tmpUploadPath] stringByAppendingPathComponent:[identi stringByAppendingString:@"_thumb"]];
                                                                [pngData writeToFile:filePath atomically:YES]; // Write the file
                                                                // Get a URL for this file resource
                                                                NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
                                                                [self sendImage:imageUrl];
                                                                
                                                            } else {
                                                                [self sendFaild];
                                                            }
                                                            
                                                        }];
                
                // 3、发送大图
                if (IOS9 && asset.mediaType == PHAssetMediaTypeVideo) {
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        NSString *identi = [fileInfo stringForKey:FILE_IDENTIFIER];
                        NSString *filePath = [[ZZPath tmpUploadPath] stringByAppendingPathComponent:identi];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                            [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
                        }
                        NSURL *outputURL = [NSURL fileURLWithPath:filePath];
                        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
                        session.outputURL = outputURL;
                        session.outputFileType = AVFileTypeQuickTimeMovie;
                        [session exportAsynchronouslyWithCompletionHandler:^(void) {
                            switch (session.status) {
                                case AVAssetExportSessionStatusCompleted:
                                    [self sendImage:outputURL];
                                    break;
                                default:
                                    [self sendFaild];
                                    break;
                            }
                        }];
                    }];
                } else {
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        if (imageData.length > 0) {
                            NSString *identi = [fileInfo stringForKey:FILE_IDENTIFIER];
                            NSString *path = [[ZZPath tmpUploadPath] stringByAppendingPathComponent:identi];
                            [imageData writeToFile:path atomically:YES];
                            [self sendImage:[NSURL fileURLWithPath:path]];
                        } else {
                            [self sendFaild];
                        }
                    }];
                }
                
                
                
            }
        } else {
            [self sendFaild];
        }
        
        
    }];
    
}

- (void)clearProgress {
    if (_sendingProgress) {
        [_sendingProgress removeObserver:self forKeyPath:kProgressCancelledKeyPath];
        [_sendingProgress removeObserver:self forKeyPath:kProgressCompletedUnitCountKeyPath];
        _sendingProgress = nil;
    }
}

- (void)sendSucceed {
    [self clearProgress];
    
    [self updateTransferStatus:STFileTransferStatusSent withIdentifier:_sendingTransferInfo.identifier];
    self.sendingTransferInfo.progress = 1.0;
    self.sendingTransferInfo.transferStatus = STFileTransferStatusSent;
    self.sendingItem = nil;
    self.sendingTransferInfo = nil;
    [self startSend];
}

- (void)sendFaild {
    [self clearProgress];
    
    _sendingTransferInfo.transferStatus = STFileTransferStatusSendFailed;
    [self updateTransferStatus:STFileTransferStatusSendFailed withIdentifier:_sendingTransferInfo.identifier];
    
    self.sendingItem = nil;
    self.sendingTransferInfo = nil;
    [self startSend];
}

- (BOOL)sendData:(NSData *)data {
    NSError *error;
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    // Check the error return to know if there was an issue sending data to peers.  Note any peers in the 'toPeers' array argument are not connected this will fail.
    if (error) {
        NSLog(@"Error sending message to peers [%@]", error);
        return NO;
    }
    
    return YES;
}

- (void)sendImage:(NSURL *)imageUrl {
    __weak typeof(self) weakSelf = self;
    
    BOOL isThumb = [[imageUrl absoluteString] hasSuffix:@"_thumb"];
    
    MCPeerID *connectedPeerId = _session.connectedPeers.firstObject;
    // Send the resource to the remote peer.  The completion handler block will be called at the end of sending or if any errors occur
    NSProgress *progress = [self.session sendResourceAtURL:imageUrl withName:[imageUrl lastPathComponent] toPeer:connectedPeerId withCompletionHandler:^(NSError *error) {
        // Implement this block to know when the sending resource transfer completes and if there is an error.
        if (error) {
            NSLog(@"Send resource to peer [%@] completed with Error [%@]", connectedPeerId.displayName, error);
            
            if (!isThumb) {
                [weakSelf sendFaild];
            }
        } else {
            if (!isThumb) {
                [weakSelf sendSucceed];
            }
        }
    }];
    
    if (!isThumb) {
        _sendingProgress = progress;
        [_sendingProgress addObserver:self forKeyPath:kProgressCancelledKeyPath options:NSKeyValueObservingOptionNew context:NULL];
        [_sendingProgress addObserver:self forKeyPath:kProgressCompletedUnitCountKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)sendHeadPortrait {
    UIImage *headPortrait = nil;
    
    NSString *headImage = [[NSUserDefaults standardUserDefaults] stringForKey:HeadImage];
    if ([headImage isEqualToString:CustomHeadImage]) {
        headPortrait = [[UIImage alloc] initWithContentsOfFile:[[ZZPath documentPath] stringByAppendingPathComponent:CustomHeadImage]];
    } else {
        headPortrait = [UIImage imageNamed:headImage];
    }
    
    if (headPortrait) {
        [self sendData:[STPacket initWithHeadPortrait:headPortrait]];
    }

}

- (STFileTransferInfo *)insertItemsToDbWithFileInfo:(NSDictionary *)fileInfo {
    STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
    entity.identifier = [fileInfo stringForKey:FILE_IDENTIFIER];
    entity.transferType = STFileTransferTypeSend;
    entity.transferStatus = STFileTransferStatusSending;
    entity.fileName = [fileInfo stringForKey:FILE_NAME];
    entity.dateString = [[NSDate date] dateString];
    entity.fileSize = [fileInfo doubleForKey:FILE_SIZE];
    
    NSString *fileUrl = [fileInfo stringForKey:FILE_URL];
    if ([fileUrl containsString:@"/image"]) {
        entity.fileType = STFileTypePicture;
        entity.url = [fileInfo stringForKey:ASSET_ID];
    } else if ([fileUrl containsString:@"/contact"]) {
        entity.fileType = STFileTypeContact;
        entity.url = @([fileInfo integerForKey:RECORD_ID]).stringValue;
    } else if ([fileUrl containsString:@"/music"]) {
        entity.fileType = STFileTypeMusic;
        entity.url = @([fileInfo longLongForKey:RECORD_ID]).stringValue;
    }
    
    entity.deviceName = _deviceInfo.deviceName;
   // entity.headImage = deviceInfo.headImage;
    
    [self insertTransferInfo:entity];
    [self addTransferFile:entity];
    
    return entity;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSProgress *progress = object;
    if ([keyPath isEqualToString:kProgressCompletedUnitCountKeyPath]) {
        // Notify the delegate of our progress change
        _sendingTransferInfo.progress = progress.fractionCompleted;
        if (progress.completedUnitCount == progress.totalUnitCount) {
            _sendingTransferInfo.progress = 1.0;
        }
    }
}


#pragma mark - Receiving Files

- (void)receiveFileInfo:(NSDictionary *)fileInfo {
    STFileTransferInfo *entity = [[STFileTransferInfo alloc] initWithReceiveFileInfo:fileInfo deviceInfo:_deviceInfo];
				
    if (!_prepareToReceiveFiles) {
        _prepareToReceiveFiles = [NSMutableArray array];
    }
    
    @synchronized(_prepareToReceiveFiles) {
        [_prepareToReceiveFiles addObject:entity];
    }
    [self insertTransferInfo:entity];
    [self addTransferFile:entity];

}

- (void)receiveFaildWithInfo:(STFileTransferInfo *)info {
    info.transferStatus = STFileTransferStatusReceiveFailed;
    [self updateTransferStatus:STFileTransferStatusReceiveFailed withIdentifier:info.identifier];
    
    @synchronized (_prepareToReceiveFiles) {
        [_prepareToReceiveFiles removeObject:info];
    }
}

- (void)downloadSucceedWithPath:(NSString *)downloadPath info:(STFileTransferInfo *)info {
    [self updateTransferStatus:STFileTransferStatusReceived withIdentifier:info.identifier];
    
    info.progress = 1.0f;
    info.transferStatus = STFileTransferStatusReceived;
    
    if (info.fileType == STFileTypePicture && [[NSUserDefaults standardUserDefaults] boolForKey:AutoImportPhoto]) {
        // 导入图片到系统相册
        [self writeToSavedPhotosAlbum:downloadPath isImage:YES info:info];
    }
}

- (void)writeToSavedPhotosAlbum:(NSString *)path isImage:(BOOL)isImage info:(STFileTransferInfo *)info {
    __block PHFetchResult *photosAsset;
    __block PHObjectPlaceholder *placeholder;
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    
    dispatch_block_t block = ^ {
        // Save to the album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *assetRequest = nil;
            if (isImage) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileUrl];
            } else {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
            }
            
            placeholder = [assetRequest placeholderForCreatedAsset];
            photosAsset = [PHAsset fetchAssetsInAssetCollection:toSaveCollection options:nil];
            PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:toSaveCollection
                                                                                                                          assets:photosAsset];
            [albumChangeRequest addAssets:@[placeholder]];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                info.url = placeholder.localIdentifier;
                [self updateAssetIdentifier:placeholder.localIdentifier withIdentifier:info.identifier];
                info.transferStatus = STFileTransferStatusReceived; // 触发刷新列表
                
                // 保存相册成功，删除本地缓存
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                }
            } else {
                NSLog(@"%@", error);
            }
        }];
    };
    
    [self createToSaveCollectionIfNeeded:^(PHAssetCollection *assetCollection) {
        if (!assetCollection) {
            NSLog(@"create albumn failed");
        } else {
            block();
        }
    }];
}

#pragma mark - Cancel

- (void)cancelAllTransferFile {
    [[STFileReceiveModel shareInstant] stopBroadcast];
    [[STFileTransferModel shareInstant] stopListenBroadcast];
    [[STFileTransferModel shareInstant] removeAllDevices];
    [[STWebServerModel shareInstant] stopWebServer2];
    [[STWebServerModel shareInstant] stopWebServer];
    
    @synchronized (_prepareToSendFiles) {
        [_prepareToSendFiles removeAllObjects];
    }
    [self sendFaild];
    
    @synchronized (_prepareToReceiveFiles) {
        [_prepareToReceiveFiles removeAllObjects];
    }
    
    [_session disconnect];
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

    if ([peerID.displayName isEqualToString:_deviceInfo.deviceName]) {
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
    
    if (state == MCSessionStateConnected) {
        _deviceInfo.deviceName = peerID.displayName;
        // 先互相发送头像，再认为连接成功
        [self sendHeadPortrait];
    } else {
        self.state = (STMultiPeerState)state;
    }
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    if (data.length <= 1) {
        return;
    }
    
    UInt8 flag = [STPacket getFlagWithData:data];
    NSData *bodyData = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
    if (flag == KPacketPortraitFlag) {
        UIImage *image = [[UIImage alloc] initWithData:bodyData];
        if (image) {
            NSString *headPath = [[ZZPath headImagePath] stringByAppendingFormat:@"/%@", _deviceInfo.deviceName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:headPath isDirectory:NULL]) {
                [[NSFileManager defaultManager] removeItemAtPath:headPath error:NULL];
            }
            [bodyData writeToFile:headPath atomically:YES];
            _deviceInfo.headImage = image;
            self.state = STMultiPeerStateConnected;
        }
    } else if (flag == KPacketFileInfoFlag) {
        NSDictionary *dic = [[[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding] jsonDictionary];
        if (dic.count > 0) {
            // 接收到文件
            [self receiveFileInfo:dic];
        }
    }
    
    
}

// MCSession delegate callback when we start to receive a resource from a peer in a given session
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Start receiving resource [%@] from peer %@ with progress [%@]", resourceName, peerID.displayName, progress);
    
}

// MCSession delegate callback when a incoming resource transfer ends (possibly with error)
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    STFileTransferInfo *receivingInfo = nil;
    @synchronized (_prepareToReceiveFiles) {
        for (STFileTransferInfo *info in _prepareToReceiveFiles) {
            if ([resourceName containsString:info.identifier]) {
                receivingInfo = info;
                break;
            }
        }
    }
    
    if (!receivingInfo) {
        return;
    }
    
    BOOL isThumb = [resourceName hasSuffix:@"_thumb"];
    
    // If error is not nil something went wrong
    if (error)
    {
        if (!isThumb) {
            // 接收失败
            [self receiveFaildWithInfo:receivingInfo];
        }
        
        NSLog(@"Error [%@] receiving resource from peer %@ ", [error localizedDescription], peerID.displayName);
    }
    else
    {
        // No error so this is a completed transfer.  The resources is located in a temporary location and should be copied to a permenant locatation immediately.
        // Write to documents directory
        NSString *pathExtension = receivingInfo.pathExtension;
        if (pathExtension.length == 0) {
            pathExtension = receivingInfo.fileName.pathExtension;
        }
        
        if (pathExtension.length == 0) {
            pathExtension = @"unknow";
        }
        
        NSString *downloadPath = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", resourceName, pathExtension]];
        
        if (![[NSFileManager defaultManager] copyItemAtPath:[localURL path] toPath:downloadPath error:nil])
        {
            NSLog(@"Error copying resource to documents directory");
            if (!isThumb) {
                // 接收失败
                [self receiveFaildWithInfo:receivingInfo];
            }
        }
        else {
            if (isThumb) {
                receivingInfo.thumbnailProgress = 1.0f;
            } else {
                [self downloadSucceedWithPath:downloadPath info:receivingInfo];
            }
        }
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

@end
