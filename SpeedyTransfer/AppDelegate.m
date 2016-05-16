//
//  AppDelegate.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/11/28.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "AppDelegate.h"
#import "STHomeViewController.h"
#import "HTFMDatabase.h"
#import <FMDatabaseAdditions.h>
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

NSString * const dbName = @"FileTransfer.sqlite";

@interface AppDelegate ()
{
    UIWindow *startingWindow;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@", [ZZPath documentPath]);
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{AutoImportPhoto: @YES, AutoImportVideo: @YES, HeadImage: @"龙", HeadImage_: @"head5"}];
    
    STHomeViewController *vc = [[STHomeViewController alloc] init];
    ZZNavigationController *nav = [[ZZNavigationController alloc] initWithRootViewController:vc];
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.rootViewController = nav;
    self.window = window;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UINavigationBar appearance] setBarTintColor:RGBFromHex(0xeb694a)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],NSForegroundColorAttributeName,
                                                          [UIFont boldSystemFontOfSize:17.0f],NSFontAttributeName,nil]];
    
    [[UITabBar appearance] setTintColor:RGBFromHex(0xeb694a)];
    [self setupStartingView];
    [self setupDatabase];
    [WXApi registerApp:KWeChatAppId];
    [[TencentOAuth alloc] initWithAppId:KQQAppId andDelegate:nil]; //注册
    
    return YES;
}

- (void)setupStartingView {
    int height = [[UIScreen mainScreen] currentMode].size.height;
    if (height == 2001) {
        height = 1334;
    }
    UIImage *startingImage = [UIImage imageNamed:[NSString stringWithFormat:@"%dh", height]];
    if (startingImage) {
        startingWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        startingWindow.windowLevel = UIWindowLevelStatusBar + 1;
        startingWindow.backgroundColor = [UIColor colorWithPatternImage:startingImage];
        startingWindow.hidden = NO;
        
        UIViewController *rootViewController = [[UIViewController alloc] init];
        startingWindow.rootViewController = rootViewController;
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, IPHONE_HEIGHT - 180.0f, IPHONE_WIDTH, 44.0f)];
        label1.text = NSLocalizedString(@"点传", nil);
        label1.textColor = [UIColor whiteColor];
        label1.font = [UIFont systemFontOfSize:36.0f];
        label1.textAlignment = NSTextAlignmentCenter;
        [startingWindow addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, IPHONE_HEIGHT - 119.0f, IPHONE_WIDTH, 25.0f)];
        label2.text = NSLocalizedString(@"随时随地，极速互传", nil);
        label2.textColor = RGBFromHex(0xfbeeed);
        label2.font = [UIFont systemFontOfSize:20.0f];
        label2.textAlignment = NSTextAlignmentCenter;
        [startingWindow addSubview:label2];
        
        [self performSelector:@selector(dismissStartingView) withObject:nil afterDelay:3.0f];
    }
}

- (void)dismissStartingView {
    [UIView animateWithDuration:0.3f animations:^{
        startingWindow.alpha = 0.1f;
    } completion:^(BOOL finished) {
        startingWindow.hidden = YES;
        startingWindow = nil;
    }];
}

- (void)setupDatabase {
    NSString *defaultDbPath = [[ZZPath documentPath] stringByAppendingPathComponent:dbName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:defaultDbPath]) {
        HTFMDatabase *defaultDatabase = [[HTFMDatabase alloc] initWithPath:defaultDbPath];
        BOOL result = [self createDefaultTable:defaultDatabase];
        if (result) {
            if ([defaultDatabase open]) {
                [defaultDatabase setUserVersion:1];
                [defaultDatabase close];
            }
        }
    } else {
        HTFMDatabase *defaultDatabase = [[HTFMDatabase alloc] initWithPath:defaultDbPath];
        BOOL databaseCreated = YES;
        if ([defaultDatabase open]) {
            int version = [defaultDatabase userVersion];
            if (version != 1) {
                databaseCreated = NO;
            }
        } else {
            databaseCreated = NO;
        }
        
        if (!databaseCreated) {
            [[NSFileManager defaultManager] removeItemAtPath:defaultDbPath error:nil];
            [self setupDatabase];
        }
        
    }
}

- (BOOL)createDefaultTable:(HTFMDatabase *)database
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"defaultSql" ofType:@"sql"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *sqls = [string componentsSeparatedByString:@";"];
    
    BOOL succeed = NO;
    int tryTimes = 3;
    do {
        if ([database open]) {
            [database beginTransaction];
            
            succeed = YES;
            
            for (NSString *sql in sqls) {
                NSString *trimSql = [sql trim];
                if ([trimSql length] > 0) {
                    succeed = succeed && [database executeUpdate:trimSql];
                    if (!succeed) break;
                }
            }
            if (succeed) {
                succeed = succeed && [database commit];
            }
            else{
                NSLog(@"create table error : %d \"%@\"",[database lastErrorCode], [database lastErrorMessage]);
                [database rollback];
            }
            [database close];
        }
        tryTimes--;
    } while (!succeed && tryTimes > 0);
    
    return succeed;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([WXApi handleOpenURL:url delegate:nil]) {
        return YES;
    } else {
        return [TencentOAuth HandleOpenURL:url];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([WXApi handleOpenURL:url delegate:nil]) {
        return YES;
    } else {
        return [TencentOAuth HandleOpenURL:url];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
