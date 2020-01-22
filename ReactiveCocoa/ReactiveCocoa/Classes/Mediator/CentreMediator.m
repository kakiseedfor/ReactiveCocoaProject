//
//  CentreMediator.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/20.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "CentreMediator.h"

@interface CentreMediator ()
@property (strong, nonatomic) NSMapTable *classMapTable;

@end

@implementation CentreMediator

+ (instancetype)shareCentreMediator{
    static dispatch_once_t dispatchOnce;
    
    static CentreMediator *CM = nil;
    dispatch_once(&dispatchOnce, ^{
        CM = [[CentreMediator alloc] init];
    });
    return CM;
}

- (void)openFromRemote:(NSURL *)url completeBlock:(CompleteBlock)completeBlock{
    
}

- (void)openFromNative:(NSString *)target
                action:(NSString *)action, ... __attribute__((sentinel)){
    va_list parameters;
    va_start(parameters, action);
    [self openFromNative:target action:action vaList:parameters completeBlock:nil];
    va_end(parameters);
}

- (void)openFromNative:(NSString *)target
                action:(NSString *)action
         completeBlock:(CompleteBlock)completeBlock, ... __attribute__((sentinel))
{
    va_list parameters;
    va_start(parameters, completeBlock);
    [self openFromNative:target action:action vaList:parameters completeBlock:completeBlock];
    va_end(parameters);
}

- (void)openFromNative:(NSString *)target
                action:(NSString *)action
                vaList:(va_list)parameters
         completeBlock:(CompleteBlock)completeBlock {
    /**
     没有目标或行为的视为不可跳转
     */
    if (!target.length || !action.length) {
        NSLog(@"Invalid paramters with target or action.");
        return;
    }
    
    
    Class targetClass = NSClassFromString(target);
    id targetInstance = [[targetClass alloc] init];
    
    /**
     没有找到目标视为不可跳转
     */
    if (!targetInstance) {
        NSLog(@"There is no found target with %@",target);
        return;
    }
    
    SEL actionSelector = NSSelectorFromString(action);
    if (![targetInstance respondsToSelector:actionSelector]) {
        NSLog(@"Unrecongize selector with %@ in %@",action,target);
        return;
    }
    
    NSMethodSignature *methodSignature = [targetInstance methodSignatureForSelector:actionSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = actionSelector;
    invocation.target = targetInstance;
    
    NSUInteger count = 2;
    id parameter = nil;
    while ((parameter = va_arg(parameters, id))){
        [invocation setArgument:&parameter atIndex:count];
        count++;
    }
    va_end(parameters);
    
    [invocation invoke];
}

@end
