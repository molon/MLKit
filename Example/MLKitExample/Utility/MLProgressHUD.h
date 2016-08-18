//
//  MLProgressHUD.h
//  XQ_SDB
//
//  Created by molon on 16/8/18.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <MBProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLProgressHUD : MBProgressHUD

/**
 Show message or customView conveniently
 
 @param view                   view
 @param message                message
 @param detailMessage          detailMessage
 @param customView             customView
 @param userInteractionEnabled userInteractionEnabled
 @param yOffset                yOffset
 @param hideDelay              hideDelay
 
 @return instance
 */
+ (instancetype)showOnView:(UIView*)view message:(nullable NSString*)message detailMessage:(nullable NSString*)detailMessage customView:(nullable UIView*)customView userInteractionEnabled:(BOOL)userInteractionEnabled yOffset:(CGFloat)yOffset hideDelay:(NSTimeInterval)hideDelay;

/**
 Show indeterminate hud on view conveniently
 
 @param view          view
 @param message       message
 @param detailMessage detailMessage
 @param yOffset       yOffset
 
 @return instance
 */
+ (instancetype)showIndeterminateHUDOnView:(UIView*)view message:(nullable NSString*)message detailMessage:(nullable NSString*)detailMessage yOffset:(CGFloat)yOffset;

/**
 Hide all indeterminate huds conveniently
 
 @param view view
 
 @return count hided
 */
+ (NSInteger)hideIndeterminateHUDsOnView:(UIView*)view;

@end

NS_ASSUME_NONNULL_END
