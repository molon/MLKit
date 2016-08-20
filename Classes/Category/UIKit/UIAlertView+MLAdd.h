//
//  UIAlertView+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIAlertView`.
 */
@interface UIAlertView (MLAdd)

/**
 The message transfer
 */
@property (nullable, nonatomic, strong) id userInfo;

/**
 Returns alertView with clickedCallback conveniently
 
 @param title             title
 @param message           message
 @param clickedCallback   clickedCallback
 @param cancelButtonTitle cancelButtonTitle
 @param otherButtonTitles otherButtonTitles
 
 @return alertView
 */
+ (instancetype)alertViewWithTitle:(NSString*)title message:(NSString*)message clickedCallback:(void(^)(UIAlertView *alertView,NSInteger buttonIndex,BOOL canceled))clickedCallback cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Just show message
 
 @param title             title
 @param message           message
 @param cancelButtonTitle cancelButtonTitle
 */
+ (void)showWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString *)cancelButtonTitle;

@end

NS_ASSUME_NONNULL_END