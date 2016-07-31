//
//  UIScrollView+MLRefreshControl.h
//
//  Created by molon on 15/8/18.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLRefreshControlTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class MLRefreshControlView,MLRefreshControlAnimateView;
@interface UIScrollView (MLRefreshControl)

/**
 refresh control view
 */
@property (nonatomic, strong, readonly, nullable) MLRefreshControlView *refreshView;

/**
 The last refresh time
 */
@property (nonatomic, strong, readonly) NSDate *lastRefreshTime;

/**
 is refreshing
 */
@property (nonatomic, assign, readonly) BOOL isRefreshing;

/**
 Indicate whether auto scroll to top after refreshing completed.
 */
@property (nonatomic, assign, readonly) BOOL scrollToTopAfterEndRefreshing;

/**
 
 Enable MLRefreshControl support for scrollView
 
 @param actionBlock                   refreshing action block
 @param style                         display style for refresh control
 @param scrollToTopAfterEndRefreshing whether auto scroll to top after refreshing completed
 */
- (void)enableRefreshingWithAction:(MLRefreshControlActionBlock)actionBlock style:(MLRefreshControlViewStyle)style scrollToTopAfterEndRefreshing:(BOOL)scrollToTopAfterEndRefreshing;

/**
 Enable MLRefreshControl support for scrollView
 
 @param actionBlock                   refreshing action block
 @param style                         display style for refresh control
 @param scrollToTopAfterEndRefreshing whether auto scroll to top after refreshing completed
 @param animateView                   animateView
 */
- (void)enableRefreshingWithAction:(MLRefreshControlActionBlock)actionBlock style:(MLRefreshControlViewStyle)style scrollToTopAfterEndRefreshing:(BOOL)scrollToTopAfterEndRefreshing animteView:(MLRefreshControlAnimateView*)animateView;

/**
 End refreshing, please tell the control manually.
 */
- (void)endRefreshing;

/**
 Begin refreshing, if you want to begin refreshing manually.
 */
- (void)beginRefreshing;

@end

NS_ASSUME_NONNULL_END
