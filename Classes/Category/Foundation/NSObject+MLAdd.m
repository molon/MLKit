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
             @"Can't swizzle instance method of superclass:%@",NSStringFromSelector(originalSel));
    NSAssert([self instancesRespondToSelectorWithoutSuper:newSel],
             @"Can't swizzle instance method of superclass:%@",NSStringFromSelector(newSel));
    
    method_exchangeImplementations(originalMethod,
                                   newMethod);
    return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getClassMethod(self, originalSel);
    Method newMethod = class_getClassMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    NSAssert([self respondsToSelectorWithoutSuper:originalSel],
             @"Can't swizzle class method of superclass:%@",NSStringFromSelector(originalSel));
    NSAssert([self respondsToSelectorWithoutSuper:newSel],
             @"Can't swizzle class method of superclass:%@",NSStringFromSelector(newSel));
    
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

@end
