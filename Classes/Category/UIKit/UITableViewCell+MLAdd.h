//
//  UITableViewCell+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UITableViewCell`.
 */
@interface UITableViewCell (MLAdd)

//=============================================================================
/// @name Height
///=============================================================================

/**
 return height with object and max width
 
 @warning default is 44.0f
 
 @param object   object
 @param maxWidth maxwidth
 
 @return height
 */
+ (CGFloat)heightForObject:(id)object maxWidth:(CGFloat)maxWidth;

/**
 Get the fit height if the cell uses autolayout
 
 @param maxWidth        max width
 @param afterReuseBlock afterReuseBlock
 
 @return fit height
 */
- (CGFloat)autolayoutFitHeightWithMaxWidth:(CGFloat)maxWidth afterReuseBlock:(void(^)())afterReuseBlock;

//=============================================================================
/// @name Other
///=============================================================================

/**
 Return reuse identifier named NSStringFromClass(self class)
 
 @return reuse identifier
 */
+ (NSString *)cellReuseIdentifier;

/**
 Use this method to cancel reuse temporarily
 If no ,the reuse identifier will be reset to `cellReuseIdentifier`
 
 @warning the method must be used in conjunction with `cellReuseIdentifier`
 
 @param cancelReuse cancel or no
 */
- (void)cancelReuse:(BOOL)cancelReuse;

@end

NS_ASSUME_NONNULL_END