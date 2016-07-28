//
//  UICollectionViewCell+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UICollectionViewCell+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(UICollectionViewCell_MLAdd)

@implementation UICollectionViewCell (MLAdd)

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
}

+ (instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil]lastObject];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
