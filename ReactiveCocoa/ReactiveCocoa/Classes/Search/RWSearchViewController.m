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
    } error:^(NSError * _Nullable error) {
        NSLog(@"error = %@",error);
    } completed:^{
        NSLog(@"completed");
    }];
    
    //监听点击搜索按钮信号
    [[self rac_signalForSelector:@selector(searchBarSearchButtonClicked:) fromProtocol:@protocol(UISearchBarDelegate)] subscribeNext:^(RACTuple * _Nullable value) {
        UISearchBar *searchBar = value.first;
        [searchBar resignFirstResponder];
    }];
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
