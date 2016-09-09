//
//  DefaultMLLazyLoadTableViewCell.m
//  TycoonBuy
//
//  Created by molon on 16/4/18.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "DefaultMLLazyLoadTableViewCell.h"

@interface DefaultMLLazyLoadTableViewCell()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation DefaultMLLazyLoadTableViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tipsLabel = [UILabel new];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_tipsLabel];
        
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.backgroundColor = [UIColor clearColor];
        _indicator.opaque = NO;
        [self.contentView addSubview:_indicator];
        
        self.status = MLLazyLoadCellStatusInit;
    }
    return self;
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
#define kIndicatorSide 20.0f
    _indicator.frame =  CGRectMake((self.contentView.frame.size.width-kIndicatorSide)/2, (self.contentView.frame.size.height-kIndicatorSide)/2, kIndicatorSide, kIndicatorSide);
    
    _tipsLabel.frame = self.contentView.bounds;
}

#pragma mark - setter
- (void)setStatus:(MLLazyLoadCellStatus)status
{
    [super setStatus:status];
    
    NSString *text = @"";
    if (status == MLLazyLoadCellStatusLoading) {
        [_indicator startAnimating];
    }else{
        [_indicator stopAnimating];
        if (status == MLLazyLoadCellStatusInit) {
//            text = @"...";
        }else if (status == MLLazyLoadCellStatusLoadFailed){
            text = @"加载失败，点击重试";
        }else if (status == MLLazyLoadCellStatusNoMore){
            text = @"已无更多数据";
        }else if (status == MLLazyLoadCellStatusEmpty){
            text = @"暂无数据";
        }
    }
    
    _tipsLabel.attributedText = [[NSAttributedString alloc] initWithString:text
                                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f],
                                                                             NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    [self setNeedsLayout];
}

#pragma mark - helper
//dont need
//- (void)willMoveToWindow:(UIWindow *)newWindow
//{
//    BOOL visible = newWindow != nil;
//
//    if (visible&&_status==MLLazyLoadCellStatusLoading) {
//        [_indicator startAnimating];
//    }
//}

#pragma mark - height
- (CGFloat)preferredHeightWithMaxWidth:(CGFloat)maxWidth
{
    return 50.0f;
}

@end
