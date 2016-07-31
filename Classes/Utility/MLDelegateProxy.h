//
//  MLDelegateProxy.h
//  MLKitExample
//
//  Created by molon on 16/7/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 Copy from ASyncDisplayKit
 */

@class MLDelegateProxy;
@protocol MLDelegateProxyInterceptor <NSObject>
@required
// Called if the target object is discovered to be nil if it had been non-nil at init time.
// This happens if the object is deallocated, because the proxy must maintain a weak reference to avoid cycles.
// Though the target object may become nil, the interceptor must not; it is assumed the interceptor owns the proxy.
- (void)proxyTargetHasDeallocated:(MLDelegateProxy *)proxy;
@end

/**
 * Stand-in for delegates like UITableView or UICollectionView's delegate / dataSource.
 * Any selectors flagged by "interceptsSelector" are routed to the interceptor object and are not delivered to the target.
 */
@interface MLDelegateProxy : NSProxy

- (instancetype)initWithTarget:(nullable id <NSObject>)target interceptor:(id <MLDelegateProxyInterceptor>)interceptor;

/**
 This method must be overridden by a subclass.
 
 @param selector selector
 
 @return whether intercept
 */
- (BOOL)interceptsSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END