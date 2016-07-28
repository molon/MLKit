//
//  UIScreen+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIScreen`.
 */
@interface UIScreen (MLAdd)

/**
 Main screen's scale
 
 @return screen's scale
 */
+ (CGFloat)screenScale;

/**
 Main screen's size
 
 @warning the return width is always less than height
 
 @return screenSize
 */
+ (CGSize)screenSize;

/**
 Returns the bounds of the screen for the current device orientation.
 
 @return A rect indicating the bounds of the screen.
 @see    boundsForOrientation:
 */
- (CGRect)currentBounds NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Returns the bounds of the screen for a given device orientation.
 `UIScreen`'s `bounds` method always returns the bounds of the
 screen of it in the portrait orientation.
 
 @param orientation  The orientation to get the screen's bounds.
 @return A rect indicating the bounds of the screen.
 @see  currentBounds
 */
- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END

// main screen's scale
#ifndef kScreenScale
#define kScreenScale [UIScreen screenScale]
#endif

// line weight
#ifndef kLineWeight
#define kLineWeight (1.0f/kScreenScale)
#endif

// main screen's size (portrait)
#ifndef kScreenSize
#define kScreenSize [UIScreen screenSize]
#endif

// main screen's width (portrait)
#ifndef kScreenWidth
#define kScreenWidth kScreenSize.width
#endif

// main screen's height (portrait)
#ifndef kScreenHeight
#define kScreenHeight kScreenSize.height
#endif

