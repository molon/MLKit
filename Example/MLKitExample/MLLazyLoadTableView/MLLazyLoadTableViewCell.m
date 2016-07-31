//
//  MLLazyLoadTableViewCell.m
//  TycoonBuy
//
//  Created by molon on 16/4/18.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLLazyLoadTableViewCell.h"

@implementation MLLazyLoadTableViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, [UIScreen mainScreen].bounds.size.width*10.0f, 0, 0);
    }
    return self;
}

- (CGFloat)preferredHeightWithMaxWidth:(CGFloat)maxWidth
{
    return 44.0f;
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        if (self.status==MLLazyLoadCellStatusLoadFailed) {
            if (self.clickForRetryBlock) {
                self.clickForRetryBlock();
            }
        }
    }
}

@end
