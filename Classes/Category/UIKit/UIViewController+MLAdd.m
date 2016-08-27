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
    //    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    //    return [UIApplication sharedApplication].statusBarHidden?0.0f:fmin(statusBarSize.width, statusBarSize.height);
    
    // When a tel call comes in, the statusBarHeight should be 40.0f
    // But but !! if use 40, the view's height will be reduced by 20 simultaneously.
    // So always using 20 is well.
    return 20.0f;
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
    return ([UIApplication sharedApplication].statusBarHidden?0.0f:[UIViewController statusBarHeight]) + self.navigationController.navigationBar.intrinsicContentSize.height;
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
    UIViewController *presentedVC = self;
    while (presentedVC.presentedViewController) {
        presentedVC = presentedVC.presentedViewController;
    }
    if ([presentedVC isEqual:self]) {
        if ([self isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController*)self) topViewController];
        }else if ([self isKindOfClass:[UITabBarController class]]) {
            return ((UITabBarController*)self).selectedViewController;
        }
    }
    return presentedVC;
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

@end
