//
//  UIBarButtonItem+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIBarButtonItem+MLAdd.h"
#import "MLKitMacro.h"
#import <objc/runtime.h>

SYNTH_DUMMY_CLASS(UIBarButtonItem_MLAdd)

static const int block_key;

@interface _MLUIBarButtonItemBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _MLUIBarButtonItemBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) self.block(sender);
}

@end


@implementation UIBarButtonItem (MLAdd)

- (void)setActionBlock:(void (^)(UIBarButtonItem *barButtonItem))block {
    _MLUIBarButtonItemBlockTarget *target = [[_MLUIBarButtonItemBlockTarget alloc] initWithBlock:block];
    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}

- (void (^)(UIBarButtonItem *barButtonItem))actionBlock {
    _MLUIBarButtonItemBlockTarget *target = objc_getAssociatedObject(self, &block_key);
    return target.block;
}

- (instancetype)initWithImage:(nullable UIImage *)image style:(UIBarButtonItemStyle)style actionBlock:(nullable void (^)(UIBarButtonItem *barButtonItem))actionBlock {
    self = [self initWithImage:image style:style target:nil action:nil];
    if (!self) {
        return nil;
    }
    
    self.actionBlock = actionBlock;
    return self;
}

- (instancetype)initWithImage:(nullable UIImage *)image landscapeImagePhone:(nullable UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style actionBlock:(nullable void (^)(UIBarButtonItem *barButtonItem))actionBlock NS_AVAILABLE_IOS(5_0) {
    self = [self initWithImage:image landscapeImagePhone:landscapeImagePhone style:style target:nil action:nil];
    if (!self) {
        return nil;
    }
    
    self.actionBlock = actionBlock;
    return self;
}

- (instancetype)initWithTitle:(nullable NSString *)title style:(UIBarButtonItemStyle)style actionBlock:(nullable void (^)(UIBarButtonItem *barButtonItem))actionBlock {
    self = [self initWithTitle:title style:style target:nil action:nil];
    if (!self) {
        return nil;
    }
    
    self.actionBlock = actionBlock;
    return self;
}

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem actionBlock:(nullable void (^)(UIBarButtonItem *barButtonItem))actionBlock {
    self = [self initWithBarButtonSystemItem:systemItem target:nil action:nil];
    if (!self) {
        return nil;
    }
    
    self.actionBlock = actionBlock;
    return self;
}

@end
