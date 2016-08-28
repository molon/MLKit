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

+ (BOOL)containsVisibleWindowOnMainScreenReversePassingTest:(BOOL (^)(UIWindow *window,BOOL aboveAppDelegateWindow,BOOL *stop))comparator {
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

@end
