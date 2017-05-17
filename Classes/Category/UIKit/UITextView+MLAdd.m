//
//  UITextView+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UITextView+MLAdd.h"
#import "MLKitMacro.h"
#import <objc/runtime.h>
#import "NSObject+MLAdd.h"
#import "NSString+MLAdd.h"

SYNTH_DUMMY_CLASS(UITextView_MLAdd)

static inline NSArray * kUITextViewPlaceholderObserveKeys() {
    static NSArray *_kUITextViewPlaceholderObserveKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kUITextViewPlaceholderObserveKeys = @[@"attributedText",
                                               @"bounds",
                                               @"font",
                                               @"frame",
                                               @"text",
                                               @"textAlignment",
                                               @"textContainerInset"];
    });
    
    return _kUITextViewPlaceholderObserveKeys;
}

@implementation UITextView (MLAdd)

SYNTH_DYNAMIC_PROPERTY_OBJECT(placeholder, setPlaceholder:, COPY_NONATOMIC, NSString *)
SYNTH_DYNAMIC_PROPERTY_OBJECT(placeholderColor, setPlaceholderColor:, RETAIN_NONATOMIC, UIColor *)
SYNTH_DYNAMIC_PROPERTY_OBJECT(____ml_placeholderObserver, set____ml_placeholderObserver:, RETAIN_NONATOMIC, NSNumber *)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewTextChanged:) name:UITextViewTextDidChangeNotification object:nil];
        
        [self swizzleInstanceMethod:NSSelectorFromString(@"dealloc") with:@selector(____hookDealloc)];
    });
}

+ (void)textViewTextChanged:(NSNotification*)notification {
    UITextView *textView = SUBCLASS(UITextView, notification.object);
    [textView setNeedsLayout];
}

- (void)____hookDealloc {
    if ([self.____ml_placeholderObserver boolValue]) {
        for (NSString *key in kUITextViewPlaceholderObserveKeys()) {
            [self removeObserver:self forKeyPath:key];
        }
    }
    [self ____hookDealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([kUITextViewPlaceholderObserveKeys() containsObject:keyPath]) {
        [self setNeedsLayout];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
#define kUITextViewPlaceholderLabelTag 101027
    UILabel *label = [self viewWithTag:kUITextViewPlaceholderLabelTag];
    if (self.text.length<=0&&[self.placeholder isNotBlank]) {
        if (![self.____ml_placeholderObserver boolValue]) {
            for (NSString *key in kUITextViewPlaceholderObserveKeys()) {
                [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
            }
            self.____ml_placeholderObserver = @(YES);
        }
        
        if (!label) {
            label = [UILabel new];
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 0;
            label.userInteractionEnabled = NO;
            label.tag = kUITextViewPlaceholderLabelTag;
            [self addSubview:label];
        }
        
        UIColor *placeholderColor = self.placeholderColor;
        if (!placeholderColor) {
            placeholderColor = [UIColor colorWithRed:0.830 green:0.828 blue:0.865 alpha:1.000];
        }
        UIFont *font = self.font;
        if (!font) {
            font = [UIFont systemFontOfSize:16.0f];
        }
        
        label.textColor = placeholderColor;
        label.textAlignment = self.textAlignment;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = font;
        label.text = self.placeholder;
        
        CGRect frame = CGRectMake(self.contentInset.left+self.textContainerInset.left+5, self.contentInset.top+self.textContainerInset.top, self.frame.size.width-self.contentInset.left-self.textContainerInset.left-5-self.contentInset.right-self.textContainerInset.right-5, self.frame.size.height-self.contentInset.top-self.textContainerInset.top-self.contentInset.bottom-self.textContainerInset.bottom);
        frame.size.height = [label sizeThatFits:frame.size].height;
        label.frame = frame;
    }else{
        [label removeFromSuperview];
    }
    
    if (label.superview) {
        [label.superview sendSubviewToBack:label];
    }
}

@end
