//
//  UIActionSheet+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIActionSheet+MLAdd.h"
#import "MLKitMacro.h"
#import <objc/runtime.h>
#import "NSObject+MLAdd.h"

SYNTH_DUMMY_CLASS(UIActionSheet_MLAdd)

@interface UIActionSheet()

@property (nonatomic, copy) void(^clickedCallback)(UIActionSheet *actionSheet,NSInteger buttonIndex,BOOL cancel,BOOL destructive);

@end

@implementation UIActionSheet (MLAdd)

SYNTH_DYNAMIC_PROPERTY_OBJECT(userInfo, setUserInfo:, RETAIN_NONATOMIC, id)
SYNTH_DYNAMIC_PROPERTY_OBJECT(clickedCallback, setClickedCallback:, COPY_NONATOMIC, void (^)(UIActionSheet *, NSInteger, BOOL, BOOL))

+ (instancetype)actionSheetWithTitle:(nullable NSString *)title clickedCallback:(void(^)(UIActionSheet *actionSheet,NSInteger buttonIndex,BOOL cancel,BOOL destructive))clickedCallback cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    actionSheet.delegate = (id<UIActionSheetDelegate>)actionSheet;
    actionSheet.clickedCallback = clickedCallback;
    
    if (otherButtonTitles) {
        [actionSheet addButtonWithTitle:otherButtonTitles];
        
        NSString * eachObject;
        
        va_list args;
        va_start(args, otherButtonTitles);
        while ((eachObject = va_arg(args, NSString *))){
            [actionSheet addButtonWithTitle:eachObject];
        }
        
        va_end(args);
    }
    
    return actionSheet;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(setDelegate:) with:@selector(____hookSetDelegate:)];
    });
}

- (void)____hookSetDelegate:(id)delegate {
    NSAssert(!self.clickedCallback, @"If using clickedCallback, please dont assign delegate to UIActionSheet yourself");
    
    [self ____hookSetDelegate:delegate];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.clickedCallback) {
        BOOL cancel = [actionSheet cancelButtonIndex]==buttonIndex;
        BOOL destructive = [actionSheet destructiveButtonIndex]==buttonIndex;
        
        self.clickedCallback(self,buttonIndex,cancel,destructive);
    }
}

@end
