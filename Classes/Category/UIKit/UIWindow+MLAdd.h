//
//  UIWindow+MLAdd.h
//  MLKitExample
//
//  Created by molon on 16/7/4.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIWindow`.
 */
@interface UIWindow (MLAdd)

/**
 Detect whether contains windows which in visible windows on mainScreen with test block
 @warning reverseObjectEnumerator
 
 @param comparator comparator
 
 @return bool
 */
+ (BOOL)containsInVisibleWindowsOnMainScreenReversePassingTest:(BOOL (^)(UIWindow *window,BOOL aboveAppDelegateWindow,BOOL *stop))comparator;

/*!
 @brief Enumerate windows which is visible on mainScreen
 
 @param reverse reverse
 @param block   block
 */
+ (void)enumerateVisibleWindowsOnMainScreenWithReverse:(BOOL)reverse usingBlock:(void (^)(UIWindow *window,BOOL aboveAppDelegateWindow,BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
