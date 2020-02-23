//
//  RWSearchViewModel.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/16.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import <objectiveflickr/ObjectiveFlickr.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "RWSearchViewModel.h"
#import "RWSearchModel.h"

@interface RWSearchViewModel ()<OFFlickrAPIRequestDelegate>
@property (strong, nonatomic) OFFlickrAPIRequest *offlickrRequest;
@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;
@property (strong, nonatomic) RACReplaySubject *replaySubject;  //共享回放信号
@property (strong, nonatomic) RACSubject *racSubject;  //共享信号
@property (strong, nonatomic) NSString *queryString;

@end

@implementation RWSearchViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queryString = @"Hello";
        _photoArray = [NSMutableArray array];
        /**
         RACSubject 共享信号:
            多个订阅接受着共享一个订阅器。
         RACReplaySubject   共享回放信号:
            多少个回放数据，订阅器回放多少个。
         */
        _racSubject = RACSubject.subject;
        _replaySubject = [RACReplaySubject replaySubjectWithCapacity:1];    //回放信号中存放最近回放数据的个数
        _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:@"45a4251dc1a3c9934f8ff8da7a8216ee" sharedSecret:@"f7d45ce1c8b4bf8d"];
        _offlickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
        _offlickrRequest.delegate = self;
    }
    return self;
}

/**
 -reduceEach: Unpacks RACTuple
 */
- (RACSignal *)queryToOFFlickrWithText{
    @weakify(self);
    RACSignal *signal = [[[[[[self rac_signalForSelector:@selector(flickrAPIRequest:didCompleteWithResponse:) fromProtocol:@protocol(OFFlickrAPIRequestDelegate)] reduceEach:^id(OFFlickrAPIRequest *inRequest,NSDictionary * inResponseDictionary){
        return inResponseDictionary;
    }] map:^id(NSDictionary *dataDic) {
        @strongify(self);
        [self dealResponse:dataDic];
    }] catch:^RACSignal *(NSError *error) {
        NSLog(@"%s %@",__FUNCTION__ , error.domain);
        return RACSignal.empty;
    }] publish] autoconnect];   //publish 内部使用了共享订阅器。
    [_offlickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:self.paramDic];

    return signal;
}

//- (RACSignal *)queryToOFFlickrWithText{
//    @weakify(self);
//    [[[self rac_signalForSelector:@selector(flickrAPIRequest:didCompleteWithResponse:) fromProtocol:@protocol(OFFlickrAPIRequestDelegate)] map:^id(RACTuple *value) {
//        return value.second;
//    }] subscribeNext:^(NSDictionary *dataDic) {
//        @strongify(self);
//        [self dealResponse:dataDic];
//        [self.replaySubject sendCompleted]; //信号完成、释放，此后订阅器再向订阅内容发送消息，只有重新向订阅器订阅新内容
//    } error:^(NSError *error) {
//        NSLog(@"%s %@",__FUNCTION__ , error.domain);
//    }];
//    [_offlickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:self.paramDic];
//
//    return _replaySubject;
//}

- (void)dealResponse:(NSDictionary *)dataDic{
    NSArray *photoArray = [dataDic valueForKeyPath:@"photos.photo"];
    
    /**
     1、将数组的值序列化，转化为序列流[Pull-driven]。
     2、将信号流中的值转换为model。
     3、将序列流转换为数组的值序列化。
     
     Push-driven : 在创建信号的时候，信号不会被立即赋值，之后才会被赋值.
     Pull-driven : 在创建信号的同时序列中的值就会被确定下来，我们可以从流中一个个地查询值.
     */
    @weakify(self);
    _photoArray = [[photoArray.rac_sequence map:^id(NSDictionary *value) {
        @strongify(self);
        return [[RWSearchModel alloc] initWith:value flickrContext:self.flickrContext];
    }] array];
}

- (NSDictionary *)paramDic{
    return @{@"text" : _queryString,
             @"sort": @"interestingness-desc"};
}

@end
