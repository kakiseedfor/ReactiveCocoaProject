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
    @weakify(self);
    [[model.imageSignal deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSData *imageData) {
        @strongify(self);
        self.photoImage.image = [UIImage imageWithData:imageData];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
