//
//  MLRefreshControlView.m
//
//  Created by molon on 15/8/18.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLRefreshControlView.h"
#import "MLRefreshControlAnimateView.h"
#import "UIScrollView+MLRefreshControl.h"

@interface UIScrollView(MLRefreshControlViewPrivate)

@property (nonatomic, strong) NSDate *lastRefreshTime;

@end

@interface MLRefreshControlView()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, copy) MLRefreshControlActionBlock actionBlock;

@property (nonatomic, assign) MLRefreshControlState state;

@end

@implementation MLRefreshControlView {
    /**
     Sometimes we need to ignore the kvo for contentOffset temporarily.
     Because some behavior will affect contentOffset(Like changing contentInset)
     */
    BOOL _ignoreSetContentOffsetForKVO;
    
    __weak UIPanGestureRecognizer *_scrollViewPanGesture;
}

- (id)initWithScrollView:(UIScrollView *)scrollView action:(MLRefreshControlActionBlock)actionBlock animateView:(MLRefreshControlAnimateView*)animateView style:(MLRefreshControlViewStyle)style originalTopInset:(CGFloat)originalTopInset scrollToTopAfterEndRefreshing:(BOOL)scrollToTopAfterEndRefreshing
{
    self = [self init];
    if (self) {
        self.actionBlock = actionBlock;
        self.originalTopInset = originalTopInset;
        self.scrollToTopAfterEndRefreshing = scrollToTopAfterEndRefreshing;
        
        self.animateView = animateView;
        self.style = style;
        
        [scrollView addSubview:self];
        [scrollView sendSubviewToBack:self];
        
        //first layout, the view's frame be always set self according to scrollView.
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    return self;
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.style==MLRefreshControlViewStyleFixed) {
        [super setFrame:CGRectMake(0, self.scrollView.contentOffset.y+self.originalTopInset, self.scrollView.frame.size.width, kMLRefreshControlViewHeight)];
    }else{
        [super setFrame:CGRectMake(0, -kMLRefreshControlViewHeight, self.scrollView.bounds.size.width, kMLRefreshControlViewHeight)];
    }
    self.animateView.frame = self.bounds;
}

#pragma mark - helper
- (void)changeScrollViewContentInsetTop:(CGFloat)insetTop
{
    _ignoreSetContentOffsetForKVO = YES;
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.top = insetTop;
    self.scrollView.contentInset = inset;
    _ignoreSetContentOffsetForKVO = NO;
}

#pragma mark - setter
- (void)setAnimateView:(MLRefreshControlAnimateView *)animateView
{
    [_animateView removeFromSuperview];
    
    MLRefreshControlState state = _animateView.state;
    float pullingProgress = _animateView.pullingProgress;
    
    _animateView = animateView;
    
    [self addSubview:_animateView];
    _animateView.state = state;
    _animateView.pullingProgress = pullingProgress;
    
    [self setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
    //Disable setting frame directly.
    return;
}

- (void)setState:(MLRefreshControlState)state
{
    if (_state == state) return;
    _state = state;
    
    self.animateView.state = state;
    
    void (^scrollTopTopBlock)() = ^{
        _ignoreSetContentOffsetForKVO = YES;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.scrollView.contentInset.top) animated:NO];
        _ignoreSetContentOffsetForKVO = NO;
    };
    
    switch (state) {
        case MLRefreshControlStateNormal:
        {
            void (^animationBlock)(void) = ^{
                [self changeScrollViewContentInsetTop:self.originalTopInset];
                
                //Auto scroll to top after refreshing completeds
                if (self.scrollToTopAfterEndRefreshing) {
                    scrollTopTopBlock();
                }
            };
            
            if (self.scrollView.window) {
                [UIView animateWithDuration:kMLRefreshControlAnimateDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:animationBlock completion:nil];
            }else{
                animationBlock();
            }
            break;
        }
        case MLRefreshControlStateRefreshing:
        {
            void (^animationBlock)(void) = ^{
                [self changeScrollViewContentInsetTop:kMLRefreshControlViewHeight+self.originalTopInset];
                
                //scroll to top
                scrollTopTopBlock();
            };
            
            if (self.scrollView.window) {
                [UIView animateWithDuration:kMLRefreshControlAnimateDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:animationBlock completion:^(BOOL finished) {
                    if (self.actionBlock) {
                        self.actionBlock();
                    }
                }];
            }else{
                animationBlock();
                if (self.actionBlock) {
                    self.actionBlock();
                }
            }
            self.scrollView.lastRefreshTime = [NSDate date];
            break;
        }
        default:
            break;
    }
}

