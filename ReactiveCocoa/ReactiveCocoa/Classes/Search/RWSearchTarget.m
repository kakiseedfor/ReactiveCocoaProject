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

typedef struct Temp {
    int ttttt;
}Temp;

@implementation RWSearchTarget

+ (void)load{
    CMRWSearchViewTarget = NSStringFromClass(RWSearchTarget.class);
    CMActionShowRWSearchVC = NSStringFromSelector(@selector(pushRWSearchViewController:charTest:));
}

- (void)pushRWSearchViewController:(NSString *)title charTest:(Temp)charTest{
    RWSearchViewController *searchViewController = StoryboardWithNameAndIdentifier(@"Main", @"RWSearchViewController");
    searchViewController.navigationItem.title = title;
    [UIView.currentViewController.navigationController pushViewController:searchViewController animated:YES];
    
//    NSLog(@"%d",charTest);
}

@end
