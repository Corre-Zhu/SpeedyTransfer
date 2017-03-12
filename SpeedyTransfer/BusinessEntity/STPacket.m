//
//  STPacket.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/3/5.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import "STPacket.h"

@implementation STPacket

+ (NSData *)initWithHeadPortrait:(UIImage *)image {
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&KPacketPortraitFlag length:1];
    [data appendData:UIImageJPEGRepresentation(image, 1.0)];
    
    return data;
}

+ (NSData *)initWithFileInfo:(NSDictionary *)fileInfo {
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&KPacketFileInfoFlag length:1];
    [data appendData:[[fileInfo jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
}

+ (NSData *)initWithVcard:(NSData *)vcard recordId:(NSInteger)recordId {
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&KPacketVCardFlag length:1];
    [data appendBytes:&recordId length:2];
    [data appendData:vcard];
    
    return data;
}

+ (UInt8)getFlagWithData:(NSData *)data {
    UInt8 flag = 0;
    if (data.length > 1) {
        [data getBytes:&flag length:1];
    }
    
    return flag;
}

@end
