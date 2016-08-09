//
//  NSURLRequest+MLAdd.h
//  Pods
//
//  Created by molon on 16/8/9.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (MLAdd)

/**
 Returns curl command string which has `--dump-header -`
 */
- (NSString *)cURLCommandString;

/**
 Returns curl command string
 
 @param dumpHeader whether add `--dump-header -`
 @param jsonPP     whether add `| json_pp`
 
 @return curl command string
 */
- (NSString *)cURLCommandStringWithDumpHeader:(BOOL)dumpHeader jsonPP:(BOOL)jsonPP;

@end

NS_ASSUME_NONNULL_END