//
//  DefaultMLAPIObserverView.m
//  MLKitExample
//
//  Created by molon on 16/8/11.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "DefaultMLAPIObserverView.h"
#import "UIView+MLAdd.h"
#import "MLKitMacro.h"
#import "UIImage+MLAdd.h"
#import "CALayer+MLAdd.h"
#import "UIScreen+MLAdd.h"

@interface DefaultMLAPIObserverView()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation DefaultMLAPIObserverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _indicatorView = ({
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self addSubview:view];
            view;
        });
        _retryButton = ({
            UIButton *button = [[UIButton alloc]init];
            [button addTarget:self action:@selector(clickRetry) forControlEvents:UIControlEventTouchUpInside];
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:button];
            button;
        });
        self.retryButtonImage = [MLKIT_BUNDLE_PNG_IMAGE(@"刷新") imageWithTintColor:[UIColor grayColor]];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickBackground)]];
    }
    return self;
}

#pragma mark - setter
- (void)setState:(MLAPIHelperState)state
{
    [super setState:state];
    
    switch (state) {
        case MLAPIHelperStateInit:
        case MLAPIHelperStateRequestSucceed:
            self.hidden = YES;
            [self.layer addFadeTransitionWithDuration:.15f];
            break;
        case MLAPIHelperStateRequestError:
        case MLAPIHelperStateRequestFailed:
        {
            //if no retry block，just do same with MLAPIHelperStateRequestSucceed
            if (!self.retryBlock) {
                self.hidden = YES;
                [self.layer addFadeTransitionWithDuration:.15f];
            }else{
                self.hidden = NO;
                [_indicatorView stopAnimating];
                _retryButton.hidden = NO;
            }
        }
            break;
        case MLAPIHelperStateCachePreloaded:
        case MLAPIHelperStateRequesting:
            if (self.observingAPIHelper.isCurrentPreloaded) {
                self.hidden = YES;
            }else{
                self.hidden = NO;
                [_indicatorView startAnimating];
                _retryButton.hidden = YES;
            }
            break;
        default:
            break;
    }
}

- (void)setRetryButtonImage:(UIImage *)retryButtonImage {
    _retryButtonImage = retryButtonImage;
    
    [_retryButton setImage:retryButtonImage forState:UIControlStateNormal];
    
    [self setNeedsLayout];
}

#pragma mark - event
- (void)clickRetry {
    if (self.retryBlock) {
        self.retryBlock(self);
    }
}

- (void)clickBackground {
    if (_clickBackgroundToRefresh&&!_retryButton.hidden) {
        [self clickRetry];
    }
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.indicatorView.center = CGPointMake(self.width/2, self.height/2);
#define kRetryButtonSide 40.0f
    UIImage *image = [self.retryButton imageForState:UIControlStateNormal];
    CGFloat side = fmax(image.size.width*image.scale/kScreenScale, image.size.height*image.scale/kScreenScale);
    side = fmax(kRetryButtonSide, side);
    self.retryButton.frame = [self centerFrameWithWidth:side height:side];
}

#pragma mark - penetrable
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    
    if (result) {
        //penetrable except button
        if (_penetrable&&!CGRectContainsPoint(self.retryButton.frame, point)) {
            return NO;
        }
    }
    
    return result;
}

@end
