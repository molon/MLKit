//
//  UITabBar+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UITabBar+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(UITabBar_MLAdd)

@implementation UITabBar (MLAdd)

//http://stackoverflow.com/a/17435146
- (UIView*)viewForTabBarItemAtIndex:(NSUInteger)index
{
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:[self.items count]];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")] && [view respondsToSelector:@selector(frame)]) {
            [tabBarItems addObject:view];
        }
    }
    if ([tabBarItems count] == 0) {
        return nil;
    }
    
    //sort
    [tabBarItems sortUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        if (view1.frame.origin.x < view2.frame.origin.x) {
            return NSOrderedAscending;
        }
        if (view1.frame.origin.x > view2.frame.origin.x) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    if (index < [tabBarItems count]) {
        UIView *tabView = tabBarItems[index];
        if ([tabView respondsToSelector:@selector(frame)]) {
            return tabView;
        }
    }else {
        //Because of dispaly count of tabBars must <=5, the more tabBarItem will be moved in more style tabBar.
        //So we return the last display tabBar
        UIView *tabView = [tabBarItems lastObject];
        if ([tabView respondsToSelector:@selector(frame)]) {
            return tabView;
        }
    }
    return nil;
}

@end
