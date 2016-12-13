//
//  UINavigationController+MLAdd.m
//  Pods
//
//  Created by molon on 16/8/24.
//
//

#import "UINavigationController+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(UINavigationController_MLAdd)

@implementation UINavigationController (MLAdd)

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
