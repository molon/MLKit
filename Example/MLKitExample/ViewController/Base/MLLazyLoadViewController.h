//
//  MLLazyLoadViewController.h
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLListViewController.h"
#import "MLLazyLoadTableView.h"

NS_ASSUME_NONNULL_BEGIN

@class MLLazyLoadTableViewCell,LazyLoadAPIHelper;
@interface MLLazyLoadViewController : MLListViewController

@property (nonatomic, strong, readonly) MLLazyLoadTableView *tableView;
@property (nonatomic, assign) NSInteger currentPageNo;

#pragma mark - config
- (BOOL)autoRefreshWhenFirstDidAppear;
- (BOOL)autoEnableMLRefreshControl;
- (BOOL)autoObserveFirstRequest;

- (nullable NSString*)configureKeyOfEntryIDForDeduplication;
- (NSInteger)configureLazyLoadSection;
- (NSInteger)configureExceptTopRowCount;
- (nullable MLLazyLoadTableViewCell*)configureLazyLoadCell;

- (nullable UIView*)configureBackgroundViewIfEmptyList;

- (LazyLoadAPIHelper *)lazyLoadHelperWithRefreshing:(BOOL)refreshing;

#pragma mark - for override
- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper  __attribute__((objc_requires_super));
- (void)afterRequestFailed:(MLAPIHelper *)apiHelper  __attribute__((objc_requires_super));

#pragma mark - operations
- (void)deleteRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsInLazyLoadSectionWithEntryID:(nullable id)entryID rowAnimation:(UITableViewRowAnimation)animation;

- (void)reloadRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation;
- (void)replaceEntriesAndReloadRowsWithEntry:(id)entry rowAnimation:(UITableViewRowAnimation)animation;

@end

NS_ASSUME_NONNULL_END
