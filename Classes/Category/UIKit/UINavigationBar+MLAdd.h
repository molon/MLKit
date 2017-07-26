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
 Return the UINavigationButton with its display index from left or right
 
 @param index    display index
 @param fromLeft direction
 
 @return view or nil
 */
- (nullable UIView*)viewForBarItemAtIndex:(NSUInteger)index fromLeft:(BOOL)fromLeft;

@end

NS_ASSUME_NONNULL_END
