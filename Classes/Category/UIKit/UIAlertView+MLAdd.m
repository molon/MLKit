//
//  UIAlertView+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIAlertView+MLAdd.h"
#import "MLKitMacro.h"
#import <objc/runtime.h>
#import "NSObject+MLAdd.h"

SYNTH_DUMMY_CLASS(UIAlertView_MLAdd)

@interface UIAlertView()

@property (nonatomic, copy) void(^clickedCallback)(UIAlertView *alertView,NSInteger buttonIndex,BOOL canceled);

@end

@implementation UIAlertView (MLAdd)

SYNTH_DYNAMIC_PROPERTY_OBJECT(userInfo, setUserInfo:, RETAIN_NONATOMIC, id)
SYNTH_DYNAMIC_PROPERTY_OBJECT(clickedCallback, setClickedCallback:, COPY_NONATOMIC, void (^)(UIAlertView *, NSInteger, BOOL))

+ (instancetype)alertViewWithTitle:(NSString*)title message:(NSString*)message clickedCallback:(void(^)(UIAlertView *alertView,NSInteger buttonIndex,BOOL canceled))clickedCallback cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alertView.delegate = alertView;
    alertView.clickedCallback = clickedCallback;
    
    if (otherButtonTitles) {
        [alertView addButtonWithTitle:otherButtonTitles];
        
        NSString * eachObject;
        
        va_list args;
        va_start(args, otherButtonTitles);
        while ((eachObject = va_arg(args, NSString *))){
            [alertView addButtonWithTitle:eachObject];
        }
    
        va_end(args);
    }
    
    return alertView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL canceled = (buttonIndex == [alertView cancelButtonIndex]);
    if (self.clickedCallback) {
        self.clickedCallback(self,buttonIndex,canceled);
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(setDelegate:) with:@selector(____hookSetDelegate:)];
    });
}

- (void)____hookSetDelegate:(id)delegate {
    NSAssert(!self.clickedCallback, @"If using clickedCallback, please dont assign delegate to UIAlertView yourself");
    
    [self ____hookSetDelegate:delegate];
}

+ (void)showWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString *)cancelButtonTitle {
    [[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil]show];
}
@end
