//
//  UIScrollView+MLRefreshControl.m
//
//  Created by molon on 15/8/18.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "UIScrollView+MLRefreshControl.h"
#import <objc/runtime.h>
#import "MLRefreshControlView.h"
#import "CircleMLRefreshControlAnimateView.h"

@interface UIScrollView()

@property (nonatomic, strong) MLRefreshControlView *refreshView;
@property (nonatomic, strong) NSDate *lastRefreshTime;

@end

@implementation UIScrollView (MLRefreshControl)

#pragma mark - event
- (void)enableRefreshingWithAction:(MLRefreshControlActionBlock)actionBlock style:(MLRefreshControlViewStyle)style scrollToTopAfterEndRefreshing:(BOOL)scrollToTopAfterEndRefreshing
{
    [self enableRefreshingWithAction:actionBlock style:style scrollToTopAfterEndRefreshing:scrollToTopAfterEndRefreshing animteView:[CircleMLRefreshControlAnimateView new]];
}

- (void)enableRefreshingWithAction:(MLRefreshControlActionBlock)actionBlock style:(MLRefreshControlViewStyle)style scrollToTopAfterEndRefreshing:(BOOL)scrollToTopAfterEndRefreshing animteView:(MLRefreshControlAnimateView*)animateView
{
    if (!animateView) {
        animateView = [CircleMLRefreshControlAnimateView new];
        
    }
    self.refreshView = [[MLRefreshControlView alloc]initWithScrollView:self action:actionBlock animateView:animateView style:style originalTopInset:self.contentInset.top scrollToTopAfterEndRefreshing:scrollToTopAfterEndRefreshing];
}

- (void)endRefreshing
{
    [self.refreshView endRefreshing];
}

- (void)beginRefreshing
{
    if (!self.refreshView) {
        return;
    }
    
    [self.refreshView endRefreshing];
    [self.refreshView beginRefreshing];
}

#pragma mark - getter and setter
- (BOOL)isRefreshing
{
    return self.refreshView.state == MLRefreshControlStateRefreshing;
}

- (BOOL)scrollToTopAfterEndRefreshing
{
    return self.refreshView.scrollToTopAfterEndRefreshing;
}

static char refreshViewKey;
static char lastRefreshTimeKey;

- (MLRefreshControlView *)refreshView
{
    return objc_getAssociatedObject(self,&refreshViewKey);
}

- (void)setRefreshView:(MLRefreshControlView *)refreshView
{
    //Remove old
    if (self.refreshView) {
        [self.refreshView removeFromSuperview];
    }
    
    static NSString * key = @"refreshView";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &refreshViewKey, refreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

-(NSDate *)lastRefreshTime
{
    return objc_getAssociatedObject(self,&lastRefreshTimeKey);
}

- (void)setLastRefreshTime:(NSDate *)lastRefreshTime
{
    static NSString * key = @"lastRefreshTime";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &lastRefreshTimeKey, lastRefreshTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}


@end
