//
//  UIBarButtonItem+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIBarButtonItem`.
 */
@interface UIBarButtonItem (MLAdd)

/**
 The block that invoked when the item is selected. The objects captured by block
 will retained by the ButtonItem.
 
 @discussion This param is conflict with `target` and `action` property.
 Set this will set `target` and `action` property to some internal objects.
 */
@property (nullable, nonatomic, copy) void (^actionBlock)(id);

@end

NS_ASSUME_NONNULL_END