//
//  RWSearchViewController.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/16.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "RWSearchViewController.h"
#import "RWSearchViewModel.h"
#import "RWSearchViewCell.h"

@interface RWSearchViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *BGImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) RWSearchViewModel *viewModel;

@end

@implementation RWSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //监听文本变化信号
    RACSignal *textDidChangeSignal = [self rac_signalForSelector:@selector(searchBar:textDidChange:) fromProtocol:@protocol(UISearchBarDelegate)];
    
    RAC(self,viewModel.queryString) = [textDidChangeSignal map:^id _Nullable(RACTuple * _Nullable value) {
        return value.second;
    }];
    
    @weakify(self);
    _viewModel = [[RWSearchViewModel alloc] init];
    [_viewModel.queryToOFFlickrWithText subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [[[[textDidChangeSignal filter:^BOOL(RACTuple * _Nullable value) {
        NSString *searchText = value.second;
        return searchText.length > 3;
    }] throttle:.5f] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        @strongify(self);
        return self.viewModel.queryToOFFlickrWithText;
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    } completed:^{
        NSLog(@"completed");
    }];
    
    //监听点击搜索按钮信号
    [[self rac_signalForSelector:@selector(searchBarSearchButtonClicked:) fromProtocol:@protocol(UISearchBarDelegate)] subscribeNext:^(RACTuple * _Nullable value) {
        UISearchBar *searchBar = value.first;
        [searchBar resignFirstResponder];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imagePath = [NSBundle.mainBundle pathForResource:@"background" ofType:@"jpg"];
        UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
        
        /**
         *放射变换首先考虑的是平移，再进行旋转或绕轴旋转。
         */
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, tempImage.size.width, tempImage.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        transform = CGAffineTransformTranslate(transform, tempImage.size.width, 0.f);
        transform = CGAffineTransformScale(transform, -1.f, 1.f);
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contextRef = CGBitmapContextCreate(NULL, tempImage.size.width, tempImage.size.height, 8, 0, colorSpaceRef, kCGImageAlphaNone);
        CGContextConcatCTM(contextRef, transform);
        CGContextDrawImage(contextRef, CGRectMake(0.f, 0.f, tempImage.size.width, tempImage.size.height), tempImage.CGImage);
        CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
        CGColorSpaceRelease(colorSpaceRef);
        CGContextRelease(contextRef);
        
        UIImage *renderImage = [UIImage imageWithCGImage:imageRef scale:tempImage.scale orientation:tempImage.imageOrientation];
        CGImageRelease(imageRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.BGImage.image = renderImage;
        });
    });
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.viewModel.photoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RWSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RWSearchViewCell" forIndexPath:indexPath];
    [cell updateViewCell:self.viewModel.photoArray[indexPath.row]];
    return cell;
}

@end
