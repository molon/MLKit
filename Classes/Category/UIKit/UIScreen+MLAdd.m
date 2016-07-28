//
//  UIScreen+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIScreen+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(UIScreen_MLAdd);

static CGFloat ____screenScale;
static CGSize ____screenSize;

@implementation UIScreen (MLAdd)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ____screenScale = [UIScreen mainScreen].scale;
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (screenSize.height < screenSize.width) {
            CGFloat tmp = screenSize.height;
            screenSize.height = screenSize.width;
            screenSize.width = tmp;
        }
        ____screenSize = screenSize;
    });
}

+ (CGFloat)screenScale {
    return ____screenScale;
}

+ (CGSize)screenSize {
    return ____screenSize;
}

- (CGRect)currentBounds {
    return [self boundsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation {
    CGRect bounds = [self bounds];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat buffer = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = buffer;
    }
    return bounds;
}

@end

