//
//  NSObject+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/6.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MLAdd)

#pragma mark - Runtime method

/**
 Returns a Boolean value that indicates whether the receiver implements a class method that can respond to a specified message.
 @warning This function doesn't search superclasses
 @param sel sel
 
 @return YES if the receiver implements a class method that can respond to aSelector, otherwise NO.
 */
- (BOOL)respondsToSelectorWithoutSuper:(SEL)sel;

/**
 Returns a Boolean value that indicates whether the receiver implements a class method that can respond to a specified message.
 @warning This function doesn't search superclasses
 @param sel sel
 
 @return YES if the receiver implements a class method that can respond to aSelector, otherwise NO.
 */
+ (BOOL)respondsToSelectorWithoutSuper:(SEL)sel;

/**
 Returns a Boolean value that indicates whether instances of the receiver are capable of responding to a given selector.
 @warning This function doesn't search superclasses
 
 @param aSelector aSelector
 
 @return YES if instances of the receiver are capable of responding to aSelector messages, otherwise NO.
 */
+ (BOOL)instancesRespondToSelectorWithoutSuper:(SEL)aSelector;

/**
 Swap two instance method's implementation in one class. 
 @warning Can't swizzle instance methods of superclass.
 
 @param originalSel   Selector 1.
 @param newSel        Selector 2.
 @return              YES if swizzling succeed; otherwise, NO.
 */
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;

/**
 Swap two class method's implementation in one class. Dangerous, be careful.
 @warning Can't swizzle class methods of superclass.
 
 @param originalSel   Selector 1.
 @param newSel        Selector 2.
 @return              YES if swizzling succeed; otherwise, NO.
 */
+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

#pragma mark - Deep copy
///=============================================================================
/// @name Deep copy
///=============================================================================

/**
 Returns a copy of the instance with `NSKeyedArchiver` and ``NSKeyedUnarchiver``.
 Returns nil if an error occurs.
 */
- (nullable id)deepCopy;

/**
 Returns a copy of the instance use archiver and unarchiver.
 Returns nil if an error occurs.
 
 @param archiver   NSKeyedArchiver class or any class inherited.
 @param unarchiver NSKeyedUnarchiver clsas or any class inherited.
 */
- (nullable id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver;

@end

NS_ASSUME_NONNULL_END