//
//  CentreMediator+Search.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/20.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "CentreMediator+Search.h"

extern NSString * CMRWSearchViewTarget;
extern NSString * CMActionShowRWSearchVC;

@implementation CentreMediator (Search)

- (void)CM_PushRWSearchViewController{
    [self openFromNative:CMRWSearchViewTarget action:CMActionShowRWSearchVC, @"Search ViewController", nil];
}

@end
