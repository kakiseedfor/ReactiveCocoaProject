//
//  RWDummySignInService.m
//  RWReactivePlayground
//
//  Created by Colin Eberhardt on 18/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "RWDummySignInService.h"

@implementation RWDummySignInService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _additionalCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber * _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [subscriber sendNext:input];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return self;
}

- (RACSignal *)signInWithSingal:(NSString *)username password:(NSString *)password{
    [_additionalCommand execute:@(Logining)];
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        [self signInWithUsername:username password:password complete:^(LoginState state) {
            /*
             终止信号:
             -sendCompleted、-sendError:
             */
            [subscriber sendNext:@(state)];
            [subscriber sendCompleted]; //信号完成、释放
            [self.additionalCommand execute:@(state)];
        }];
        return nil;
    }];
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(RWSignInResponse)completeBlock {

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        LoginState state = ([username isEqualToString:@"user"] && [password isEqualToString:@"password"]) ? LoginFinish : LoginFail;
        completeBlock(state);
    });
}


@end
