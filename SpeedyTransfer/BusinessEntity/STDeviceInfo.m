//
//  STDeviceInfo.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/17.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import "STDeviceInfo.h"

@implementation STDeviceInfo

HT_DEF_SINGLETON(STDeviceInfo, shareInstant);

- (BOOL)setup {
    if (self.ip.length > 0 && self.port > 0) {
        // 访问api总接口
        NSString *apiUrl = [NSString stringWithFormat:@"http://%@:%@/api", self.ip, @(self.port)];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiUrl]];
        request.timeoutInterval = 3.0f;
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (error || dataString.length == 0) {
            NSLog(@"apiUrl: %@, error: %@", apiUrl, error);
            return NO;
        }
        
        NSDictionary *apiInfo = [dataString jsonDictionary];
        
        // 访问dev_info接口
        NSDictionary *devInfo = [apiInfo dictionaryForKey:@"dev_info"];
        NSString *devInfoUrl = [devInfo stringForKey:@"href"];
        if (devInfoUrl.length > 0) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:devInfoUrl]];
            request.timeoutInterval = 3.0f;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (error || dataString.length == 0) {
                NSLog(@"devInfoUrl: %@, error: %@", devInfoUrl, error);
                return NO;
            } else {
                NSDictionary *devInfo = [dataString jsonDictionary];
                self.deviceId = [devInfo stringForKey:@"device_id"];
                self.deviceName = [devInfo stringForKey:@"device_name"];
            }
            
        } else {
            return NO;
        }
        
        // 访问设备头像
        NSDictionary *portraitInfo = [apiInfo dictionaryForKey:@"portrait"];
        NSString *portraitUrl = [portraitInfo stringForKey:@"href"];
        if (portraitUrl.length > 0) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:portraitUrl]];
            request.timeoutInterval = 3.0f;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (error || !image) {
                NSLog(@"devInfoUrl: %@, error: %@", devInfoUrl, error);
                return NO;
            } else {
                NSString *headPath = [[ZZPath headImagePath] stringByAppendingFormat:@"/%@", self.deviceId];
                if ([[NSFileManager defaultManager] fileExistsAtPath:headPath isDirectory:NULL]) {
                    [[NSFileManager defaultManager] removeItemAtPath:headPath error:NULL];
                }
                [data writeToFile:headPath atomically:YES];
                self.headImage = image;
            }
        } else {
            return NO;
        }
        
        //
        NSDictionary *recvInfo = [apiInfo dictionaryForKey:@"recv"];
        NSString *recvUrl = [recvInfo stringForKey:@"href"];
        self.recvUrl = recvUrl;

        return YES;
    }
    
    return NO;
}

- (NSString *)_tableName {
	return @"STDeviceInfo";
}

- (NSString *)_deviceId {
	return @"DeviceId";
}

- (NSString *)_deviceName {
	return @"DeviceName";
}

@end
