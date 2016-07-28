//
//  UIViewController+MLAdd.h
//  MLKitExample
//
//  Created by molon on 16/7/2.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIViewController`.
 */
@interface UIViewController (MLAdd)

/**
 Get height of statusBarHeight, always is 20 now.
 
 @return 20.0f
 */
+ (CGFloat)statusBarHeight;

/**
 Returns the bottom y of navigationBar.
 The value is usually the starting point of layout subviews of self.view or the top inset of UIScrollView.
 */
- (CGFloat)navigationBarBottomY;

/**
 Returns the occupied height of tabBar in self.view.
 The value is usually the end of layout subviews of self.view or the bottom inset of UIScrollView.
 */
- (CGFloat)tabBarOccupiedHeight;

/**
 Returns the top visible viewController.
 It is usually the top presentedViewController.
 If no presentedViewController, it is usually self.
 If self is ContainerViewController,like `UINavigationController`,`UITabBarController`,returns it's topVieController or selectedViewController
 */
- (UIViewController*)topVisibleViewController;

/**
 If locate in a navigationController and is not the first child of it,just pop. otherwise dismiss.
 */
- (void)disappear;

/**
 Removes the backBarItem's title for navigationBar
 */
+ (void)validateNoBackTitleForNavigationBar;

@end

NS_ASSUME_NONNULL_END
