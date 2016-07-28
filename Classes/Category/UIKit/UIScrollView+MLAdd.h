//
//  UIScrollView+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIScrollView`.
 */
@interface UIScrollView (MLAdd)

@property (nonatomic, assign) CGFloat contentInsetTop;
@property (nonatomic, assign) CGFloat contentInsetBottom;
@property (nonatomic, assign) CGFloat contentInsetLeft;
@property (nonatomic, assign) CGFloat contentInsetRight;

@property (nonatomic, assign, readonly) CGPoint bottomContentOffset;
@property (nonatomic, assign, readonly) CGPoint rightContentOffset;

/**
 Scroll content to top.
 
 @param animated  Use animation.
 */
- (void)scrollToTopAnimated:(BOOL)animated;

/**
 Scroll content to bottom.
 
 @param animated  Use animation.
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 Scroll content to left.
 
 @param animated  Use animation.
 */
- (void)scrollToLeftAnimated:(BOOL)animated;

/**
 Scroll content to right.
 
 @param animated  Use animation.
 */
- (void)scrollToRightAnimated:(BOOL)animated;

/**
 Scroll the rect to display at middle of vertical
 
 @param rect     rect , like `[tableView rectForRowAtIndexPath:targetIndexPath]`
 @param animated animated
 */
- (void)scrollRectToVisibleAtMiddleOfVertical:(CGRect)rect animated:(BOOL)animated;

/**
 Dodge the bottom height in window to make sure to display the datumContentOffsetY position.
 The method is usually used to dodge the keyboard.
 
 @warning we must change the contentInsetBottom to original(datum) when not dodge
 
 @param heightInWindow          the height which will be dodged
 @param datumContentOffsetY     ensure display position
 @param datumContentInsetBottom the original contentInsetBottom when not dodge
 @param animated                animted
 */
- (void)dodgeBottomWithHeightInWindow:(CGFloat)heightInWindow datumContentOffsetY:(CGFloat)datumContentOffsetY datumContentInsetBottom:(CGFloat)datumContentInsetBottom animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
