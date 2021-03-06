//
//  UIViewController+MLAdd.m
//  MLKitExample
//
//  Created by molon on 16/7/2.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIViewController+MLAdd.h"
#import "MLKitMacro.h"
#import "UIDevice+MLAdd.h"
#import "NSObject+MLAdd.h"

SYNTH_DUMMY_CLASS(UIViewController_MLAdd)

@implementation UIViewController (MLAdd)

+ (instancetype)instanceFromNib {
    Class cls = [self class];
    return [[self alloc]initWithNibName:NSStringFromClass(cls) bundle:[NSBundle bundleForClass:cls]];
}

+ (CGFloat)statusBarHeight {
    if ([UIDevice currentDevice].isFullScreenDevice) {
        CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
        return [UIApplication sharedApplication].statusBarHidden?0.0f:fmin(statusBarSize.width, statusBarSize.height);
    }
    
    // When a tel call comes in, the statusBarHeight should be 40.0f
    // But but !! if use 40, the view's height will be reduced by 20 simultaneously.
    // So always using 20 is well.
    return [UIApplication sharedApplication].statusBarHidden?0.0f:20.0f;
}

- (CGFloat)navigationBarBottom {
    if (kSystemVersion<7.0f) {
        return 0.0f;
    }
    
    //we only care about the child of navigationController
    if (!self.navigationController||![self.navigationController isEqual:self.parentViewController]) {
        return 0.0f;
    }
    if (!self.navigationController.navigationBar.translucent) {
        return 0.0f;
    }
    if (self.navigationController.navigationBarHidden) {
        return 0.0f;
    }
    //如果prefersStatusBarHidden为true，则直接为0.0f，此时有可能[UIApplication sharedApplication].statusBarHidden还未变成true呢
    return (self.prefersStatusBarHidden?0.0f:[UIViewController statusBarHeight]) + self.navigationController.navigationBar.intrinsicContentSize.height;
}

- (CGFloat)tabBarOccupiedHeight {
    if (kSystemVersion<7.0f) {
        return 0.0f;
    }
    if (!self.tabBarController) {
        return 0.0f;
    }
    if (!self.tabBarController.tabBar.translucent) {
        return 0.0f;
    }
    if (self.hidesBottomBarWhenPushed) {
        return 0.0f;
    }
    return self.tabBarController.tabBar.intrinsicContentSize.height;
}

- (UIViewController*)topVisibleViewController {
    UIViewController *vc = self;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    
    while ([vc isKindOfClass:[UINavigationController class]]||
           [vc isKindOfClass:[UITabBarController class]]) {
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [((UINavigationController*)vc) topViewController];
        }else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)self).selectedViewController;
        }
    }
    
    return vc;
}

- (UIViewController*)topPresentedViewController {
    UIViewController *vc = self;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

- (UIViewController*)topParentViewController {
    UIViewController *topParentViewController = self;
    while (topParentViewController.parentViewController!=nil) {
        topParentViewController = topParentViewController.parentViewController;
    }
    return topParentViewController;
}

- (void)disappear {
    //If locate in a navigationController and self is the first child of naviagtionController. just dismiss the navigationController. othewise pop.
    //If not locate in a navigationController,just dismiss self.
    if ([self.navigationController.presentingViewController.presentedViewController isEqual:self.navigationController]&&[[self.navigationController.viewControllers firstObject]isEqual:self]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        if ([self.presentingViewController.presentedViewController isEqual:self]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if(self.navigationController.viewControllers.count>1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//- (BOOL)hidesBottomBarWhenPushed {
//    //nav除了第一个页面，后面的都自动hide bottom
//    if (!self.navigationController) {
//        return NO;
//    }
//    
//    UIViewController *vc = self;
//    while (![self.navigationController isEqual:vc.parentViewController]) {
//        vc = vc.parentViewController;
//    }
//    
//    return [[self.navigationController.viewControllers firstObject] isEqual:vc]?NO:[self.navigationController.topViewController isEqual:vc];
//}

+ (void)validateNoBackTitleForNavigationBar {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController swizzleInstanceMethod:@selector(viewDidLoad) with:@selector(____hookViewDidLoad)];
    });
}

- (void)____hookViewDidLoad {
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    [self ____hookViewDidLoad];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(prefersStatusBarHidden) with:@selector(____hookPrefersStatusBarHidden)];
    });
}

- (BOOL)____hookPrefersStatusBarHidden {
    return NO;
}

@end
