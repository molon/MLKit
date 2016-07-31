//
//  CircleMLRefreshControlAnimateView.m
//
//  Created by molon on 15/8/19.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "CircleMLRefreshControlAnimateView.h"

@interface CircleView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIColor *color;

@end

@implementation CircleView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setProgress:(float)progress
{
    _progress = progress;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    UIColor *color = self.color?:[UIColor lightGrayColor];
    CGContextSetStrokeColorWithColor(context,color.CGColor);
    CGFloat startAngle = -M_PI/3;
    CGFloat step = 11*M_PI/6 * self.progress;
    
    
    CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.height/2-5.0f, startAngle, startAngle+step, 0);
    CGContextStrokePath(context);
}

@end

@interface CircleMLRefreshControlAnimateView()

@property (nonatomic, strong) CircleView *circleView;

@end

@implementation CircleMLRefreshControlAnimateView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.circleView];
    }
    return self;
}

- (void)setState:(MLRefreshControlState)state
{
    MLRefreshControlState originalState = self.state;
    
    [super setState:state];
    
    if (state==MLRefreshControlStateNormal) {
        self.circleView.progress = 0.0f;
        
        [self.circleView.layer removeAllAnimations];
        
        if (originalState==MLRefreshControlStateRefreshing) {
            CATransition *animation = [CATransition animation];
            animation.duration = .15f;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionFade;
            [self.circleView.layer addAnimation:animation forKey:nil];
        }
    }else if (state==MLRefreshControlStateOverstep||state==MLRefreshControlStateRefreshing){
        self.circleView.progress = 1.0f;
        
        if (state==MLRefreshControlStateRefreshing) {
            CABasicAnimation* rotate =  [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
            rotate.fillMode = kCAFillModeForwards;
            [rotate setToValue: [NSNumber numberWithFloat:M_PI/2]];
            rotate.repeatCount = FLT_MAX;
            rotate.duration = 0.25f;
            rotate.cumulative = TRUE;
            rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            
            [_circleView.layer addAnimation:rotate forKey:@"rotateAnimation"];
        }
    }
}


- (void)setPullingProgress:(float)pullingProgress
{
    [super setPullingProgress:pullingProgress];
    
    if (self.state != MLRefreshControlStatePulling) {
        return;
    }
    
    self.circleView.progress = pullingProgress;
}

- (CircleView *)circleView
{
    if (!_circleView) {
        _circleView = [CircleView new];
    }
    return _circleView;
}

- (void)setCircleYOffset:(CGFloat)circleYOffset
{
    _circleYOffset = circleYOffset;
    
    [self setNeedsLayout];
}

- (void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    self.circleView.color = circleColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
#define kYPadding 10.0f
    CGFloat side = self.frame.size.height-kYPadding*2;
    self.circleView.frame = CGRectMake((self.frame.size.width-side)/2, kYPadding+self.circleYOffset, side, side);
}

@end
