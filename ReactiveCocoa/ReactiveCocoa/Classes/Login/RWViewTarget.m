//
//  RWViewTarget.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/20.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "RWViewController.h"
#import "RWViewTarget.h"

NSString * CMRWViewTarget = @"";
NSString * CMActionShowRWVC = @"";

@implementation RWViewTarget

+ (void)load{
    CMRWViewTarget = NSStringFromClass(RWViewTarget.class);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    CMActionShowRWVC = NSStringFromSelector(@selector(pushRWViewController));
#pragma clang diagnostic pop
}

- (void)pushRWViewController{
    RWViewController *rwViewController = StoryboardWithNameAndIdentifier(@"Main", @"RWViewController");
    [UIView.currentViewController.navigationController pushViewController:rwViewController animated:YES];
}

@end
