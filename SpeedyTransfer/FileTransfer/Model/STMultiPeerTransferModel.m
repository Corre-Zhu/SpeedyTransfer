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
#import "STContactInfo.h"

static NSString *STServiceType = @"STServiceZZ";

@interface STMultiPeerTransferModel ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate> {
    NSTimer *connectingTimer;
}

@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;

@property (nonatomic, strong) NSMutableArray *prepareToSendFiles; // 准备要发送的文件
@property (nonatomic, strong) STFileTransferInfo *sendingTransferInfo; // 正在发送的文件
@property (nonatomic, strong) id sendingItem; // 正在发送的文件

// 文件接收
@property (nonatomic, strong) NSMutableArray *prepareToReceiveFiles; // 收到的的所有文件
@property (nonatomic) ABAddressBookRef addressBook;

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
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice name]];
        _session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
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
    
    [self fireConnectingTimer];
}

- (void)reset {
    [_advertiser stopAdvertisingPeer];
    [_browser stopBrowsingForPeers];
    [_session disconnect];
    [self invalidConnectingTimer];
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
        
        // Send step 1、写数据库
        _sendingTransferInfo = [self insertItemsToDbWithFileInfo:fileInfo];
        _sendingTransferInfo.fileInfo = fileInfo;
        
        // Send step 2、询问对方能否接收
        if (![self sendData:[STPacket initWithCanReceiveRequest]]) {
            [self sendFaild];
        }
        
    }];
    
}

- (void)doSend {
    // Send step 4、发送info
    NSDictionary *fileInfo = _sendingTransferInfo.fileInfo;
    if ([self sendData:[STPacket initWithFileInfo:fileInfo]]) {
        if ([_sendingItem isKindOfClass:[PHAsset class]]) {
            PHAsset *asset = (PHAsset *)_sendingItem;
            // Send step 5、发送大图
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
                        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                        }
                        
                        if ([imageData writeToFile:path atomically:YES]) {
                            [self sendImage:[NSURL fileURLWithPath:path]];
                            return;
                        }
                    }
                    
                    [self sendFaild];
                    
                }];
            }
        } else if ([_sendingItem isKindOfClass:[STContactInfo class]]) {
            NSInteger recordId = [fileInfo integerForKey:RECORD_ID];
            if (!self.addressBook) {
                self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            }
            ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(self.addressBook, (ABRecordID)recordId);
            CFArrayRef cfArrayRef =  (__bridge CFArrayRef)@[(__bridge id)recordRef];
            CFDataRef vcards = (CFDataRef)ABPersonCreateVCardRepresentationWithPeople(cfArrayRef);
            
            //NSString *sttt = [[NSString alloc] initWithData:(__bridge NSData *)vcards encoding:NSUTF8StringEncoding];
            
            NSData *vcardData = [STPacket initWithVcard:(__bridge NSData *)vcards recordId:recordId];
            if ([self sendData:vcardData]) {
                [self sendSucceed];
            } else {
                [self sendFaild];
            }
        } else if ([_sendingItem isKindOfClass:[STFileInfo class]]) {
            STFileInfo *file = (STFileInfo *)_sendingItem;
            if (file.fileExist) {
                [self sendImage:[NSURL fileURLWithPath:file.localPath]];
            } else {
                [self sendFaild];
            }
        }
    } else {
        [self sendFaild];
    }
}

- (void)sendSucceed {
    [self updateTransferStatus:STFileTransferStatusSent withIdentifier:_sendingTransferInfo.identifier];
    self.sendingTransferInfo.progress = 1.0;
    self.sendingTransferInfo.transferStatus = STFileTransferStatusSent;
    self.sendingItem = nil;
    self.sendingTransferInfo = nil;
    [self startSend];
}

- (void)sendFaild {
    if (_sendingTransferInfo) {
        _sendingTransferInfo.transferStatus = STFileTransferStatusSendFailed;
        [self updateTransferStatus:STFileTransferStatusSendFailed withIdentifier:_sendingTransferInfo.identifier];
    }
    
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
    
    NSLog(@"start send imageUrl: %@", imageUrl);
        
    MCPeerID *connectedPeerId = _session.connectedPeers.firstObject;
    // Send the resource to the remote peer.  The completion handler block will be called at the end of sending or if any errors occur
    NSProgress *progress = [self.session sendResourceAtURL:imageUrl withName:[imageUrl lastPathComponent] toPeer:connectedPeerId withCompletionHandler:^(NSError *error) {
        // Implement this block to know when the sending resource transfer completes and if there is an error.
        if (error) {
            NSLog(@"Send resource to peer [%@] completed with Error [%@]", connectedPeerId.displayName, error);
            [weakSelf sendFaild];
        } else {
            [weakSelf sendSucceed];
        }
    }];
    
    _sendingTransferInfo.nsprogress = progress;
}

