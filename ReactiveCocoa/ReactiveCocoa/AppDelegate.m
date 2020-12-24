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
@property (nonatomic, strong) dispatch_source_t dispatchTimer;

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
#if TARGET_IPHONE_SIMULATOR
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            if (!(application.backgroundTimeRemaining < CGFLOAT_MAX)) {
                if (self.taskIdentifier) {
                    continue;
                }else{
                    NSLog(@"the app don't requests additional background execution time!");
                    break;
                }
            }
#endif
            if (!self.dispatchTimer) {
                dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
                dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 0);
                dispatch_source_set_event_handler(timer, ^{
                    if (!((NSInteger)application.backgroundTimeRemaining > 0)) {
                        NSLog(@"%@",[NSString stringWithFormat:@"the app’s remaining background time does reach %f",application.backgroundTimeRemaining]);
                        [NSNotificationCenter.defaultCenter postNotificationName:UIApplicationBackgroundTimeDidRunningOut object:application];
                        dispatch_suspend(timer);
                        return;
                    }
                    
                    NSLog(@"the app’s remaining background time %f",application.backgroundTimeRemaining);
                });
                self.dispatchTimer = timer;
            }
            dispatch_resume(self.dispatchTimer);
#if TARGET_IPHONE_SIMULATOR
            break;
        }
    });
#endif
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    !_dispatchTimer ?: dispatch_suspend(_dispatchTimer);
}


- (void)applicationEndBackgroundTask:(UIApplication *)application{
    if (!_taskIdentifier) {
        return;
    }
    
    [application endBackgroundTask:_taskIdentifier];
    _taskIdentifier = 0;
    _dispatchTimer = nil;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self applicationEndBackgroundTask:application];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
