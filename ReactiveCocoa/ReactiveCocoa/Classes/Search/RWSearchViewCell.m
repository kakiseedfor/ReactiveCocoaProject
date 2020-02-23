//
//  RWSearchViewCell.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/19.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "RWSearchViewCell.h"

@interface RWSearchViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UILabel *photoTitle;

@end

@implementation RWSearchViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

/**
 信号可以重复被监听，但不能重复绑定。
 所以 model.imageSignal 不是同一个的话，将报信号已被绑定的错误。
 */
- (void)updateViewCell:(RWSearchModel *)model{
    self.photoTitle.text = model.title;
    RAC(self.photoImage,image) = [[model.imageSignal deliverOn:RACScheduler.mainThreadScheduler] map:^id(id value) {
        return [UIImage imageWithData:value];
    }];
}

@end
