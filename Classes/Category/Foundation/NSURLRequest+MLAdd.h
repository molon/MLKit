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
 Returns curl command string
 @warning `dumpHeader` and `jsonPP` cant be YES simultaneously!
 
 @param dumpHeader whether add `--dump-header -`
 @param jsonPP     whether add `| json_pp`
 
 @return curl command string
 */
- (NSString*)curlCommandWithDumpHeader:(BOOL)dumpHeader jsonPP:(BOOL)jsonPP;

@end

NS_ASSUME_NONNULL_END
