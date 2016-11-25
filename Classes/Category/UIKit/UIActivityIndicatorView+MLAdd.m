//
//  UIActivityIndicatorView+MLAdd.m
//  Pods
//
//  Created by molon on 2016/11/25.
//
//

#import "UIActivityIndicatorView+MLAdd.h"
#import "MLKitMacro.h"
#import "NSObject+MLAdd.h"

SYNTH_DUMMY_CLASS(UIActivityIndicatorView_MLAdd)

@implementation UIActivityIndicatorView (MLAdd)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(startAnimating) with:@selector(____hookStartAnimating)];
        [self swizzleInstanceMethod:@selector(stopAnimating) with:@selector(____hookStopAnimating)];
    });
}

- (UIImageView*)____animatingImageView {
    UIImageView *imgV = nil;
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            imgV = v;
            break;
        }
    }
    return imgV;
}

- (void)____hookStartAnimating {
    [self ____hookStartAnimating];
    
    UIImageView *imageView = [self ____animatingImageView];
    if (imageView) {
        imageView.hidden = NO;
    }
}

- (void)____hookStopAnimating {
    UIImageView *imageView = [self ____animatingImageView];
    if (imageView) {
        imageView.hidden = YES;
    }else{
        [self ____hookStopAnimating];
    }
}

@end
