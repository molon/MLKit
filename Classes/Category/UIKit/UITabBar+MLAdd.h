//
//  UITabBar+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UITabBar`.
 */
@interface UITabBar (MLAdd)

/**
 Return the tabBar with its index
 
 @param index tabBarItemIndex
 
 @return tabBar view
 */
- (nullable UIView*)viewForTabBarItemAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END