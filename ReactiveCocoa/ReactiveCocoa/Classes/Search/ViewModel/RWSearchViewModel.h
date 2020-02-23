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
@property (strong, readonly, nonatomic) NSString *queryString;
@property (strong, readonly, nonatomic) NSArray *photoArray;
@property (strong, nonatomic) id<RACSubscriber> tempSubscriber;

- (RACSignal *)queryToOFFlickrWithText;

@end

NS_ASSUME_NONNULL_END
