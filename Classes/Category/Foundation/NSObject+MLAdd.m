//
//  NSObject+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/6.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NSObject+MLAdd.h"
#import "MLKitMacro.h"
#import <objc/objc.h>
#import <objc/runtime.h>

SYNTH_DUMMY_CLASS(NSObject_MLAdd)

static inline BOOL class_respondsToSelectorWithoutSuper (Class cls,SEL sel) {
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        for (unsigned int i = 0; i < methodCount; i++) {
            if (sel == method_getName(methods[i])){
                return YES;
            }
        }
        free(methods);
    }
    return NO;
}

@implementation NSObject (MLAdd)

- (BOOL)respondsToSelectorWithoutSuper:(SEL)sel {
    Class class = object_getClass(self);
    return class_respondsToSelectorWithoutSuper(class,sel);
}

+ (BOOL)respondsToSelectorWithoutSuper:(SEL)sel {
    Class class = object_getClass(self);
    return class_respondsToSelectorWithoutSuper(class,sel);
}

+ (BOOL)instancesRespondToSelectorWithoutSuper:(SEL)aSelector {
    return class_respondsToSelectorWithoutSuper(self,aSelector);
}

+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    NSAssert([self instancesRespondToSelectorWithoutSuper:originalSel],
             @"Can't swizzle instance method of superclass->%@, please inherit it directly!",NSStringFromSelector(originalSel));
    NSAssert([self instancesRespondToSelectorWithoutSuper:newSel],
             @"Can't swizzle instance method of superclass->%@, please inherit it directly!",NSStringFromSelector(newSel));
    
    method_exchangeImplementations(originalMethod,
                                   newMethod);
    return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getClassMethod(self, originalSel);
    Method newMethod = class_getClassMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    NSAssert([self respondsToSelectorWithoutSuper:originalSel],
             @"Can't swizzle class method of superclass->%@, please inherit it directly!",NSStringFromSelector(originalSel));
    NSAssert([self respondsToSelectorWithoutSuper:newSel],
             @"Can't swizzle class method of superclass->%@, please inherit it directly!",NSStringFromSelector(newSel));
    
    method_exchangeImplementations(originalMethod, newMethod);
    return YES;
}

- (id)deepCopy
{
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        DDLogError(@"%@",exception);
    }
    return obj;
}

- (id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver
{
    id obj = nil;
    @try {
        obj = [unarchiver unarchiveObjectWithData:[archiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        DDLogError(@"%@",exception);
    }
    return obj;
}

- (NSDictionary *)callerMessage {
#ifdef DEBUG
    NSArray *symbols = [NSThread callStackSymbols];
    if (symbols.count<3) {
        return nil;
    }
    NSString *sourceString = symbols[2];
    if (sourceString.length<=0) {
        return nil;
    }
    
    NSRange range = [sourceString rangeOfString:@"["];
    if (range.length<=0||range.location<=0) {
        return nil;
    }
    
    BOOL isInstance = [[sourceString substringWithRange:NSMakeRange(range.location-1,1)] isEqualToString:@"+"];
    
    sourceString = [sourceString substringFromIndex:range.location+1];
    
    range = [sourceString rangeOfString:@"]"];
    if (range.length<=0) {
        return nil;
    }
    sourceString = [sourceString substringToIndex:range.location];
    
    NSMutableArray *array = [[sourceString componentsSeparatedByString:@" "]mutableCopy];
    if (array.count!=2) {
        return nil;
    }
    
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    
    range = [array[0] rangeOfString:@"("];
    if (range.length>0) {
        NSString *categoryName = [array[0] substringWithRange:NSMakeRange(range.location+1, ((NSString*)array[0]).length-(range.location+1)-1)];
        message[@"Category"] = categoryName;
        
        
        array[0] = [array[0] substringToIndex:range.location];
    }
    message[@"Class"] = NSClassFromString(array[0]);
    message[@"Method"] = array[1];
    message[@"IsInstance"] = @(isInstance);
    
    return message;
#else
    return nil;
#endif
}

@end
