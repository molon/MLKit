//
//  NSFileManager+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/16.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provide some method for `NSFileManager`
 */
@interface NSFileManager (MLAdd)

/**
 Add NSURLIsExcludedFromBackupKey attribute to item at path
 
 @param path path
 
 @return isSuccess
 */
- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END