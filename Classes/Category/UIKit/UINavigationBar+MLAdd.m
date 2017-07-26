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

- (UIView*)viewForBarItemAtIndex:(NSUInteger)index fromLeft:(BOOL)fromLeft {
    NSMutableArray *barItems = [NSMutableArray arrayWithCapacity:[self.items count]];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UINavigationButton")] && [view respondsToSelector:@selector(frame)]) {
            [barItems addObject:view];
        }
    }
    if ([barItems count] == 0) {
        return nil;
    }
    
    //sort
    [barItems sortUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        if (view1.frame.origin.x < view2.frame.origin.x) {
            return fromLeft?NSOrderedAscending:NSOrderedDescending;
        }
        if (view1.frame.origin.x > view2.frame.origin.x) {
            return fromLeft?NSOrderedDescending:NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    if (index < [barItems count]) {
        return barItems[index];
    }
    return nil;
}

@end
