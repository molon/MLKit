//
//  UIScrollView+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIScrollView+MLAdd.h"
#import "MLKitMacro.h"
#import "UIView+MLAdd.h"
#import "NSObject+MLAdd.h"

SYNTH_DUMMY_CLASS(UIScrollView_MLAdd)

@implementation UIScrollView (MLAdd)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(setContentInset:) with:@selector(____hookSetContentInset:)];
    });
}

- (void)____hookSetContentInset:(UIEdgeInsets)contentInset {
    [self ____hookSetContentInset:contentInset];
    
    //the scrollIndicatorInsets will always be same with contentInset
    self.scrollIndicatorInsets = contentInset;
}

- (CGFloat)contentInsetTop {
    return self.contentInset.top;
}

- (void)setContentInsetTop:(CGFloat)top {
    UIEdgeInsets inset = self.contentInset;
    if (inset.top==top) {
        return;
    }
    
    inset.top = top;
    
    CGFloat adjustOffsetY = self.contentInset.top - inset.top;
    CGPoint offset = self.contentOffset;
    self.contentInset = inset;
    
    offset.y += adjustOffsetY;
    self.contentOffset = offset;
}

- (CGFloat)contentInsetBottom {
    return self.contentInset.bottom;
}

- (void)setContentInsetBottom:(CGFloat)bottom {
    UIEdgeInsets inset = self.contentInset;
    if (inset.bottom==bottom) {
        return;
    }
    inset.bottom = bottom;
    self.contentInset = inset;
}

- (CGFloat)contentInsetLeft {
    return self.contentInset.left;
}

- (void)setContentInsetLeft:(CGFloat)left {
    UIEdgeInsets inset = self.contentInset;
    if (inset.left==left) {
        return;
    }
    
    inset.left = left;
    
    CGFloat adjustOffsetX = self.contentInset.left - inset.left;
    CGPoint offset = self.contentOffset;
    self.contentInset = inset;
    
    offset.x += adjustOffsetX;
    self.contentOffset = offset;
}

- (CGFloat)contentInsetRight {
    return self.contentInset.right;
}

- (void)setContentInsetRight:(CGFloat)right {
    UIEdgeInsets inset = self.contentInset;
    if (inset.right==right) {
        return;
    }
    inset.right = right;
    self.contentInset = inset;
}

- (CGPoint)bottomContentOffset {
    CGFloat offsetY = self.contentSize.height+self.contentInset.bottom-self.height;
    offsetY = fmax(offsetY, -self.contentInset.top);
    return CGPointMake(self.contentOffset.x, offsetY);
}

- (CGPoint)rightContentOffset {
    CGFloat offsetX = self.contentSize.width+self.contentInset.right-self.width;
    offsetX = fmax(offsetX, -self.contentInset.left);
    return CGPointMake(self.contentOffset.x, offsetX);
}

- (void)scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    [self setContentOffset:[self bottomContentOffset] animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = 0 - self.contentInset.left;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToRightAnimated:(BOOL)animated {
    [self setContentOffset:[self rightContentOffset] animated:animated];
}

- (void)scrollRectToVisibleAtMiddleOfVertical:(CGRect)rect animated:(BOOL)animated
{
    CGFloat height = self.height;
    CGFloat adjustOriginY = fmax(rect.origin.y+rect.size.height/2-height/2,-self.contentInset.top);
    if (adjustOriginY>self.contentSize.height+self.contentInset.bottom-height) {
        adjustOriginY = self.contentSize.height+self.contentInset.bottom-height;
    }
    adjustOriginY = fmax(adjustOriginY, -self.contentInset.top);
    
    [self setContentOffset:CGPointMake(0, adjustOriginY) animated:animated];
}

- (void)dodgeBottomWithHeightInWindow:(CGFloat)heightInWindow datumContentOffsetY:(CGFloat)datumContentOffsetY datumContentInsetBottom:(CGFloat)datumContentInsetBottom animated:(BOOL)animated
{
    if (!self.window) {
        return;
    }
    
    CGPoint offset = self.contentOffset;
    
    CGFloat bottomAreaOrginY = self.window.frame.size.height-heightInWindow;
    
    CGRect dodgeViewFrameInWindow = [self.superview convertRect:self.frame toView:self.window];
    CGFloat dodgeViewFrameBottomInWindow = CGRectGetMaxY(dodgeViewFrameInWindow);
    
    datumContentInsetBottom += fmax(0,dodgeViewFrameBottomInWindow-bottomAreaOrginY);
    
    offset.y = datumContentInsetBottom-(fmin(bottomAreaOrginY,dodgeViewFrameBottomInWindow)-dodgeViewFrameInWindow.origin.y);
    offset.y = fmin(offset.y, self.contentSize.height-CGRectGetHeight(dodgeViewFrameInWindow)+datumContentInsetBottom);
    offset.y = fmax(offset.y, -self.contentInset.top);
    
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = datumContentInsetBottom;
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.25f];
        [UIView setAnimationCurve:7];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.contentInset = inset;
        [self setContentOffset:offset animated:NO];
        
        [UIView commitAnimations];
    }else{
        self.contentInset = inset;
        
        [self setContentOffset:offset animated:NO];
    }
}

@end
