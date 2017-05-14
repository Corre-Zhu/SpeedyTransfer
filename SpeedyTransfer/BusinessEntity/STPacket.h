//
//  STPacket.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/3/5.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

static UInt8 KPacketPortraitFlag =  0xF0;	//头像
static UInt8 KPacketFileInfoFlag =  0xF1;	//文件信息
static UInt8 KPacketVCardFlag =  0xF2;	//联系人

static UInt8 KPacketCanReceiveRequestFlag =  0xF3;	//询问能否接收
static UInt8 KPacketCanReceiveResponseFlag =  0xF4;	//能否接收响应

@interface STPacket : NSObject

+ (NSData *)initWithHeadPortrait:(UIImage *)image;
+ (NSData *)initWithFileInfo:(NSDictionary *)fileInfo;
+ (NSData *)initWithVcard:(NSData *)data recordId:(NSInteger)recordId;
+ (NSData *)initWithCanReceiveRequest;
+ (NSData *)initWithCanReceiveResponse:(UInt8)flag;

+ (UInt8)getFlagWithData:(NSData *)data;

@end
