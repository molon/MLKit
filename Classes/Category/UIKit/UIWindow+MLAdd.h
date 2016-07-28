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
 The window which windowLevel==UIWindowLevelNormal and visible==YES and displays at the topmost zIndex on mainScreen
 
 @return window
 */
+ (UIWindow*)currentVisbileNormalWindow;

@end

NS_ASSUME_NONNULL_END