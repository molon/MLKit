//
//  MLLazyLoadTableView.m
//  TycoonBuy
//
//  Created by molon on 16/4/18.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLLazyLoadTableView.h"
#import "DefaultMLLazyLoadTableViewCell.h"
#import "MLKit.h"
#import <MLRefreshControl/MLRefreshControl.h>

@interface UIScrollView(MLRefreshControlViewPrivateForLazyLoad)

@property (nonatomic, strong) NSDate *lastRefreshTime;

@end

@interface _MLLazyLoadTableViewProxy : MLDelegateProxy
@end
@implementation _MLLazyLoadTableViewProxy

- (BOOL)interceptsSelector:(SEL)selector {
    return (
            selector == @selector(tableView:cellForRowAtIndexPath:) ||
            selector == @selector(tableView:heightForRowAtIndexPath:) ||
            selector == @selector(tableView:didSelectRowAtIndexPath:) ||
            
            selector == @selector(tableView:willDisplayCell:forRowAtIndexPath:) ||
            
            selector == @selector(tableView:numberOfRowsInSection:)
            );
}

@end

@interface MLLazyLoadTableView()<MLDelegateProxyInterceptor>

@property (nonatomic, strong) MLAPIHelper *requestingAPIHelper;

@property (nonatomic, strong) NSMutableArray *entries;

@end

@implementation MLLazyLoadTableView {
    BOOL _needLazyLoad;
    
    _MLLazyLoadTableViewProxy *_delegateProxy;
    _MLLazyLoadTableViewProxy *_dataSourceProxy;
    
    BOOL _isDeallocating;
}

