//
//  UIView+Utility.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/21.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "UIView+Utility.h"

@implementation UIView (Utility)

+ (UIViewController *)currentViewController{
    return [UIView currentViewControllerFrom:UIApplication.sharedApplication.keyWindow.rootViewController];
}

+ (UIViewController *)currentViewControllerFrom:(UIViewController *)fromViewController{
    UIViewController *tempVC = fromViewController.presentedViewController;
    
    if (tempVC) {
        return tempVC;
    }
    
    if ([fromViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *tempNav = (UINavigationController *)fromViewController;
        return [UIView currentViewControllerFrom:tempNav.topViewController];
    }
    
    if ([fromViewController isKindOfClass:UITabBarController.class]) {
        UITabBarController *tempTabVC = (UITabBarController *)fromViewController;
        return [UIView currentViewControllerFrom:tempTabVC.selectedViewController];
    }
    
    return fromViewController;
}

@end