- (BOOL)sendHeadPortrait {
    UIImage *headPortrait = nil;
    
    NSString *headImage = [[NSUserDefaults standardUserDefaults] stringForKey:HeadImage];
    if ([headImage isEqualToString:CustomHeadImage]) {
        headPortrait = [[UIImage alloc] initWithContentsOfFile:[[ZZPath documentPath] stringByAppendingPathComponent:CustomHeadImage]];
    } else {
        headPortrait = [UIImage imageNamed:headImage];
    }
    
    if (headPortrait) {
        return [self sendData:[STPacket initWithHeadPortrait:headPortrait]];
    }
    
    return NO;

}

- (STFileTransferInfo *)insertItemsToDbWithFileInfo:(NSDictionary *)fileInfo {
    STFileTransferInfo *entity = [[STFileTransferInfo alloc] init];
    entity.identifier = [fileInfo stringForKey:FILE_IDENTIFIER];
    entity.transferType = STFileTransferTypeSend;
    entity.transferStatus = STFileTransferStatusSending;
    entity.fileName = [fileInfo stringForKey:FILE_NAME];
    entity.dateString = [[NSDate date] dateString];
    entity.fileSize = [fileInfo doubleForKey:FILE_SIZE_IOS];
    
    NSString *fileUrl = [fileInfo stringForKey:FILE_URL];
    if ([fileUrl containsString:@"/image"]) {
        entity.fileType = STFileTypePicture;
        entity.url = [fileInfo stringForKey:ASSET_ID];
    } else if ([fileUrl containsString:@"/contact"]) {
        entity.fileType = STFileTypeContact;
        entity.url = @([fileInfo integerForKey:RECORD_ID]).stringValue;
        entity.recordId = [fileInfo integerForKey:RECORD_ID];
    } else if ([fileUrl containsString:@"/music"]) {
        entity.fileType = STFileTypeMusic;
        entity.url = @([fileInfo longLongForKey:RECORD_ID]).stringValue;
    } else if ([fileUrl containsString:@"/myfile"]) {
        entity.fileType = STFileTypeOther;
    }
    
    entity.deviceName = _deviceInfo.deviceName;
   // entity.headImage = deviceInfo.headImage;
    
    [self insertTransferInfo:entity];
    [self addTransferFile:entity];
    
    return entity;
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
    info.progress = 1.0f;
    info.transferStatus = STFileTransferStatusReceived;
    [self updateTransferStatus:STFileTransferStatusReceived withIdentifier:info.identifier];
    @synchronized (_prepareToReceiveFiles) {
        [_prepareToReceiveFiles removeObject:info];
    }
    
    if (info.fileType == STFileTypePicture && [[NSUserDefaults standardUserDefaults] boolForKey:AutoImportPhoto]) {
        // 导入图片到系统相册
        [self writeToSavedPhotosAlbum:downloadPath isImage:YES info:info];
    } else if (info.fileType == STFileTypeVideo && [[NSUserDefaults standardUserDefaults] boolForKey:AutoImportVideo]) {
        // 导入视频到系统相册
        [self writeToSavedPhotosAlbum:downloadPath isImage:NO info:info];
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
                NSLog(@"writeToSavedPhotosAlbum failed, %@, %@", info.identifier, error);
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
    [self reset];
    
    @synchronized (_prepareToSendFiles) {
        [_prepareToSendFiles removeAllObjects];
    }
    [self sendFaild];
    
    @synchronized (_prepareToReceiveFiles) {
        [_prepareToReceiveFiles removeAllObjects];
    }
}

// 取消所有发送
- (void)cancelAllSendFile {
    @synchronized (_prepareToSendFiles) {
        [_prepareToSendFiles removeAllObjects];
    }
    [self sendFaild];
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

#pragma mark - Timer

- (void)fireConnectingTimer {
    [self invalidConnectingTimer];
    
    connectingTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(connectingTimeout) userInfo:nil repeats:NO];
}

- (void)invalidConnectingTimer {
    if (connectingTimer) {
        [connectingTimer invalidate];
        connectingTimer = nil;
    }
}

- (void)connectingTimeout {
    if (self.state == STMultiPeerStateBrowsing ||
        self.state == STMultiPeerStateConnecting) {
        self.state = STMultiPeerStateTimeout;
    }
}

#pragma mark - MCSessionDelegate methods

// Override this method to handle changes to peer session state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);
    
    if (state == MCSessionStateConnected) {
        _deviceInfo.deviceName = peerID.displayName;
        [self sendHeadPortrait];
    }
    
    self.state = (STMultiPeerState)state;
    if (state != MCSessionStateConnecting) {
        [self invalidConnectingTimer];
    }
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    if (data.length == 0) {
        return;
    }
    
    UInt8 flag = [STPacket getFlagWithData:data];
    NSData *bodyData = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
    
    if (flag == KPacketCanReceiveRequestFlag) {
        [self sendData:[STPacket initWithCanReceiveResponse:[self shouldReceiveFile]]];
    } else if (flag == KPacketCanReceiveResponseFlag) {
        if (bodyData.length == 0) {
            return;
        }
        
        UInt8 canReceive = 1;
        [bodyData getBytes:&canReceive length:1];
        
        if (canReceive) {
            // Send step 3、对方能接收
            [self doSend];
        } else {
            // 对方不能接收
            [self cancelAllSendFile];
        }
    } else if (flag == KPacketPortraitFlag) {
        UIImage *image = [[UIImage alloc] initWithData:bodyData];
        if (image) {
            NSString *headPath = [[ZZPath headImagePath] stringByAppendingFormat:@"/%@", _deviceInfo.deviceName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:headPath isDirectory:NULL]) {
                [[NSFileManager defaultManager] removeItemAtPath:headPath error:NULL];
            }
            [bodyData writeToFile:headPath atomically:YES];
            _deviceInfo.headImage = image;
        }
    }
    
    if (![self shouldReceiveFile]) {
        // 容量不足不接收文件
        return;
    }
    
    if (flag == KPacketFileInfoFlag) {
        NSDictionary *dic = [[[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding] jsonDictionary];
        if (dic.count > 0) {
            // 接收到文件
            [self receiveFileInfo:dic];
        }
    } else if (flag == KPacketVCardFlag) {
        if (bodyData.length < 3) {
            return;
        }
        
        UInt16 recordId = 0;
        [bodyData getBytes:&recordId length:2];
        bodyData = [bodyData subdataWithRange:NSMakeRange(2, bodyData.length - 2)];
        
        ABAddressBookRef book = ABAddressBookCreate();
        ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
        CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, (__bridge CFDataRef)bodyData);
        if (CFArrayGetCount(vCardPeople) > 0) {
            STFileTransferInfo *receivingInfo = nil;
            @synchronized (_prepareToReceiveFiles) {
                for (STFileTransferInfo *info in _prepareToReceiveFiles) {
                    if (info.fileType == STFileTypeContact && info.recordId == recordId) {
                        receivingInfo = info;
                        break;
                    }
                }
            }
            
            if (!receivingInfo) {
                return;
            }
            
            ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, 0);
            ABAddressBookAddRecord(book, person, NULL);
            ABAddressBookSave(book, NULL);
            
            NSString *path = [[ZZPath downloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.vcard", receivingInfo.identifier]];
            if (![bodyData writeToFile:path atomically:YES]) {
                NSLog(@"vcard write file error");
            }
            
            receivingInfo.progress = 1.0f;
            receivingInfo.transferStatus = STFileTransferStatusReceived;
            [self updateTransferStatus:STFileTransferStatusReceived withIdentifier:receivingInfo.identifier];
            @synchronized (_prepareToReceiveFiles) {
                [_prepareToReceiveFiles removeObject:receivingInfo];
            }
        }
        
    }
    
    
}

