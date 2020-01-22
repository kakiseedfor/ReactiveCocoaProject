//
//  RWSearchModel.h
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/19.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import <objectiveflickr/ObjectiveFlickr.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

NS_ASSUME_NONNULL_BEGIN

@interface RWSearchModel : NSObject
@property (strong, readonly, nonatomic) RACSignal *imageSignal;
@property (strong, readonly, nonatomic) NSString *title;

- (instancetype)initWith:(NSDictionary *)dataDic flickrContext:(OFFlickrAPIContext *)flickrContext;

@end

NS_ASSUME_NONNULL_END
