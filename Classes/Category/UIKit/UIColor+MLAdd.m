//
//  UIColor+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIColor+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(UIColor_MLAdd)

/**
 If you want to get color with color format
 The singleton can find whether a color with same format exist.
 If exist, just return it ,dont need to recreate.
 The singleton doesn't retain any color.
 */
@interface _UIColor_MLAdd_Record : NSObject

@end

@implementation _UIColor_MLAdd_Record {
    NSMapTable *_mapTable;
}

+ (instancetype)record {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self class] new];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mapTable = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

- (void)addRecordWithFormat:(NSString*)format color:(UIColor*)color {
    [_mapTable setObject:color forKey:format];
}

- (UIColor*)colorWithFormat:(NSString*)format {
    return [_mapTable objectForKey:format];
}

@end

@implementation UIColor (MLAdd)

+ (UIColor*)colorWithFormat:(NSString*)format {
    UIColor *color = [[_UIColor_MLAdd_Record record]colorWithFormat:format];
    if (color) {
        return color;
    }
    
    if ([format hasPrefix:@"{"]||[format hasPrefix:@"["]){
        color = [[self class] colorWithFloatStringFormat:format];
    }else{
        color = [[self class] colorWithHexStringFormat:format];
    }
    
    [[_UIColor_MLAdd_Record record] addRecordWithFormat:format color:color];
    
    return color;
}

+ (UIColor*)colorWithFloatStringFormat:(NSString*)string {
    BOOL isCalced = NO; //是否还需要/255.0,中括号的不需要，大括号的需要
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    if (![scanner scanString:@"{" intoString:NULL]){
        if (![scanner scanString:@"[" intoString:NULL]) {
            return nil;
        }
        isCalced = YES;
    }
    const NSUInteger kMaxComponents = 4;
    float c[kMaxComponents];
    NSUInteger i = 0;
    if (![scanner scanFloat:&c[i++]]) return nil;
    while (1) {
        if ([scanner scanString:isCalced?@"]":@"}" intoString:NULL]) break;
        if (i >= kMaxComponents) return nil;
        if ([scanner scanString:@"," intoString:NULL]) {
            if (![scanner scanFloat:&c[i++]]) return nil;
        } else {
            // either we're at the end of there's an unexpected character here
            // both cases are error conditions
            return nil;
        }
    }
    if (![scanner isAtEnd]) return nil;
    
    for (NSInteger t=0; t<i&&t<3; t++) {
        if (!isCalced) {
            c[t] = c[t]/255.0f;
        }
    }
    
    UIColor *color;
    switch (i) {
        case 1:
            color = [UIColor colorWithRed:c[0] green:c[0] blue:c[0] alpha:1];
            break;
        case 2: // monochrome
            color = [UIColor colorWithWhite:c[0] alpha:c[1]];
            break;
        case 3:
            color = [UIColor colorWithRed:c[0] green:c[1] blue:c[2] alpha:1];
            break;
        case 4: // RGB
            color = [UIColor colorWithRed:c[0] green:c[1] blue:c[2] alpha:c[3]];
            break;
        default:
            color = nil;
    }
    return color;
    
}


+ (UIColor *)colorWithHexStringFormat:(NSString *)stringToConvert {
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return nil;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    NSInteger length = [cString length];
    if (length < 6) return nil;
    
    // Separate into r, g, b, a substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    NSString *aString = @"1.000";
    if (length>6) {
        range.location = 6;
        range.length = length-6;
        aString = [cString substringWithRange:range];
    }
    
    // Scan values
    unsigned int r, g, b;
    float a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    [[NSScanner scannerWithString:aString] scanFloat:&a];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:a];
}

@end
