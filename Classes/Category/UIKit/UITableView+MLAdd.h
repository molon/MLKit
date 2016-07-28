//
//  UITableView+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UITableView`.
 */
@interface UITableView (MLAdd)

/**
 Perform a series of method calls that insert, delete, or select rows and
 sections of the receiver.
 
 @discussion Perform a series of method calls that insert, delete, or select
 rows and sections of the table. Call this method if you want
 subsequent insertions, deletion, and selection operations (for
 example, cellForRowAtIndexPath: and indexPathsForVisibleRows)
 to be animated simultaneously.
 
 @discussion If you do not make the insertion, deletion, and selection calls
 inside this block, table attributes such as row count might become
 invalid. You should not call reloadData within the block; if you
 call this method within the group, you will need to perform any
 animations yourself.
 
 @param block  A block combine a series of method calls.
 */
- (void)updateWithBlock:(void (^)(UITableView *tableView))block;

/**
 Return screenshot excluding headerview/footerview or not
 
 @param excludingHeaderView excludingHeaderView
 @param excludingFooterView excludingFooterView
 
 @return screenshot
 */
- (nullable UIImage *)screenshotExcludingHeaderView:(BOOL)excludingHeaderView
                       excludingFooterView:(BOOL)excludingFooterView;
/**
 Return screenshot excluding (headerview/footerview or not) (HeadersAtSections/FootersAtSections or not) (rows or not)
 
 @param excludedHeaderSections excludedHeaderSections
 @param excludedFooterSections excludedFooterSections
 @param excludedIndexPaths     excludedIndexPaths
 @param excludingHeaderView    excludingHeaderView
 @param excludingFooterView    excludingFooterView
 
 @return screenshot
 */
- (nullable UIImage *)screenshotExcludingHeadersAtSections:(nullable NSSet *)excludedHeaderSections
                       excludingFootersAtSections:(nullable NSSet *)excludedFooterSections
                        excludingRowsAtIndexPaths:(nullable NSSet *)excludedIndexPaths
                              excludingHeaderView:(BOOL)excludingHeaderView
                              excludingFooterView:(BOOL)excludingFooterView;

@end

NS_ASSUME_NONNULL_END