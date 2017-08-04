//
//  UINavigationBar+MLAdd.h
//  Pods
//
//  Created by molon on 16/8/29.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UINavigationBar`.
 */
@interface UINavigationBar (MLAdd)

/**
 Returns bottom hairline imageView
 */
- (UIImageView *)hairlineImageView;

/*!
 Return the button with its display index from left or right
 
 @param index    display index
 @param fromLeft direction
 
 @return button or nil
 */
- (nullable UIButton*)buttonAtIndex:(NSUInteger)index fromLeft:(BOOL)fromLeft;

@end

NS_ASSUME_NONNULL_END
