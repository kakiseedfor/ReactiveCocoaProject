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

@interface RWDummySignInService ()


@end

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
        
        /**
         **Note:** The `didSubscribe` block is called every time a new subscriber subscribes. Any side effects within the block will thus execute once for each subscription, not necessarily on one thread, and possibly even simultaneously!
         */
        @weakify(self);
        _signInSingal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            [self signInWithUsername:self.username password:self.password complete:^(LoginState state) {
                /*
                 终止信号:
                 -sendCompleted、-sendError:
                 */
                [subscriber sendNext:@(state)];
                [subscriber sendCompleted]; //信号完成、释放，此后订阅器再向订阅内容发送消息，只有重新向订阅器订阅新内容
                [self.additionalCommand execute:@(state)];
            }];
            return nil;
        }];
    }
    return self;
}

- (RACSignal *)signInWithSingal:(NSString *)username password:(NSString *)password{
    [_additionalCommand execute:@(Logining)];
    return _signInSingal;
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(RWSignInResponse)completeBlock
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        LoginState state = ([username isEqualToString:@"user"] && [password isEqualToString:@"password"]) ? LoginFinish : LoginFail;
        completeBlock(state);
    });
}


@end
