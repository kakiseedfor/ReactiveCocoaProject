//
//  RWSearchModel.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/19.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "RWSearchModel.h"

@interface RWSearchModel ()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *identifier;

@end

@implementation RWSearchModel

- (instancetype)initWith:(NSDictionary *)dataDic flickrContext:(OFFlickrAPIContext *)flickrContext
{
    self = [super init];
    if (self) {
        @weakify(self);
        _imageSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            if (!self.imageData) {
                self.imageData = [NSData dataWithContentsOfURL:self.url];
            }
            
            [subscriber sendNext:self.imageData];
            [subscriber sendCompleted];
            return nil;
        }] subscribeOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
        
        _identifier = dataDic[@"id"];
        _title = dataDic[@"title"];
        _url = [flickrContext photoSourceURLFromDictionary:dataDic size:OFFlickrSmallSize];
    }
    return self;
}

@end