- (void)commonInit {
    self.scrollsToTop = YES;
    self.backgroundColor = [UIColor clearColor];
    
    WEAK_SELF
    [_lazyLoadCell setClickForRetryBlock:^{
        STRONG_SELF
        [self loadDataWithRefresh:NO];
    }];
    
    _delegateProxy = [[_MLLazyLoadTableViewProxy alloc] initWithTarget:nil interceptor:self];
    super.delegate = (id<UITableViewDelegate>)_delegateProxy;
    
    _dataSourceProxy = [[_MLLazyLoadTableViewProxy alloc] initWithTarget:nil interceptor:self];
    super.dataSource = (id<UITableViewDataSource>)_dataSourceProxy;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        //default lazy load cell
        _lazyLoadCell = [DefaultMLLazyLoadTableViewCell new];
        
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithLazyLoadSection:(NSInteger)lazyLoadSection exceptTopRowCount:(NSInteger)exceptTopRowCount {
    return [self initWithLazyLoadSection:lazyLoadSection exceptTopRowCount:exceptTopRowCount lazyLoadCell:nil];
}

- (instancetype)initWithLazyLoadSection:(NSInteger)lazyLoadSection exceptTopRowCount:(NSInteger)exceptTopRowCount lazyLoadCell:(MLLazyLoadTableViewCell*)lazyLoadCell {
    self = [super initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (self) {
        _lazyLoadSection = lazyLoadSection;
        _exceptTopRowCount = exceptTopRowCount;
        
        if (lazyLoadCell) {
            _lazyLoadCell = lazyLoadCell;
        }else{
            _lazyLoadCell = [DefaultMLLazyLoadTableViewCell new];
        }
        
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    DDLogWarn(@"Warning: MLLazyLoadTableView is not designed to be used with Interface Builder.  Table properties set in IB will be lost.");
    return [self initWithFrame:CGRectZero style:UITableViewStylePlain];
}

- (void)dealloc {
    _isDeallocating = YES;
    self.proxyDataSource = nil;
    self.proxyDelegate = nil;
}

#pragma mark - MLDelegateProxyInterceptor
- (void)proxyTargetHasDeallocated:(MLDelegateProxy *)proxy {
    if (proxy == _delegateProxy) {
        self.proxyDelegate = nil;
    } else if (proxy == _dataSourceProxy) {
        self.proxyDataSource = nil;
    }
}

#pragma mark - getter
- (NSMutableArray *)entries {
    if (!_entries) {
        _entries = [NSMutableArray new];
    }
    return _entries;
}

#pragma mark - setter
- (void)setRequestingAPIHelper:(MLAPIHelper * _Nullable)requestingAPIHelper {
    MLAPIHelper *originalRequestingAPIHelper = _requestingAPIHelper;
    _requestingAPIHelper = requestingAPIHelper;
    
    if (originalRequestingAPIHelper) {
        [originalRequestingAPIHelper cancel];
    }
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    NSAssert(dataSource == nil, @"MLLazyLoadTableView uses proxyDataSource, not UITableView's dataSource property.");
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    NSAssert(delegate == nil, @"MLLazyLoadTableView uses proxyDelegate, not UITableView's delegate property.");
}

- (void)setProxyDelegate:(id<UITableViewDelegate>)proxyDelegate {
    NS_VALID_UNTIL_END_OF_SCOPE id oldDelegate = self.delegate;
    
    if (proxyDelegate == nil) {
        _proxyDelegate = nil;
        _delegateProxy = _isDeallocating ? nil : [[_MLLazyLoadTableViewProxy alloc] initWithTarget:nil interceptor:self];
    } else {
        _proxyDelegate = proxyDelegate;
        _delegateProxy = [[_MLLazyLoadTableViewProxy alloc] initWithTarget:_proxyDelegate interceptor:self];
    }
    
    super.delegate = (id<UITableViewDelegate>)_delegateProxy;
}

- (void)setProxyDataSource:(id<UITableViewDataSource>)proxyDataSource {
    NS_VALID_UNTIL_END_OF_SCOPE id oldDataSource = self.dataSource;
    
    if (proxyDataSource == nil) {
        _proxyDataSource = nil;
        _dataSourceProxy = _isDeallocating ? nil : [[_MLLazyLoadTableViewProxy alloc] initWithTarget:nil interceptor:self];
    } else {
        _proxyDataSource = proxyDataSource;
        _dataSourceProxy = [[_MLLazyLoadTableViewProxy alloc] initWithTarget:_proxyDataSource interceptor:self];
    }
    
    super.dataSource = (id<UITableViewDataSource>)_dataSourceProxy;
}

#pragma mark - helper
- (void)loadDataWithRefresh:(BOOL)refresh {
    void (^requestBlock)() = ^{
        MLAPIHelper *helper = self.requestingAPIHelperBlock(self,_refreshing);
        NSAssert(helper&&[helper isKindOfClass:[MLAPIHelper class]]&&helper.state==MLAPIHelperStateRequesting, @"requestingAPIHelperBlock must return MLAPIHelper which has started request");
        
        self.requestingAPIHelper = helper;
    };
    
    if (refresh) {
        _refreshing = YES;
        
        //if refresh failed and status==MLLazyLoadCellStatusInit,
        //checkLazyLoadRightNow will be excuted.
        if (_needLazyLoad) {
            _lazyLoadCell.status = MLLazyLoadCellStatusInit;
        }
        
        requestBlock();
        
        self.lastRefreshTime = [NSDate date];
    }else{
        //if no last api helper, do request else do nothing
        if (!_requestingAPIHelper) {
            _refreshing = NO;
            
            requestBlock();
            
            _lazyLoadCell.status = MLLazyLoadCellStatusLoading;
        }
    }
}

- (NSInteger)numberOfRowsInLazyLoadSection {
    return _entries.count+_exceptTopRowCount+1;
}

- (NSInteger)indexForLazyLoadCell {
    return [self numberOfRowsInLazyLoadSection]-1;
}

- (NSIndexPath*)indexPathForLazyLoadCell {
    return [NSIndexPath indexPathForRow:[self indexForLazyLoadCell] inSection:_lazyLoadSection];
}

- (NSIndexPath*)indexPathForEntry:(id)entry {
    NSInteger index = [_entries indexOfObject:entry];
    if (index==NSNotFound) {
        return nil;
    }
    return [NSIndexPath indexPathForRow:index inSection:_lazyLoadSection];
}

/**
 Maybe the lazy-loading cell still displays after appending,
 So we need to check whether requests for next page if not noMore or failed
 */
- (void)checkLazyLoadRightNow {
    if (_needLazyLoad&&_lazyLoadCell.status!=MLLazyLoadCellStatusLoadFailed) {
        NSArray *visibleIndexPaths = [self indexPathsForVisibleRows];
        if ([visibleIndexPaths containsObject:[self indexPathForLazyLoadCell]]) {
            [self loadDataWithRefresh:NO];
        }
    }
}

- (void)doReloadDataWithCompletion:(void (^)())completion {
    [self reloadData];
    
    if (completion) {
        completion();
    }
    
    //end refreshing if using MLRefreshControl
    [self endRefreshing];
}

- (NSInteger)deleteRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation {
    NSParameterAssert(entry);
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSIndexSet *indexes = [_entries indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([entry isEqual:obj]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:_lazyLoadSection]];
            return YES;
        }
        return NO;
    }];
    
    if (indexes.count>0) {
        [_entries removeObjectsAtIndexes:indexes];
        if (_entries.count<=0) {
            //set the status first, if `deleteRowsAtIndexPaths:withRowAnimation:` raises lazy-load, it's status will be change to correct.
            //if not raise, empty status is correct.
            _lazyLoadCell.status = MLLazyLoadCellStatusEmpty;
        }
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }
    return indexes.count;
}

