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

@implementation UITextView (MLAdd)

SYNTH_DYNAMIC_PROPERTY_OBJECT(placeholder, setPlaceholder:, COPY_NONATOMIC, NSString *)
SYNTH_DYNAMIC_PROPERTY_OBJECT(placeholderColor, setPlaceholderColor:, RETAIN_NONATOMIC, UIColor *)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewTextChanged:) name:UITextViewTextDidChangeNotification object:nil];
    });
}

+ (void)textViewTextChanged:(NSNotification*)notification
{
    UITextView *textView = SUBCLASS(UITextView, notification.object);
    if (textView.placeholder.length>0) {
        [textView setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.text.length<=0) {
        //the placeholder will not follow scrolling
        UIColor *placeholderColor = self.placeholderColor;
        if (!placeholderColor) {
            placeholderColor = [UIColor colorWithRed:0.830 green:0.828 blue:0.865 alpha:1.000];
        }
        UIFont *font = self.font;
        if (!font) {
            font = [UIFont systemFontOfSize:16.0f];
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = self.textAlignment;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        [self.placeholder drawInRect:CGRectMake(self.contentInset.left+self.textContainerInset.left+5, self.contentInset.top+self.textContainerInset.top, self.frame.size.width-self.contentInset.left-self.textContainerInset.left-5, self.frame.size.height-self.contentInset.top-self.textContainerInset.top) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:placeholderColor, NSParagraphStyleAttributeName:paragraphStyle}];
    }
}

@end
