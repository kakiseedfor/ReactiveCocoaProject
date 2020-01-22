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
    
    for (NSUInteger i = 2; i < methodSignature.numberOfArguments; i++) {
        NSString *typeName = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i]];
        
        if ([typeName isEqualToString:@"c"]){
            char parameter = '\0';
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"i"]){
            int parameter = 0;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"s"]){
            short parameter = 0;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"l"]){
            long parameter = 0;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"q"]){
            long long parameter = 0;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"C"]){
            unsigned char parameter = 0;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"I"]){
            unsigned int parameter = 0;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"L"]){
            unsigned long parameter = 0;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"Q"]){
            unsigned long long parameter = 0;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"f"]){
            float parameter = 0.f;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"d"]){
            double parameter = 0.f;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"B"]){
            bool parameter;
            parameter = va_arg(parameters, typeof(parameter));
            [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"*"]){
            char *parameter = NULL;
            parameter = va_arg(parameters, typeof(parameter));
            !parameter ? : [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"@"]) {
            id parameter = nil;
            parameter = va_arg(parameters, id);
            !parameter ? : [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@"#"]) {
            Class parameter = NULL;
            parameter = va_arg(parameters, typeof(parameter));
            !parameter ? : [invocation setArgument:&parameter atIndex:i];
        }else if ([typeName isEqualToString:@":"]) {
            SEL parameter = NSSelectorFromString(@"");
            parameter = va_arg(parameters, typeof(parameter));
            !parameter ? : [invocation setArgument:&parameter atIndex:i];
        }else if ([self isArray:typeName] || [self isPointer:typeName]){
            void *parameter = NULL;
            parameter = va_arg(parameters, typeof(parameter));
            !parameter ? : [invocation setArgument:&parameter atIndex:i];
        }else if ([self isStructure:typeName]){
            
        }
        NSLog(@"%@",typeName);
    }
    va_end(parameters);
    [invocation invoke];
}

- (BOOL)isArray:(NSString *)typeName{
    NSString *arrayRegex = @"\\[[0-9]+[a-zA-Z]+\\]";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",arrayRegex];
    return [predicate evaluateWithObject:typeName];
}

- (BOOL)isPointer:(NSString *)typeName{
    NSString *pointerRegex = @"\\^[a-zA-Z]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pointerRegex];
    return [predicate evaluateWithObject:typeName];
}

- (BOOL)isStructure:(NSString *)typeName{
    NSString *structureRegex = @"\\{[a-zA-Z]+=[[c,i,s,l,q,C,I,S,L,Q,f,d,B,v,*,#,:]+,\\[[0-9]+[a-zA-Z]+\\]]\\}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",structureRegex];
    return [predicate evaluateWithObject:typeName];
}

@end
