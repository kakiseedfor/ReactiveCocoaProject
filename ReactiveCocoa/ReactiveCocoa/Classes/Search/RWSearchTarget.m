//
//  RWSearchTarget.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/20.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "RWSearchViewController.h"
#import "RWSearchTarget.h"

NSString * CMRWSearchViewTarget = @"";
NSString * CMActionShowRWSearchVC = @"";

@implementation RWSearchTarget

+ (void)load{
    CMRWSearchViewTarget = NSStringFromClass(RWSearchTarget.class);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    CMActionShowRWSearchVC = NSStringFromSelector(@selector(pushRWSearchViewController:));
#pragma clang diagnostic pop
}

- (void)pushRWSearchViewController:(NSString *)title{
    RWSearchViewController *searchViewController = StoryboardWithNameAndIdentifier(@"Main", @"RWSearchViewController");
    searchViewController.navigationItem.title = title;
    [UIView.currentViewController.navigationController pushViewController:searchViewController animated:YES];
}

@end
