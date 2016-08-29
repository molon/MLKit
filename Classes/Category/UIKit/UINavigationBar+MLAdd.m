//
//  UINavigationBar+MLAdd.m
//  Pods
//
//  Created by molon on 16/8/29.
//
//

#import "UINavigationBar+MLAdd.h"

static UIImageView * ____FindHairlineImageViewUnder(UIView *view) {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = ____FindHairlineImageViewUnder(subview);
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@implementation UINavigationBar (MLAdd)

- (UIImageView *)hairlineImageView {
    return ____FindHairlineImageViewUnder(self);
}

@end
