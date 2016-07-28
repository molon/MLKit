//
//  NSNumber+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/6.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NSNumber+MLAdd.h"
#import "NSString+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(NSNumber_MLAdd)

@implementation NSNumber (MLAdd)

+ (NSNumber *)numberWithString:(NSString *)string {
    NSString *str = [[string stringByTrim] lowercaseString];
    if (!str || !str.length || str == (id)kCFNull) {
        return nil;
    }
    
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    id num = dic[str];
    if (num) {
        if (num == (id)kCFNull) return nil;
        return num;
    }
    
    const char *cstring = string.UTF8String;
    if (!cstring) return nil;
    if ([string rangeOfCharacterFromSet:dot].location != NSNotFound) {
        double num = atof(cstring);
        if (isnan(num) || isinf(num)) return nil;
        return @(num);
    } else {
        return @(atoll(cstring));
    }
}

@end
