//
//  RWDummySignInService.h
//  RWReactivePlayground
//
//  Created by Colin Eberhardt on 18/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LoginState) {
    Logining,
    LoginFail,
    LoginFinish
};

typedef void (^RWSignInResponse)(LoginState);

@interface RWDummySignInService : NSObject
@property (strong, nonatomic) RACCommand *additionalCommand;
@property (strong, nonatomic) RACSignal *signInSingal;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

- (RACSignal *)signInWithSingal:(NSString *)username password:(NSString *)password;

@end
