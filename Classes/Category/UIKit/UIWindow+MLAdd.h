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
 Detect whether contains one window which visible on mainScreen with test block
 @warning reverseObjectEnumerator
 
 @param comparator comparator
 
 @return bool
 */
+ (BOOL)containsVisibleWindowOnMainScreenReversePassingTest:(BOOL (^)(UIWindow *window,BOOL aboveAppDelegateWindow,BOOL *stop))comparator;

@end

NS_ASSUME_NONNULL_END