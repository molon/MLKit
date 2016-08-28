//
//  UISearchBar+MLAdd.h
//  Pods
//
//  Created by molon on 16/8/28.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UISearchBar`.
 */
@interface UISearchBar (MLAdd)

/**
 If YES, cancel button will be always enabled after `resignFirstResponder`,
 */
@property (nonatomic, assign) BOOL enableCancelButtonAfterResignFirstResponder;

@end

NS_ASSUME_NONNULL_END