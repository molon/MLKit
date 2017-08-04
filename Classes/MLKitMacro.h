//
//  MLKitMacro.h
//  MLKit
//
//  Created by molon on 16/6/6.
//  Copyright © 2016年 molon. All rights reserved.
//
#pragma once

#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <pthread.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

#ifdef __cplusplus
#define EXTERN_C_BEGIN  extern "C" {
#define EXTERN_C_END  }
#else
#define EXTERN_C_BEGIN
#define EXTERN_C_END
#endif

#pragma mark - 语法糖和便利写法
/**
 如果x超过范围了就返回范围的边界值
 */
#define CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))

/**
 返回子类强转对象，纯粹是为了码起来方便，否则写几个括号疯了
 */
#define SUBCLASS(subclass,object) ((subclass *)object)

/**
 返回SEL的字符串形式的便捷写法
 */
#define SELSTR(sel) (NSStringFromSelector(@selector(sel)))

/**
 @weakify(xxx)
 主要就是为了解除循环引用，返回__weak的对象。和@strongify(xxx)配合使用
 */
#if DEBUG
    #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
    #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#endif

/**
 @strongify(xxx)
 主要就是为了解除循环引用，返回__strong的对象。@weakify(xxx)配合使用
 */
#if DEBUG
    #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
    #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#endif

/**
 @weakify(self) 的便捷写法
 */
#define WEAK_SELF @weakify(self)

/**
 @strongify(self) 的便捷写法
 */
#define STRONG_SELF @strongify(self)

#pragma mark - 类目相关
/**
 在每个类目的implementation前添加这个宏，这样的话我们就不需要使用-all_load或者-force_load标记
 说白了就是为了让这个类能不被编译器忽略。http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 例子:
 SYNTH_DUMMY_CLASS(NSString_Add)
 */
#define SYNTH_DUMMY_CLASS(_name_) \
@interface SYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation SYNTH_DUMMY_CLASS_ ## _name_ @end

/**
 在使用runtime给类添加属性时候，对属性的setter和getter方法定义时候的便利写法
 
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) UIColor *myColor;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 SYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor:, RETAIN_NONATOMIC, UIColor *)
 @end
 */
#define SYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_)); \
}

/**
 和SYNTH_DYNAMIC_PROPERTY_OBJECT类似，但是这个是用于C类型，例如CGPoint之类的结构体，
 但是要注意一定要能转成NSValue的玩意才可以
 
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) CGPoint myPoint;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 SYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint:, CGPoint)
 @end
 */
#define SYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
_type_ cValue = { 0 }; \
NSValue *value = objc_getAssociatedObject(self, @selector(_setter_)); \
[value getValue:&cValue]; \
return cValue; \
}

#pragma mark - 便利方法
static inline NSString *MLFilePathOfBundle(NSString *bundleName,NSString *fileName,NSString *extension) {
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(bundleName)];
    NSString *bundlePath = [bundle pathForResource:bundleName ofType:@"bundle"];
    extension = [extension hasPrefix:@"."]?[extension substringFromIndex:1]:extension;
    return [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,extension]];
}

static inline UIImage *MLImageOfMLKitBundle(NSString *imageName,NSString *extension) {
    return [[UIImage alloc]initWithContentsOfFile:MLFilePathOfBundle(@"MLKit",imageName,extension)];
}

#define MLKIT_BUNDLE_PNG_IMAGE(o) MLImageOfMLKitBundle((o),@"png")

#pragma mark - 性能测试相关
/**
 测试某段代码执行花费的时间，返回的毫秒值
 Usage:
 Benchmark(^{
 // code
 }, ^(double ms) {
 DDLogDebug(@"time cost: %.2f ms",ms);
 });
 
 */
static inline void Benchmark(void (^block)(void), void (^complete)(double ms)) {
    // <sys/time.h> version
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

/**
 CocoaLumberjack
 */
#undef LOG_LEVEL_DEF // Undefine first only if needed
#define LOG_LEVEL_DEF kMLKitDLogLevel

#if DEBUG
static const DDLogLevel kMLKitDLogLevel = DDLogLevelAll;
#else
static const DDLogLevel kMLKitDLogLevel = DDLogLevelInfo;
#endif

#if DEBUG
#define DLOG_DEALLOC_SELF DDLogDebug(@"dealloc %@",self);

#define DEALLOC_SELF_DLOG \
- (void)dealloc { \
    DLOG_DEALLOC_SELF \
}
#else
#define DLOG_DEALLOC_SELF
#define DEALLOC_SELF_DLOG
#endif


