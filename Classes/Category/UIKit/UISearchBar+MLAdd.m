//
//  UISearchBar+MLAdd.m
//  Pods
//
//  Created by molon on 16/8/28.
//
//

#import "UISearchBar+MLAdd.h"
#import "MLKitMacro.h"
#import "NSObject+MLAdd.h"
#import <objc/runtime.h>

SYNTH_DUMMY_CLASS(UISearchBar_MLAdd)

@implementation UISearchBar (MLAdd)

SYNTH_DYNAMIC_PROPERTY_CTYPE(enableCancelButtonAfterResignFirstResponder, setEnableCancelButtonAfterResignFirstResponder:, BOOL)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(resignFirstResponder) with:@selector(____hookResignFirstResponder)];
    });
}

- (void)____hookResignFirstResponder {
    [self ____hookResignFirstResponder];
    
    if (self.enableCancelButtonAfterResignFirstResponder) {
        for (UIView *view in self.subviews) {
            for (id subview in view.subviews) {
                if ([subview isKindOfClass:[UIButton class]]) {
                    [subview setEnabled:YES];
                    return;
                }
            }
        }
    }
}

@end
