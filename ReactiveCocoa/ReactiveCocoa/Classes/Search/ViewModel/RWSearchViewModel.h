//
//  RWSearchViewModel.h
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/16.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface RWSearchViewModel : NSObject
@property (strong, readonly, nonatomic) RACSignal *queryAccessSignal;
@property (strong, readonly, nonatomic) NSString *queryString;
@property (strong, readonly, nonatomic) NSArray *photoArray;

@end

NS_ASSUME_NONNULL_END
