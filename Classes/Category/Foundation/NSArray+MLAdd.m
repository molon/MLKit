//
//  NSArray+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/7.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NSArray+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(NSArray_MLAdd)

@implementation NSArray (MLAdd)

- (id)randomObject {
    if (self.count) {
        return self[arc4random_uniform((u_int32_t)self.count)];
    }
    return nil;
}

- (id)objectOrNilAtIndex:(NSUInteger)index {
    return index < self.count ? self[index] : nil;
}

- (NSArray*)valuesOfObjectsForKeyPath:(NSString*)keyPath ignoreNil:(BOOL)ignoreNil {
    //fast than @unionOfObjects
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id object in self) {
        id value = nil;
        @try {
            value = [object valueForKeyPath:keyPath];
        } @catch (NSException *exception) {
            DDLogError(@"%@",exception);
        }

        if (!value || value == (id)kCFNull) {
            if (ignoreNil) {
                continue;
            }else if (!value) {
                value = (id)kCFNull;
            }
        }
        [array addObject:value];
    }
    return array;
}

- (NSArray*)valuesOfObjectsForKeyPath:(NSString*)keyPath {
    return [self valuesOfObjectsForKeyPath:keyPath ignoreNil:YES];
}

- (NSData *)JSONData {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:NULL];
}

- (NSString *)JSONString {
    NSData *jsonData = [self JSONData];
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)JSONPrettyString {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (BOOL)isValidJSONObject {
    return [NSJSONSerialization isValidJSONObject:self];
}

@end

@implementation NSMutableArray (MLAdd)

- (void)removeFirstObject {
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)removeLastObject {
    if (self.count) {
        [self removeObjectAtIndex:self.count - 1];
    }
}
#pragma clang diagnostic pop

- (id)popFirstObject {
    id obj = nil;
    if (self.count) {
        obj = self.firstObject;
        [self removeFirstObject];
    }
    return obj;
}

- (id)popLastObject {
    id obj = nil;
    if (self.count) {
        obj = self.lastObject;
        [self removeLastObject];
    }
    return obj;
}

- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index {
    NSUInteger i = index;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
}

- (void)reverse {
    NSUInteger count = self.count;
    int mid = floor(count / 2.0);
    for (NSUInteger i = 0; i < mid; i++) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(count - (i + 1))];
    }
}

- (void)shuffle {
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:(i - 1)
                  withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
}

- (void)removeNilValueObjectsForKeyPath:(NSString*)keyPath {
    NSIndexSet *set = [self indexesOfObjectsPassingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop)  {
        id value = nil;
        @try {
            value = [obj valueForKeyPath:keyPath];
        } @catch (NSException *exception) {
            DDLogError(@"%@",exception);
        }
        
        return (!value || value == (id)kCFNull);
    }];
    
    [self removeObjectsAtIndexes:set];
}

- (void)removeDuplicateValueObjectsForKeyPath:(NSString*)keyPath {
    NSMutableSet *tempValues = [NSMutableSet set];
    NSIndexSet *set = [self indexesOfObjectsPassingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop)  {
        id value = nil;
        @try {
            value = [obj valueForKeyPath:keyPath];
        } @catch (NSException *exception) {
            DDLogError(@"%@",exception);
        }
        
        if (!value) {
            value = (id)kCFNull;
        }
        if ([tempValues containsObject:value]) {
            return YES;
        }
        [tempValues addObject:value];
        return NO;
    }];
    
    [self removeObjectsAtIndexes:set];
}

- (void)removeSameValueObjectsWithOtherObjects:(NSArray*)otherObjects forKeyPath:(NSString*)keyPath {
    //get all values for keyPath of other objects
    NSArray *otherValues = [otherObjects valuesOfObjectsForKeyPath:keyPath ignoreNil:NO];
    
    NSIndexSet *set = [self indexesOfObjectsPassingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop)  {
        id value = nil;
        @try {
            value = [obj valueForKeyPath:keyPath];
        } @catch (NSException *exception) {
            DDLogError(@"%@",exception);
        }

        if (!value) {
            value = (id)kCFNull;
        }
        return [otherValues containsObject:value];
    }];
    
    [self removeObjectsAtIndexes:set];
}

- (void)removeNilAndDuplicateValueObjectsForKeyPath:(NSString*)keyPath andSameValueObjectsWithOtherObjects:(NSArray*)otherObjects {
    //get all values for keyPath of other objects
    NSArray *otherValues = [otherObjects valuesOfObjectsForKeyPath:keyPath ignoreNil:YES];

    NSMutableSet *tempValues = [NSMutableSet set];
    NSIndexSet *set = [self indexesOfObjectsPassingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop)  {
        id value = nil;
        @try {
            value = [obj valueForKeyPath:keyPath];
        } @catch (NSException *exception) {
            DDLogError(@"%@",exception);
        }
        
        if (!value || value == (id)kCFNull) {
            return YES; //remove if nil
        }
        
        if ([tempValues containsObject:value]) {
            return YES;
        }
        [tempValues addObject:value];
        
        return [otherValues containsObject:value];
    }];
    
    [self removeObjectsAtIndexes:set];
}

@end
