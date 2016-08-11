//
//  MLLazyLoadViewController.h
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLLazyLoadTableView,MLLazyLoadTableViewCell,LazyLoadAPIHelper;
@interface MLLazyLoadViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong, readonly) MLLazyLoadTableView *tableView;
@property (nonatomic, assign, readonly) NSInteger currentPageNo;

#pragma mark - config
- (BOOL)autoRefreshAtFirstDidAppear;
- (nullable NSString*)keyOfEntryIDForDeduplication;

- (NSInteger)lazyLoadSection;
- (NSInteger)exceptTopRowCount;
- (nullable MLLazyLoadTableViewCell*)lazyLoadCell;
- (LazyLoadAPIHelper *)lazyLoadHelperWithRefreshing:(BOOL)refreshing;

#pragma mark - for override
- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper  __attribute__((objc_requires_super));
- (void)afterRequestFailed:(MLAPIHelper *)apiHelper  __attribute__((objc_requires_super));

@end

NS_ASSUME_NONNULL_END
