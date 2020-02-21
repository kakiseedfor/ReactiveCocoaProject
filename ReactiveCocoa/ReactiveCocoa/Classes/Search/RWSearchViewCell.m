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

- (void)updateViewCell:(RWSearchModel *)model{
    self.photoTitle.text = model.title;
    RAC(self.photoImage,image) = [[model.imageSignal deliverOn:RACScheduler.mainThreadScheduler] map:^id(id value) {
        return [UIImage imageWithData:value];
    }];
}

@end
