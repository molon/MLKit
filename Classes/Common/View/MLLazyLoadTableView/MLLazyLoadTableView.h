//
//  MLLazyLoadTableView.h
//  TycoonBuy
//
//  Created by molon on 16/4/18.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <MLLayout/MLAutoRecordFrameTableView.h>

NS_ASSUME_NONNULL_BEGIN

@class MLAPIHelper,MLLazyLoadTableViewCell;

@interface MLLazyLoadTableView : MLAutoRecordFrameTableView

/**
 proxy of delegate
 */
@property (nonatomic, weak, nullable) id<UITableViewDelegate> proxyDelegate;

/**
 proxy of data source
 */
@property (nonatomic, weak) id<UITableViewDataSource> proxyDataSource;

/**
 entries for rows
 */
@property (nonatomic, strong, readonly) NSMutableArray *entries;

/**
 whether request for refreshing
 */
@property (nonatomic, assign, readonly) BOOL refreshing;

/**
 cell for indicating lazy-loading status
 */
@property (nonatomic, strong, readonly) MLLazyLoadTableViewCell *lazyLoadCell;

/**
 the section for lazy-loading
 */
@property (nonatomic, assign, readonly) NSInteger lazyLoadSection;

/**
 the top row count of lazy-loading section which will be ignored for lazy-loading
 */
@property (nonatomic, assign, readonly) NSInteger exceptTopRowCount;

/**
 the last requesting api helper for requesting.
 @note: we will check it in `requestCompletedWithRequestSign:success:pageData:loadedAll:`, if not equal, we will do nothing and return right now.
 */
@property (nonatomic, strong, readonly, nullable) MLAPIHelper *requestingAPIHelper;

/**
 block for requesting, must return the api helper for requesting
 */
@property (nonatomic, copy) MLAPIHelper *(^requestingAPIHelperBlock)(MLLazyLoadTableView *tableView, BOOL refreshing);

/**
 block for refreshing failed
 @note: you can call `reset` method in the block if the request conditions is already changed. otherwise, dont need do this.
 */
@property (nonatomic, copy) void(^refreshFailedBlock)(MLLazyLoadTableView *tableView, MLAPIHelper *apiHelper);

/**
 init
 
 @param lazyLoadSection   the section for lazy-loading
 @param exceptTopRowCount the top row count of lazy-loading section which will be ignored for lazy-loading
 
 @return instance
 */
- (instancetype)initWithLazyLoadSection:(NSInteger)lazyLoadSection exceptTopRowCount:(NSInteger)exceptTopRowCount;

/**
 init
 
 @param lazyLoadSection   the section for lazy-loading
 @param exceptTopRowCount the top row count of lazy-loading section which will be ignored for lazy-loading
 @param lazyLoadCell      cell for indicating lazy-loading status
 
 @return instance
 */
- (instancetype)initWithLazyLoadSection:(NSInteger)lazyLoadSection exceptTopRowCount:(NSInteger)exceptTopRowCount lazyLoadCell:(MLLazyLoadTableViewCell* _Nullable)lazyLoadCell;

/**
 Call this method after requesting succeed
 
 @param entries    entries
 @param noMore     whether no more
 @param apiHelper  api helper
 */
- (void)appendEntries:(NSArray*)entries noMore:(BOOL)noMore apiHelper:(MLAPIHelper*)apiHelper;

/**
 Call this method after requesting failed
 
 @param apiHelper apiHelper
 */
- (void)requestFailedWithAPIHelper:(MLAPIHelper*)apiHelper;

/**
 do refresh manually
 */
- (void)doRefresh;

/**
 reset to the init state of lazy-load table view.
 */
- (void)reset;

/**
 Returns the row index for lazy load cell
 
 @return lazyLoadIndex
 */
- (NSInteger)indexForLazyLoadCell;

/**
 Returns the indexPath for lazy load cell
 */
- (NSIndexPath*)indexPathForLazyLoadCell;

/**
 Returns current row count for lazy-loading section
 */
- (NSInteger)numberOfRowsInLazyLoadSection;

- (void)setRequestingAPIHelperBlock:(MLAPIHelper * _Nonnull (^ _Nonnull)(MLLazyLoadTableView * _Nonnull tableView, BOOL refreshing))requestingAPIHelperBlock;
- (void)setRefreshFailedBlock:(void (^ _Nonnull)(MLLazyLoadTableView * _Nonnull tableView, MLAPIHelper * _Nonnull apiHelper))refreshFailedBlock;
@end

NS_ASSUME_NONNULL_END
