//
//  ZZCategory.h
//
//
//  Created by ZZ.
//
//

#import "UIDevice+ZZ.h"
#include <mach/mach.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <ifaddrs.h>
#include <mach/mach_host.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <dlfcn.h>
#include <sys/param.h>
#include <sys/mount.h>

NSString *const UIStatusBarOrientationDidChangeNotification = @"UIStatusBarOrientationDidChangeNotification";

@implementation UIDevice (ZZ)

- (NSString *)devicePlatform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (BOOL)isPhone {
    return [[self devicePlatform] hasPrefix:@"iPhone"];
}

- (BOOL)isPod {
    return [[self devicePlatform] hasPrefix:@"iPod"];
}

- (BOOL)isPad {
    return [self userInterfaceIdiom] == UIUserInterfaceIdiomPad ? YES : NO;
}

- (NSInteger)majorVersion {
    NSString *majorVersion = [[self.systemVersion componentsSeparatedByString:@"."] objectAtIndex:0];
    NSInteger result = majorVersion.integerValue;
    return result;
}

- (BOOL)isIOS6 {
    static BOOL isIOS6;
    
    GCDExecOnce(^{
        isIOS6 = ([self majorVersion] >= 6 && [self majorVersion] < 7);
    });
    
    return isIOS6;
}

- (BOOL)isIOS7 {
    
    static BOOL isIOS7;
    
    GCDExecOnce(^{
        isIOS7 = ([self majorVersion] >= 7);
    });
    
    return isIOS7;
}

- (BOOL)isIOS8 {
    static BOOL isIOS8;
    
    GCDExecOnce(^{
        isIOS8 = ([self majorVersion] >= 8);
    });
    
    return isIOS8;
}

- (BOOL)isIOS9 {
	static BOOL isIOS9;
	
	GCDExecOnce(^{
		isIOS9 = ([self majorVersion] >= 9);
	});
	
	return isIOS9;
}

- (float)screenWidth {
    
    if (IOS8) {
        return [UIScreen mainScreen].bounds.size.width;
    }
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIScreen mainScreen].bounds.size.height;
    }
//    if (UIInterfaceOrientationIsLandscape(self.orientation)) {
//        return IPHONE_HEIGHT;
//    }
    
    return [UIScreen mainScreen].bounds.size.width;
}

- (float)screenHeight {
    
    if (IOS8) {
        return [UIScreen mainScreen].bounds.size.height;
    }
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIScreen mainScreen].bounds.size.width;
    }
    
//    if (UIInterfaceOrientationIsLandscape(self.orientation)) {
//        return IPHONE_WIDTH;
//    }
    
    return [UIScreen mainScreen].bounds.size.height;
}

- (float)statusbarWidth {
    if (IOS8) {
        return [[UIApplication sharedApplication] statusBarFrame].size.width;
    }
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    
    
    return [[UIApplication sharedApplication] statusBarFrame].size.width;
}

- (float)statusbarHeight {
    if (IOS8) {
        return [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return [[UIApplication sharedApplication] statusBarFrame].size.width;
    }
    
    
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (BOOL)isPortrait {
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}


- (BOOL)isLandscape {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}


@end
