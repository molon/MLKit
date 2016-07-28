//
//  MLDelegateProxy.m
//  MLKitExample
//
//  Created by molon on 16/7/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLDelegateProxy.h"

@implementation MLDelegateProxy {
    id <MLDelegateProxyInterceptor> __weak _interceptor;
    id <NSObject> __weak _target;
}

- (instancetype)initWithTarget:(id <NSObject>)target interceptor:(id <MLDelegateProxyInterceptor>)interceptor
{
    // -[NSProxy init] is undefined
    if (!self) {
        return nil;
    }
    
    NSAssert(interceptor, @"interceptor must not be nil");
    
    _target = target ? : [NSNull null];
    _interceptor = interceptor;
    
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self interceptsSelector:aSelector]) {
        return [_interceptor respondsToSelector:aSelector];
    } else {
        // Also return NO if _target has become nil due to zeroing weak reference (or placeholder initialization).
        return [_target respondsToSelector:aSelector];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self interceptsSelector:aSelector]) {
        return _interceptor;
    } else {
        if (_target) {
            return [_target respondsToSelector:aSelector] ? _target : nil;
        } else {
            // The _interceptor needs to be nilled out in this scenario. For that a strong reference needs to be created
            // to be able to nil out the _interceptor but still let it know that the proxy target has deallocated
            // We have to hold a strong reference to the interceptor as we have to nil it out and call the proxyTargetHasDeallocated
            // The reason that the interceptor needs to be nilled out is that there maybe a change of a infinite loop, for example
            // if a method will be called in the proxyTargetHasDeallocated: that again would trigger a whole new forwarding cycle
            id <MLDelegateProxyInterceptor> interceptor = _interceptor;
            _interceptor = nil;
            [interceptor proxyTargetHasDeallocated:self];
            
            return nil;
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // Check for a compiled definition for the selector
    NSMethodSignature *methodSignature = nil;
    if ([self interceptsSelector:aSelector]) {
        methodSignature = [[_interceptor class] instanceMethodSignatureForSelector:aSelector];
    } else {
        methodSignature = [[_target class] instanceMethodSignatureForSelector:aSelector];
    }
    
    // Unfortunately, in order to get this object to work properly, the use of a method which creates an NSMethodSignature
    // from a C string. -methodSignatureForSelector is called when a compiled definition for the selector cannot be found.
    // This is the place where we have to create our own dud NSMethodSignature. This is necessary because if this method
    // returns nil, a selector not found exception is raised. The string argument to -signatureWithObjCTypes: outlines
    // the return type and arguments to the message. To return a dud NSMethodSignature, pretty much any signature will
    // suffice. Since the -forwardInvocation call will do nothing if the delegate does not respond to the selector,
    // the dud NSMethodSignature simply gets us around the exception.
    return methodSignature ?: [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // If we are down here this means _interceptor and _target where nil. Just don't do anything to prevent a crash
}

- (BOOL)interceptsSelector:(SEL)selector
{
    NSAssert(NO, @"This method must be overridden by subclasses.");
    return NO;
}

@end
