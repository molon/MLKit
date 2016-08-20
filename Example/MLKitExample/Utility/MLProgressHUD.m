//
//  MLProgressHUD.m
//  XQ_SDB
//
//  Created by molon on 16/8/18.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLProgressHUD.h"

@interface MLProgressHUD()

@end

@implementation MLProgressHUD

#pragma mark - for scrollView
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        //remove kvo
        [self.superview removeObserver:self forKeyPath:@"contentOffset" context:nil];
        
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView*)self.superview).userInteractionEnabled = YES;
        }
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        //add kvo
        [self.superview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
        
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            self.superview.userInteractionEnabled = !self.userInteractionEnabled;
        }
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([@"contentOffset" isEqualToString:keyPath]) {
        UIScrollView *scrollView = (UIScrollView*)self.superview;
        self.frame = scrollView.bounds;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

#pragma mark - fix bug of MBProgressHUD `updateForCurrentOrientationAnimated:`
- (void)setBounds:(CGRect)bounds {
    bounds.origin = CGPointZero;
    [super setBounds:bounds];
}

#pragma mark - set
- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView*)self.superview).userInteractionEnabled = !userInteractionEnabled;
    }
}

#pragma mark - outcall
+ (instancetype)showOnView:(UIView*)view message:(nullable NSString*)message detailMessage:(nullable NSString*)detailMessage customView:(nullable UIView*)customView userInteractionEnabled:(BOOL)userInteractionEnabled yOffset:(CGFloat)yOffset hideDelay:(NSTimeInterval)hideDelay {
    NSAssert(view,@"`view` cant be nil -> %@",NSStringFromSelector(_cmd));
    if (!view) {
        return nil;
    }
    
    MLProgressHUD *hud = [[self class] showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.696];
    
    hud.userInteractionEnabled = userInteractionEnabled;
    
    CGPoint offset = hud.offset;
    offset.y = yOffset;
    hud.offset = offset;
    
    if (customView) {
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = customView;
    }else{
        hud.mode = MBProgressHUDModeText;
    }
    
    if (message.length>0) {
        hud.label.text = message;
    }
    if (detailMessage.length>0) {
        hud.detailsLabel.text = detailMessage;
    }
    
    [hud hideAnimated:YES afterDelay:hideDelay];
    
    return hud;
}

+ (instancetype)showIndeterminateHUDOnView:(UIView*)view message:(nullable NSString*)message detailMessage:(nullable NSString*)detailMessage yOffset:(CGFloat)yOffset {
    NSAssert(view,@"`view` cant be nil -> %@",NSStringFromSelector(_cmd));
    if (!view) {
        return nil;
    }
    
    MBProgressHUD *hud = [[self class]HUDForView:view];
    if (hud&&hud.mode == MBProgressHUDModeIndeterminate) {
        NSAssert([hud isKindOfClass:[MLProgressHUD class]], @"Please only use MLProgressHUD!");
        return (MLProgressHUD*)hud;
    }
    
    hud = [[self class] showHUDAddedTo:view animated:YES];
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.696];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    CGPoint offset = hud.offset;
    offset.y = yOffset;
    hud.offset = offset;
    
    if (message.length>0) {
        hud.label.text = message;
    }
    if (detailMessage.length>0) {
        hud.detailsLabel.text = detailMessage;
    }
    
    return (MLProgressHUD*)hud;
}

+ (NSInteger)hideIndeterminateHUDsOnView:(UIView*)view {
    NSAssert(view,@"`view` cant be nil -> %@",NSStringFromSelector(_cmd));
    if (!view) {
        return 0;
    }
    
    NSInteger count = 0;
    for (UIView *aView in view.subviews) {
        if ([aView isKindOfClass:[MBProgressHUD class]]) {
            MBProgressHUD *hud = (MBProgressHUD *)aView;
            if (hud.mode == MBProgressHUDModeIndeterminate) {
                hud.removeFromSuperViewOnHide = YES;
                [hud hideAnimated:YES];
                count++;
            }
        }
    }
    
    return count;
}
@end
