//
//  UIActionSheet+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIActionSheet`.
 */
@interface UIActionSheet (MLAdd)

/**
 The message transfer
 */
@property (nullable, nonatomic, strong) id userInfo;

/**
 Returns actionSheet with clickedCallback conveniently
 
 @param title             title
 @param clickedCallback   clickedCallback
 @param cancelButtonTitle cancelButtonTitle
 @param destructiveButtonTitle destructiveButtonTitle
 @param otherButtonTitles otherButtonTitles
 
 @return actionSheet
 */
+ (instancetype)actionSheetWithTitle:(nullable NSString *)title clickedCallback:(void(^)(UIActionSheet *actionSheet,NSInteger buttonIndex,BOOL cancel,BOOL destructive))clickedCallback cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION ;

@end

NS_ASSUME_NONNULL_END