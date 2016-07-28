//
//  UITableViewCell+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UITableViewCell+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(UITableViewCell_MLAdd)

@implementation UITableViewCell (MLAdd)

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
}

+ (instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil]lastObject];
}


+ (CGFloat)heightForObject:(id)object maxWidth:(CGFloat)maxWidth
{
    return 44.0f;
}

- (CGFloat)autolayoutFitHeightWithMaxWidth:(CGFloat)maxWidth afterReuseBlock:(void(^)())afterReuseBlock
{
    [self prepareForReuse];
    
    if (afterReuseBlock) {
        afterReuseBlock();
    }
    
    if (![self.contentView respondsToSelector:@selector(systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority:)]) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:maxWidth];
        constraint.priority = 999;
        [self.contentView addConstraint:constraint];
        
        CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        [self.contentView removeConstraint:constraint];
        
        return ceil(size.height);
    }
    
    CGSize fittingSize = UILayoutFittingCompressedSize;
    fittingSize.width = maxWidth;
    CGSize size = [self.contentView systemLayoutSizeFittingSize:fittingSize withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityDefaultLow];
    
    return ceil(size.height);
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)cancelReuse:(BOOL)cancelReuse
{
    if (cancelReuse) {
        NSString *temporarilyReuseIdentifier = [NSString stringWithFormat:@"%@_%p",[[self class]cellReuseIdentifier],self];
        [self setValue:temporarilyReuseIdentifier forKey:@"reuseIdentifier"];
    }else{
        [self setValue:[[self class]cellReuseIdentifier] forKey:@"reuseIdentifier"];
    }
}

@end
