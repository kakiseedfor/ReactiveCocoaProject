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

typedef struct Temp {
    int ttttt;
}Temp;

@implementation CentreMediator (Search)

- (void)CM_PushRWSearchViewController{
    Temp ttt = {10086};
    [self openFromNative:CMRWSearchViewTarget action:CMActionShowRWSearchVC, @"OFFlickr Search",ttt, nil];
}

@end