// MCSession delegate callback when we start to receive a resource from a peer in a given session
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Start receiving resource [%@] from peer %@ with progress [%@]", resourceName, peerID.displayName, progress);
    
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
    
    receivingInfo.nsprogress = progress;
}

// MCSession delegate callback when a incoming resource transfer ends (possibly with error)
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"Finish receiving resource [%@] from peer %@ error: %@", resourceName, peerID.displayName, error);

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
    
    // If error is not nil something went wrong
    if (error)
    {
        // 接收失败
        [self receiveFaildWithInfo:receivingInfo];
        NSLog(@"Error [%@] receiving resource from peer %@ ", [error localizedDescription], peerID.displayName);
    }
    else
    {
        // No error so this is a completed transfer.  The resources is located in a temporary location and should be copied to a permenant locatation immediately.
        // Write to documents directory
        NSString *pathExtension = receivingInfo.pathExtension;
        NSString *fileName = resourceName;
        if (fileName.pathExtension.length == 0 && pathExtension.length > 0) {
            fileName = [NSString stringWithFormat:@"%@.%@", fileName, pathExtension];
        }
        
        NSString *downloadPath = [[ZZPath downloadPath] stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
            // 之前接收过同样的文件
            [self downloadSucceedWithPath:downloadPath info:receivingInfo];
        } else {
            if (![[NSFileManager defaultManager] copyItemAtPath:[localURL path] toPath:downloadPath error:nil])
            {
                NSLog(@"Error copying resource to documents directory");
                // 接收失败
                [self receiveFaildWithInfo:receivingInfo];
            }
            else {
                [self downloadSucceedWithPath:downloadPath info:receivingInfo];
            }
        }
        
        
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

@end
