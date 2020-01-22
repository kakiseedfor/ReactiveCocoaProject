//
//  RWSearchViewModel.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/16.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import <objectiveflickr/ObjectiveFlickr.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "RWSearchViewModel.h"
#import "RWSearchModel.h"

@interface RWSearchViewModel ()<OFFlickrAPIRequestDelegate>
@property (strong, nonatomic) OFFlickrAPIRequest *offlickrRequest;
@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;
@property (strong, nonatomic) NSMutableArray *requestArray;
@property (strong, nonatomic) NSString *queryString;

@end

@implementation RWSearchViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _photoArray = [NSMutableArray array];
        _requestArray = [NSMutableArray array];
        _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:@"45a4251dc1a3c9934f8ff8da7a8216ee" sharedSecret:@"f7d45ce1c8b4bf8d"];
        
        @weakify(self);
        _queryAccessSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber> _Nonnull subscriber) {
            @strongify(self);
            RACDisposable *disposable = [self subscriberDisposable:subscriber];
            
            if (self.requestArray.count) {
                [self.requestArray addObject:subscriber];
                return disposable;
            }
            
            [self.requestArray addObject:subscriber];
            [self queryToOFFlickrWithText:subscriber];
            
            return disposable;
        }];
    }
    return self;
}

- (RACDisposable *)subscriberDisposable:(id<RACSubscriber> _Nonnull)subscriber{
    @weakify(self);
    return [RACDisposable disposableWithBlock:^{
        @strongify(self);
        [self.requestArray removeObject:subscriber];
        
        if (self.requestArray.count) {
            [self queryToOFFlickrWithText:self.requestArray.firstObject];
        }
    }];
}

- (void)queryToOFFlickrWithText:(id<RACSubscriber> _Nonnull)subscriber{
    _offlickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    _offlickrRequest.delegate = self;
    
    [_offlickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:self.paramDic];
    
    @weakify(self);
    [[[self rac_signalForSelector:@selector(flickrAPIRequest:didCompleteWithResponse:) fromProtocol:@protocol(OFFlickrAPIRequestDelegate)] map:^id(RACTuple *value) {
        return value.second;
    }] subscribeNext:^(NSDictionary *dataDic) {
        @strongify(self);
        NSLog(@"%@",dataDic);
        [self dealResponse:dataDic];
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
    } error:^(NSError *error) {
        [subscriber sendError:error];
    }];
}

- (void)dealResponse:(NSDictionary *)dataDic{
    NSArray *photoArray = [dataDic valueForKeyPath:@"photos.photo"];
    @weakify(self);
    _photoArray = [photoArray linq_select:^id(NSDictionary *item) {
        @strongify(self);
        return [[RWSearchModel alloc] initWith:item flickrContext:self.flickrContext];
    }];
}

- (NSDictionary *)paramDic{
    return @{@"text" : _queryString,
             @"sort": @"interestingness-desc"};
}

@end
