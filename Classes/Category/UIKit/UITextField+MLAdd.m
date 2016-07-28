//
//  UITextField+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UITextField+MLAdd.h"
#import "MLKitMacro.h"
#import <objc/runtime.h>
#import "NSObject+MLAdd.h"
#import "NSString+MLAdd.h"

SYNTH_DUMMY_CLASS(UITextFiled_MLAdd)

@implementation UITextField (MLAdd)

SYNTH_DYNAMIC_PROPERTY_OBJECT(placeholderColor, setPlaceholderColor:, RETAIN_NONATOMIC, UIColor *)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(drawPlaceholderInRect:) with:@selector(____hookDrawPlaceholderInRect:)];
    });
}

- (void)____hookDrawPlaceholderInRect:(CGRect)rect
{
    UIColor *placeholderColor = self.placeholderColor;
    if (!placeholderColor) {
        placeholderColor = [UIColor colorWithRed:0.830 green:0.828 blue:0.865 alpha:1.000];
    }
    UIFont *font = self.font;
    if (!font) {
        font = [UIFont systemFontOfSize:16.0f];
    }
    
    CGFloat height = [self.placeholder singleLineHeightForFont:self.font];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.placeholder drawInRect:CGRectMake(0, (rect.size.height-height)/2, rect.size.width, height) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:placeholderColor, NSParagraphStyleAttributeName:paragraphStyle}];
}

- (void)selectAllText {
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

- (void)setSelectedRange:(NSRange)range {
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}

@end
