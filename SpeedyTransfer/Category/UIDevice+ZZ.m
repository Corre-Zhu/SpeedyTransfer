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
#include <SystemConfiguration/CaptiveNetwork.h>
#import "OpenUDID.h"
#import "HTKeychainUtil.h"

NSString *const UIStatusBarOrientationDidChangeNotification = @"UIStatusBarOrientationDidChangeNotification";

@implementation UIDevice (ZZ)

- (NSString *)serialNumber_ {
	
	static NSString *serialNumber = nil;
	
	if (!serialNumber) {
		
		// @"/System/Library/Frameworks/IOKit.framework"
		NSString *path = [NSString stringWithFormat:@"%@%@%@",@"/System/Lib",@"rary/Frameworks/IOKit",@".framework/IOKit"];
		
		void *IOKit = dlopen(path.UTF8String, RTLD_NOW);
		if (IOKit) {
			mach_port_t *kIOMasterPortDefault = dlsym(IOKit, "kIOMasterPortDefault");
			CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = dlsym(IOKit, "IOServiceMatching");
			mach_port_t (*IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching) = dlsym(IOKit, "IOServiceGetMatchingService");
			CFTypeRef (*IORegistryEntryCreateCFProperty)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = dlsym(IOKit, "IORegistryEntryCreateCFProperty");
			kern_return_t (*IOObjectRelease)(mach_port_t object) = dlsym(IOKit, "IOObjectRelease");
			
			if (kIOMasterPortDefault && IOServiceGetMatchingService && IORegistryEntryCreateCFProperty && IOObjectRelease) {
				mach_port_t platformExpertDevice = IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
				if (platformExpertDevice) {
					CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(platformExpertDevice, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
					if (platformSerialNumber != NULL) {
						if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID()) {
							serialNumber = [NSString stringWithString:(__bridge NSString*)platformSerialNumber];
							CFRelease(platformSerialNumber);
						}
					}
					IOObjectRelease(platformExpertDevice);
				}
			}
			dlclose(IOKit);
		}
	}
	
	return serialNumber;
}

- (NSString *)openUDID {
	
	static NSString *openUDID = nil;
	
	openUDID = [HTKeychainUtil openUDID];
	
	if (openUDID.length <= 0) {
		
		openUDID = [[self serialNumber_] md5String];
		
		if (openUDID.length <= 0) {
			openUDID = [OpenUDID value];
		}
		
		if (openUDID.length <= 0) {
			openUDID = [[[[NSUUID UUID] UUIDString] lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
		}
		
		if (openUDID.length <= 0) {
			NSMutableString *string = [NSMutableString string];
			
			for (int i=0; i<32; i++) {
				[string appendString:[NSString stringWithFormat:@"%c", arc4random_uniform(26) + 'a']];
			}
			openUDID = string;
		}
		
		[HTKeychainUtil setOpenUDID:openUDID];
		
	}
    
    if (openUDID.length == 0) {
        NSLog(@"get open udid error");
        openUDID = [NSString uniqueID];
    }
	
	return openUDID;
	
}

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

- (BOOL)isIOS10 {
    static BOOL isIOS10;
    
    GCDExecOnce(^{
        isIOS10 = ([self majorVersion] >= 10);
    });
    
    return isIOS10;
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

+ (NSString *)getWifiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

+ (NSString *)getBroadcastAddress {
	NSString *address = nil;
	
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	success = getifaddrs(&interfaces);
    if (success == 0) {
		temp_addr = interfaces;
        while(temp_addr != NULL) {
			if(temp_addr->ifa_addr->sa_family == AF_INET) {
				// Check if interface is en0 which is the wifi connection on the iPhone
                NSString *ifa_name = [NSString stringWithUTF8String:temp_addr->ifa_name];
				if([ifa_name isEqualToString:@"en0"] ||
                   [ifa_name hasPrefix:@"bridge"]) {
					 NSString *temp = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
					if (temp.length > 0 && ![temp hasPrefix:@"127.0"]) {
						address = temp;
						break;
					}
                }
			}
			temp_addr = temp_addr->ifa_next;
		}
	}
	
	// Free memory
	freeifaddrs(interfaces);
	
	return address;
}

// Get All ipv4 interface
+ (NSDictionary *)getAllIpAddresses {
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    @try {
        NSInteger success = getifaddrs(&interfaces);
        if (success == 0) {
            temp_addr = interfaces;
            while(temp_addr != NULL) {
                if(temp_addr->ifa_addr->sa_family == AF_INET) {
                    NSString* ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                    NSString* address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                    [resultDic setObject:address forKey:ifaName];
                    
                }
                temp_addr = temp_addr->ifa_next;
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
        // Free memory
        freeifaddrs(interfaces);
    }
    
    return resultDic;
}

// 个人热点是否启用
+ (BOOL)isPersonalHotspotEnabled {
    NSDictionary *dic = [self getAllIpAddresses];
    for (NSString *name in dic.allKeys) {
        if ([name hasPrefix:@"bridge"] || [[dic objectForKey:name] hasPrefix:@"172.20.10."]) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSString *)hotspotAddress {
    NSDictionary *dic = [self getAllIpAddresses];
    for (NSString *name in dic.allKeys) {
        if ([name hasPrefix:@"bridge"]) {
            return [dic objectForKey:name];
        }
    }
    
    return nil;
}

+ (BOOL)isWiFiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

@end
