//
//  NSAttributedString+MLAdd.h
//  Pods
//
//  Created by molon on 2017/6/14.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (MLAdd)

/*!
 According a regex match result, replace it's string to display new one.
 
 @param regex regex
 @param block block
 
 @return new attributedString
 */
- (NSAttributedString*)attributedStringWithRegex:(NSRegularExpression*)regex block:(NSAttributedString*(^)(NSRange range, NSArray *groups, BOOL * _Nonnull stop))block;

@end

NS_ASSUME_NONNULL_END
