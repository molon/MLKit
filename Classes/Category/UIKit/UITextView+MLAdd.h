//
//  UITextView+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UITextView`.
 */
@interface UITextView (MLAdd)

/**
 Placeholder
 @warning the placeholder will not follow scrolling, so set an appropriate size for textView please.
 */
@property (nullable, nonatomic, copy) NSString *placeholder;

/**
 Placeholder color
 */
@property (nullable, nonatomic, strong) UIColor *placeholderColor;

@end

NS_ASSUME_NONNULL_END