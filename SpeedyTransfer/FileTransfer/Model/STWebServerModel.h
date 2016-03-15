//
//  STWebServerModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STWebServerModel : NSObject

- (void)startWebServer;
- (void)stopWebServer;

- (void)startWebServer2; // 无界传输
- (void)stopWebServer2;

@end
