//
//  CentreMediator.h
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/20.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteBlock) (void);

NS_ASSUME_NONNULL_BEGIN

@interface CentreMediator : NSObject

+ (instancetype)shareCentreMediator;

- (void)openFromRemote:(NSURL *)url completeBlock:(CompleteBlock)completeBlock;

- (void)openFromNative:(NSString *)target
                action:(NSString *)action, ... __attribute__((sentinel));

- (void)openFromNative:(NSString *)target
                action:(NSString *)action
         completeBlock:(CompleteBlock)completeBlock, ... __attribute__((sentinel));

@end

NS_ASSUME_NONNULL_END
