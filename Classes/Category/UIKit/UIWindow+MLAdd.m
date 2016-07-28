//
//  UIWindow+MLAdd.m
//  MLKitExample
//
//  Created by molon on 16/7/4.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIWindow+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(UIWindow_MLAdd)

@implementation UIWindow (MLAdd)

+ (UIWindow*)currentVisbileNormalWindow {
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows] reverseObjectEnumerator];
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    for (UIWindow *window in frontToBackWindows) {
        if (window.screen == mainScreen && window.windowLevel == UIWindowLevelNormal && !window.hidden) {
            return window;
        }
    }
    return nil;
}

@end
