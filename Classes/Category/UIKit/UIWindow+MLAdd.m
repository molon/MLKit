//
//  UIWindow+MLAdd.m
//  MLKitExample
//
//  Created by molon on 16/7/4.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIWindow+MLAdd.h"
#import "MLKitMacro.h"
#import "UIApplication+MLAdd.h"

SYNTH_DUMMY_CLASS(UIWindow_MLAdd)

@implementation UIWindow (MLAdd)

+ (BOOL)containsInVisibleWindowsOnMainScreenReversePassingTest:(BOOL (^)(UIWindow *window,BOOL aboveAppDelegateWindow,BOOL *stop))comparator {
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows] reverseObjectEnumerator];
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    BOOL aboveAppDelegateWindow = YES;
    BOOL stop = NO;
    for (UIWindow *window in frontToBackWindows) {
        if (window.screen != mainScreen || window.hidden) {
            continue;
        }
        if (aboveAppDelegateWindow&&kAppDelegate.window==window) {
            aboveAppDelegateWindow = NO;
        }
        if (comparator(window,aboveAppDelegateWindow,&stop)) {
            return YES;
        }
        if (stop) {
            return NO;
        }
    }
    return NO;
}


+ (void)enumerateVisibleWindowsOnMainScreenWithReverse:(BOOL)reverse usingBlock:(void (^)(UIWindow *window,BOOL aboveAppDelegateWindow,BOOL *stop))block {
    NSArray *windows = reverse?[[[[UIApplication sharedApplication]windows] reverseObjectEnumerator]allObjects ]:[[UIApplication sharedApplication]windows];
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    BOOL aboveAppDelegateWindow = reverse?YES:NO;
    BOOL stop = NO;
    for (UIWindow *window in windows) {
        if (window.screen != mainScreen || window.hidden) {
            continue;
        }
        if (reverse){
            if(aboveAppDelegateWindow&&kAppDelegate.window==window) {
                aboveAppDelegateWindow = NO;
            }
        }else{
            if (!aboveAppDelegateWindow&&kAppDelegate.window==window) {
                block(window,aboveAppDelegateWindow,&stop);
                
                aboveAppDelegateWindow = YES;
                if (stop) {
                    return;
                }
                
                continue;
            }
        }
        
        block(window,aboveAppDelegateWindow,&stop);
        if (stop) {
            return;
        }
    }
}

@end
