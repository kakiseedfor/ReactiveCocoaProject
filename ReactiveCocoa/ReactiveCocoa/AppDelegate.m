//
//  AppDelegate.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/22.
//  Copyright © 2020年 kakiYen. All rights reserved.
//

#import "AppDelegate.h"

NSNotificationName const UIApplicationBackgroundTimeWillBeRunningOut = @"UIApplicationBackgroundTimeWillBeRunningOut";
NSNotificationName const UIApplicationBackgroundTimeDidRunningOut = @"UIApplicationBackgroundTimeDidRunningOut";

@interface AppDelegate ()
@property (nonatomic) UIBackgroundTaskIdentifier taskIdentifier;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    _taskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationBackgroundTimeWillBeRunningOut object:application];
        [self applicationEndBackgroundTask:application];
        NSLog(@"the app’s remaining background time will be running out!");
    }];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    dispatch_async(dispatch_queue_create("additional.background.execution", DISPATCH_QUEUE_SERIAL), ^{
        NSString *prompt = @"";
        while (YES) {
            if (!(application.backgroundTimeRemaining < CGFLOAT_MAX)) {
                if (self.taskIdentifier) {
                    continue;
                }else{
                    prompt = @"the app don't requests additional background execution time!";
                    break;
                }
            }
            
            if (!(application.backgroundTimeRemaining > 0.f)) {
                [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationBackgroundTimeDidRunningOut object:application];
                prompt = [NSString stringWithFormat:@"the app’s remaining background time does reach %f",application.backgroundTimeRemaining];
                break;
            }
            
            NSLog(@"the app’s remaining background time %f",application.backgroundTimeRemaining);
            sleep(3);
        }
        NSLog(@"%@",prompt);
        
        [self applicationEndBackgroundTask:application];
    });
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationEndBackgroundTask:(UIApplication *)application{
    if (!_taskIdentifier) {
        return;
    }
    
    [application endBackgroundTask:_taskIdentifier];
    _taskIdentifier = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self applicationEndBackgroundTask:application];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