- (NSInteger)deleteRowsInLazyLoadSectionWithEntryID:(id)entryID keyOfEntryID:(NSString*)keyOfEntryID rowAnimation:(UITableViewRowAnimation)animation {
    NSParameterAssert(keyOfEntryID);
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSIndexSet *indexes = [_entries indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([[obj class]xx_containsPropertyKey:keyOfEntryID], @"keyOfEntryID is not exist in entry:%@",obj);
        
        id value = nil;
        @try {
            value = [obj valueForKeyPath:keyOfEntryID];
        } @catch (NSException *exception) {
            DDLogError(@"%@",exception);
        }
        
        if (!value && !entryID) {
            DDLogWarn(@"Entry:%@\nvalue for keyOfEntryID(%@) is nil",obj,keyOfEntryID);
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:_lazyLoadSection]];
            return YES;
        }
        
        if ([value isEqual:entryID]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:_lazyLoadSection]];
            return YES;
        }
        
        return NO;
    }];
    
    if (indexes.count>0) {
        [_entries removeObjectsAtIndexes:indexes];
        if (_entries.count<=0) {
            //set the status first, if `deleteRowsAtIndexPaths:withRowAnimation:` raises lazy-load, it's status will be change to correct.
            //if not raise, empty status is correct.
            _lazyLoadCell.status = MLLazyLoadCellStatusEmpty;
        }
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }
    
    return indexes.count;
}

- (NSInteger)reloadRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation {
    NSParameterAssert(entry);
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    [_entries enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([entry isEqual:obj]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:_lazyLoadSection]];
        }
    }];
    
    if (indexPaths.count>0) {
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }
    
    return indexPaths.count;
}

- (NSInteger)replaceEntriesAndReloadRowsWithEntry:(id)entry keyOfEntryID:(NSString*)keyOfEntryID rowAnimation:(UITableViewRowAnimation)animation {
    NSParameterAssert(keyOfEntryID);
    NSParameterAssert(entry);
    
    NSAssert([[entry class]xx_containsPropertyKey:keyOfEntryID], @"keyOfEntryID is not exist in entry:%@",entry);
    id entryID = nil;
    @try {
        entryID = [entry valueForKeyPath:keyOfEntryID];
    } @catch (NSException *exception) {
        DDLogError(@"%@",exception);
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSIndexSet *indexes = [_entries indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([[obj class]xx_containsPropertyKey:keyOfEntryID], @"keyOfEntryID is not exist in entry:%@",obj);
        
        id value = nil;
        @try {
            value = [obj valueForKeyPath:keyOfEntryID];
        } @catch (NSException *exception) {
            DDLogError(@"%@",exception);
        }
        
        if (!value && !entryID) {
            DDLogWarn(@"Entry:%@\nvalue for keyOfEntryID(%@) is nil",obj,keyOfEntryID);
            [arr addObject:entry];
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:_lazyLoadSection]];
            return YES;
        }
        
        if ([value isEqual:entryID]) {
            [arr addObject:entry];
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:_lazyLoadSection]];
            return YES;
        }
        
        return NO;
    }];
    
    if (indexPaths.count>0) {
        [_entries replaceObjectsAtIndexes:indexes withObjects:arr];
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }
    
    return indexPaths.count;
}

