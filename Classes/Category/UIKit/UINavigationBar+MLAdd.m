//
//  UINavigationBar+MLAdd.m
//  Pods
//
//  Created by molon on 16/8/29.
//
//

#import "UINavigationBar+MLAdd.h"
#import "UIView+MLAdd.h"
#import "UIDevice+MLAdd.h"

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

- (UIButton*)buttonAtIndex:(NSUInteger)index fromLeft:(BOOL)fromLeft {
    NSMutableArray *barItems = [NSMutableArray arrayWithCapacity:[self.items count]];
    
//    if (@available(iOS 11.0, *)) {
    if (kiOS11Later){
        //这玩意比较复杂
        NSArray *(^subviewsWithClassNameBlock)(UIView *,NSString *) = ^NSArray *(UIView *v,NSString *clsName){
            NSMutableArray *vs = [NSMutableArray array];
            Class cls = NSClassFromString(clsName);
            for (UIView *subview in v.subviews) {
                if ([subview isKindOfClass:cls]){
                    [vs addObject:subview];
                }
            }
            return vs;
        };
        UIView *contentView = [subviewsWithClassNameBlock(self,@"_UINavigationBarContentView")firstObject];
        if (!contentView) {
            return nil;
        }
        //找到所有_UIButtonBarStackView _UIButtonBarButton
        NSArray *stackViews = subviewsWithClassNameBlock(contentView,@"_UIButtonBarStackView");
        //找到所有stackViews里是UIButton的玩意
        for (UIView *stackView in stackViews) {
            [barItems addObjectsFromArray:[stackView retrieveDescendantsPassingTest:^BOOL(UIView * _Nonnull v) {
                return [v isKindOfClass:[UIButton class]] && [v respondsToSelector:@selector(frame)];
            }]];
        }
    }else{
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]] && [view respondsToSelector:@selector(frame)]) {
                [barItems addObject:view];
            }
        }
    }
    if ([barItems count] == 0) {
        return nil;
    }
    
    //sort
    [barItems sortUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        CGRect frame1 = [view1.superview convertRect:view1.frame toViewOrWindow:self];
        CGRect frame2 = [view2.superview convertRect:view2.frame toViewOrWindow:self];
        
        if (frame1.origin.x < frame2.origin.x) {
            return fromLeft?NSOrderedAscending:NSOrderedDescending;
        }
        if (frame1.origin.x > frame2.origin.x) {
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
