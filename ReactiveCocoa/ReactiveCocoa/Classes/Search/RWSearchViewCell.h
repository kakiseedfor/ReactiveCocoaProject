//
//  RWSearchViewCell.h
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/19.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWSearchModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RWSearchViewCell : UITableViewCell

- (void)updateViewCell:(RWSearchModel *)model;

@end

NS_ASSUME_NONNULL_END
