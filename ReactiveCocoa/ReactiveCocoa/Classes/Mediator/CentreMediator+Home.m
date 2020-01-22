//
//  CentreMediator+Home.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/20.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "CentreMediator+Home.h"

extern NSString *const CMRWViewTarget;
extern NSString *const CMActionShowRWVC;

@implementation CentreMediator (Home)

- (void)CM_PushRWViewController{
    [self openFromNative:CMRWViewTarget action:CMActionShowRWVC, nil];
}

@end