#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==_lazyLoadSection&&indexPath.row==[self indexForLazyLoadCell]) {
        return _lazyLoadCell;
    }
    
    return [_proxyDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==_lazyLoadSection&&indexPath.row==[self indexForLazyLoadCell]) {
        return [_lazyLoadCell preferredHeightWithMaxWidth:self.frame.size.width];
    }
    
    if (![_proxyDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return self.rowHeight<=0?44.0f:self.rowHeight;
    }
    
    return [_proxyDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==_lazyLoadSection&&indexPath.row==[self indexForLazyLoadCell]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if ([_proxyDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [_proxyDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==_lazyLoadSection) {
        return [self numberOfRowsInLazyLoadSection];
    }
    
    return [_proxyDataSource tableView:tableView numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==_lazyLoadSection&&indexPath.row==[self indexForLazyLoadCell]) {
        if (!_needLazyLoad) {
            return;
        }
        
        [self loadDataWithRefresh:NO];
    }
    
    if ([_proxyDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [_proxyDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark - outcall
- (void)reset {
    //end refreshing if using MLRefreshControl
    [self endRefreshing];
    
    self.requestingAPIHelper = nil;
    _refreshing = NO;
    _entries = nil;
    _needLazyLoad = NO;
    _lazyLoadCell.status = MLLazyLoadCellStatusInit;
    
    [self doReloadDataWithCompletion:nil];
    
    if (self.afterResetBlock) {
        self.afterResetBlock(self);
    }
}

- (void)doRefresh {
    [self loadDataWithRefresh:YES];
}

- (void)requestFailedWithAPIHelper:(MLAPIHelper*)apiHelper {
    //if not the last requesting api helper, just return
    if (_requestingAPIHelper&&![apiHelper isEqual:_requestingAPIHelper]) {
        return;
    }
    self.requestingAPIHelper = nil;
    
    if (_refreshing) {
        //end refreshing if using MLRefreshControl
        [self endRefreshing];
        
        //refresh failed block
        if (self.refreshFailedBlock) {
            self.refreshFailedBlock(self,apiHelper);
        }
        
        //if you call `reset` method in refresh failed block.
        //the method will do nothing
        [self checkLazyLoadRightNow];
    }else{
        _lazyLoadCell.status = MLLazyLoadCellStatusLoadFailed;
    }
    
    _refreshing = NO;
}

- (void)appendEntries:(NSArray*)entries noMore:(BOOL)noMore apiHelper:(MLAPIHelper*)apiHelper {
    //if not the last requesting api helper, just return
    if (_requestingAPIHelper&&![apiHelper isEqual:_requestingAPIHelper]) {
        return;
    }
    self.requestingAPIHelper = nil;
    
    _needLazyLoad = !noMore;
    
    if (_refreshing&&_entries) {
        _entries = nil;
    }
    
    void (^completionBlock)() = ^{
        if (noMore) {
            _lazyLoadCell.status = MLLazyLoadCellStatusNoMore;
        }else{
            [self checkLazyLoadRightNow];
        }
    };
    
    if (entries.count>0) {
        NSMutableArray *indexes = nil;
        
        if (!_refreshing) {
            //inserting rows need indexes
            indexes = [NSMutableArray arrayWithCapacity:entries.count];
            NSInteger currentRowCount = [self numberOfRowsInLazyLoadSection];
            for (NSUInteger i=0; i<entries.count; i++) {
                [indexes addObject:[NSIndexPath indexPathForRow:currentRowCount-1+i inSection:_lazyLoadSection]];
            }
        }
        
        //add to self.entries
        [self.entries addObjectsFromArray:entries];
        
        if (_refreshing) {
            [self doReloadDataWithCompletion:completionBlock];
        }else{
            [CATransaction setDisableActions:YES];
            [self beginUpdates];
            [self insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationNone];
            [self endUpdates];
            [CATransaction setDisableActions:NO];
            
            completionBlock();
        }
    }else{
        if (_refreshing) {
            NSAssert(noMore, @"`entries` is 0 and `noMore` is NO when refreshing. it's strange!!!");
            
            [self doReloadDataWithCompletion:^{
                if (noMore) {
                    _lazyLoadCell.status = MLLazyLoadCellStatusEmpty;
                }else{
                    [self checkLazyLoadRightNow];
                }
            }];
        }else{
            //Maybe `entries` is 0 and `noMore` is NO after deduplication，so we just do request again right now in this case
            //Of course `noMore` can also be YES.
            completionBlock();
        }
    }
    
    NSAssert(!_needLazyLoad||(_entries.count>0&&_needLazyLoad), @"`_needLazyLoad` can be YES only when _entries.count>0 after `%@`",NSStringFromSelector(_cmd));
    
    _refreshing = NO;
}

@end