-(void)setStyle:(MLRefreshControlViewStyle)style
{
    _style = style;
    
    [self setNeedsLayout];
}

#pragma mark - KVO
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        //remove kvo
        [_scrollViewPanGesture removeObserver:self forKeyPath:@"state" context:nil];
        [self.superview removeObserver:self forKeyPath:@"contentOffset" context:nil];
        [self.superview removeObserver:self forKeyPath:@"frame" context:nil];
        
        self.scrollView = nil;
        _scrollViewPanGesture = nil;
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    NSAssert(!self.superview||[self.superview isKindOfClass:[UIScrollView class]], @ "MLRefreshControlView only can be add on UIScrollView");
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        self.scrollView = (UIScrollView*)(self.superview);
        _scrollViewPanGesture = [self.scrollView valueForKey:@"pan"];
        
        //add kvo for contentOffset
        [self.superview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        [self.superview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        
        [_scrollViewPanGesture addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.scrollView]) {
        if ([@"frame" isEqualToString:keyPath]) {
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }else if ([@"contentOffset" isEqualToString:keyPath]) {
            if (self.style==MLRefreshControlViewStyleFixed) {
                //不断调整本View位置
                [self setNeedsLayout];
                [self layoutIfNeeded];
            }
            
            if (_ignoreSetContentOffsetForKVO){
                return;
            }
            
            if (self.state == MLRefreshControlStateRefreshing){
                //modify contentInset to ensure the section header can reach top
                CGFloat insetTop;
                if(self.scrollView.contentOffset.y+self.originalTopInset >= 0){
                    insetTop = self.originalTopInset;
                }else{
                    insetTop = fmin(-self.scrollView.contentOffset.y,kMLRefreshControlViewHeight+self.originalTopInset);
                }
                [self changeScrollViewContentInsetTop:insetTop];
                return;
            }
            
            //when scroll up
            CGFloat offsetY = (self.scrollView.contentOffset.y * -1) - self.originalTopInset;
            if (offsetY<0) {
                if (self.state==MLRefreshControlStatePulling) { //之前在下拉状态突然变为上拉了就把动画调调
                    self.animateView.pullingProgress = 0.0f;
                }
                return;
            }
            
            if (offsetY==0) {
                self.state = MLRefreshControlStateNormal;
            }else if (offsetY <= kMLRefreshControlViewHeight){
                self.state = MLRefreshControlStatePulling;
                self.animateView.pullingProgress = offsetY/kMLRefreshControlViewHeight;
            }else{
                self.state = MLRefreshControlStateOverstep;
            }
        }
        return;
    }
    
    if ([object isEqual:_scrollViewPanGesture]&&[@"state" isEqualToString:keyPath]) {
        //check whether stopping drag
        UIGestureRecognizerState new = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        if (new==UIGestureRecognizerStateEnded||new==UIGestureRecognizerStateCancelled||new==UIGestureRecognizerStateFailed) {
            if (self.state == MLRefreshControlStateOverstep) {
                //Begin dragging
                //Must running on next runloop, or `isDragging` would not be NO sometimes.
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.state = MLRefreshControlStateRefreshing;
                });
            }
        }
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - outcall
- (void)endRefreshing
{
    if (self.state != MLRefreshControlStateRefreshing) {
        return;
    }
    
    self.state = MLRefreshControlStateNormal;
}

- (void)beginRefreshing
{
    self.state = MLRefreshControlStateRefreshing;
}

@end
