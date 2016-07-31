//
//  MLRefreshControlView.h
//
//  Created by molon on 15/8/18.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLRefreshControlTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class MLRefreshControlAnimateView;
@interface MLRefreshControlView : UIView

/**
 Current state
 */
@property (nonatomic,assign,readonly) MLRefreshControlState state;

/**
 The original top of scrollView's contentInset, it will be used to restore the display after refreshing completed.
 */
@property (nonatomic, assign) CGFloat originalTopInset;

/**
 Indicate whether auto scroll to top after refreshing completed.
 */
@property (nonatomic, assign) BOOL scrollToTopAfterEndRefreshing;

/**
 The animateView which indicates the display of refresh state.
 */
@property (nonatomic, strong) MLRefreshControlAnimateView *animateView;

/**
 The displaying style of animateView
 */
@property (nonatomic, assign) MLRefreshControlViewStyle style;

/**
 scrollView
 */
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

/**
 Init a refresh control view
 
 @param scrollView                    scrollView
 @param actionBlock                   refreshing action block
 @param animateView                   animateView
 @param originalTopInset              originalTopInset
 @param scrollToTopAfterEndRefreshing Whether auto scroll to top after refreshing completed
 
 @return Refresh control view
 */
- (id)initWithScrollView:(UIScrollView *)scrollView action:(MLRefreshControlActionBlock)actionBlock animateView:(MLRefreshControlAnimateView*)animateView style:(MLRefreshControlViewStyle)style originalTopInset:(CGFloat)originalTopInset scrollToTopAfterEndRefreshing:(BOOL)scrollToTopAfterEndRefreshing;

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
