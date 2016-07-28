//
//  NSArray+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/7.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provide some some common method for `NSArray`.
 */
@interface NSArray (MLAdd)

/**
 Returns the object located at a random index.
 
 @return The object in the array with a random index value.
 If the array is empty, returns nil.
 */
- (nullable id)randomObject;

/**
 Returns the object located at index, or return nil when out of bounds.
 It's similar to `objectAtIndex:`, but it never throw exception.
 
 @param index The object located at index.
 */
- (nullable id)objectOrNilAtIndex:(NSUInteger)index;

/**
 Get every value for keyPath of objects , returns the values
 
 @param keyPath   keyPath
 @param ignoreNil if YES, the nil value will be ignored
 
 @return values for keypath of objects
 */
- (NSArray*)valuesOfObjectsForKeyPath:(NSString*)keyPath ignoreNil:(BOOL)ignoreNil;

/**
 Get every value for keyPath of objects , returns the values.
 The nil value will be ignored.
 
 @param keyPath   keyPath
 
 @return values for keypath of objects
 */
- (NSArray*)valuesOfObjectsForKeyPath:(NSString*)keyPath;

///=============================================================================
/// @name JSON
///=============================================================================

/**
 Convert object to json data. return nil if an error occurs.
 */
- (nullable NSData *)JSONData;

/**
 Convert object to json string. return nil if an error occurs.
 */
- (nullable NSString *)JSONString;

/**
 Convert object to json string formatted. return nil if an error occurs.
 */
- (nullable NSString *)JSONPrettyString;

/**
 Returns YES if it can be converted to json
 */
- (BOOL)isValidJSONObject;

@end

/**
 Provide some some common method for `NSMutableArray`.
 */
@interface NSMutableArray (MLAdd)

/**
 Removes the object with the lowest-valued index in the array.
 If the array is empty, this method has no effect.
 
 @discussion Apple has implemented this method, but did not make it public.
 Override for safe.
 */
- (void)removeFirstObject;

/**
 Removes the object with the highest-valued index in the array.
 If the array is empty, this method has no effect.
 
 @discussion Apple's implementation said it raises an NSRangeException if the
 array is empty, but in fact nothing will happen. Override for safe.
 */
- (void)removeLastObject;

/**
 Removes and returns the object with the lowest-valued index in the array.
 If the array is empty, it just returns nil.
 
 @return The first object, or nil.
 */
- (nullable id)popFirstObject;

/**
 Removes and returns the object with the highest-valued index in the array.
 If the array is empty, it just returns nil.
 
 @return The first object, or nil.
 */
- (nullable id)popLastObject;

/**
 Adds the objects contained in another given array at the index of the receiving
 array's content.
 
 @param objects An array of objects to add to the receiving array's
 content. If the objects is empty or nil, this method has no effect.
 
 @param index The index in the array at which to insert objects. This value must
 not be greater than the count of elements in the array. Raises an
 NSRangeException if index is greater than the number of elements in the array.
 */
- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index;

/**
 Reverse the index of object in this array.
 Example: Before @[ @1, @2, @3 ], After @[ @3, @2, @1 ].
 */
- (void)reverse;

/**
 Sort the object in this array randomly.
 */
- (void)shuffle;

/**
 Remove every object which value for keyPath is nil
 
 @param keyPath keyPath
 */
- (void)removeNilValueObjectsForKeyPath:(NSString*)keyPath;

/**
 Remove every object which has same value with other object of self for keyPath
 
 @param keyPath keyPath
 */
- (void)removeDuplicateValueObjectsForKeyPath:(NSString*)keyPath;

/**
 Remove every object which has same value with a object of other objects for keyPath
 
 @param otherObjects If every object is kind of 'Model' class, then every object of the other objects must be kind of 'Model' class too.
 @param keyPath keyPath
 */
- (void)removeSameValueObjectsWithOtherObjects:(NSArray*)otherObjects forKeyPath:(NSString*)keyPath;

/**
 Remove every object which value for keyPath is nil;
 Remove every object which has same value with other object of self for keyPath;
 Remove every object which has same value with a object of other objects for keyPath;
 
 @param keyPath      keyPath
 @param otherObjects If every object is kind of 'Model' class, then every object of the other objects must be kind of 'Model' class too.
 */
- (void)removeNilAndDuplicateValueObjectsForKeyPath:(NSString*)keyPath andSameValueObjectsWithOtherObjects:(nullable NSArray*)otherObjects;

@end

NS_ASSUME_NONNULL_END
