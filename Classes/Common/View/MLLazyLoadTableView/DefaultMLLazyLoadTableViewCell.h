//
//  DefaultMLLazyLoadTableViewCell.h
//  TycoonBuy
//
//  Created by molon on 16/4/18.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLLazyLoadTableViewCell.h"

@interface DefaultMLLazyLoadTableViewCell : MLLazyLoadTableViewCell

@property (nonatomic, strong, readonly) UILabel *tipsLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;

@end
