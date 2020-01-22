//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/21.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)beginAction:(id)sender {
    [CentreMediator.shareCentreMediator CM_PushRWViewController];
}

@end
