//
//  MLLazyLoadViewController.m
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLLazyLoadViewController.h"
#import "MLLazyLoadTableView.h"
#import <MLRefreshControl/MLRefreshControl.h>
#import "UIViewController+MLAPI.h"
#import "BaseAPIHelpers.h"

@interface MLListViewController(Private)

@property (nonatomic, strong) MLAutoRecordFrameTableView *tableView;

@end

@interface MLLazyLoadViewController ()

@property (nonatomic, copy) NSString *keyOfEntryIDForDeduplication;
@property (nonatomic, strong) UIView *backgroundViewIfEmptyList;

@end

@implementation MLLazyLoadViewController {
    BOOL _hasRequestSucceedOnce;
}

@dynamic tableView;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    self.backgroundViewIfEmptyList = [self configureBackgroundViewIfEmptyList];
    self.keyOfEntryIDForDeduplication = [self configureKeyOfEntryIDForDeduplication];
}

- (void)loadTableView {
    self.tableView = ({
        MLLazyLoadTableView *tableView = [[MLLazyLoadTableView alloc]initWithLazyLoadSection:[self configureLazyLoadSection] exceptTopRowCount:[self configureExceptTopRowCount] lazyLoadCell:[self configureLazyLoadCell]];
        tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        tableView.proxyDataSource = self;
        tableView.proxyDelegate = self;
        tableView;
    });
    
    WEAK_SELF
    [self.tableView setRequestingAPIHelperBlock:^MLAPIHelper * _Nonnull(MLLazyLoadTableView * _Nonnull tableView, BOOL refreshing) {
        STRONG_SELF
        LazyLoadAPIHelper *helper = [self lazyLoadHelperWithRefreshing:refreshing];
        NSAssert(helper, @"`lazyLoadHelperWithRefreshing` can not return nil");
        if (refreshing) {
            helper.p_pageNo = 1;
        }else{
            helper.p_pageNo = self.currentPageNo+1;
        }
        
        [helper requestWithCallbackObject:self];
        
        self.apiObserverView.observingAPIHelper =  self->_hasRequestSucceedOnce?nil:([self autoObserveFirstRequest]?helper:nil);
        
        //hide backgroundViewIfEmptyList
        tableView.backgroundView = nil;
        
        return helper;
    }];
    
    [self.tableView setAfterResetBlock:^(MLLazyLoadTableView * _Nonnull tableView) {
        STRONG_SELF
        self.currentPageNo = 0;
        tableView.backgroundView = nil;
        self.apiObserverView.observingAPIHelper = nil;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    WEAK_SELF
    if ([self autoObserveFirstRequest]) {
        [self.apiObserverView setRetryBlock:^(MLAPIObserverView *v) {
            STRONG_SELF
            [self.tableView doRefresh];
            v.observingAPIHelper =  self.tableView.requestingAPIHelper;
        }];
    }
    
    //MLRefreshControl
    if ([self autoEnableMLRefreshControl]) {
        [self.tableView enableRefreshControlWithAction:^{
            STRONG_SELF
            [self.tableView doRefresh];
        } style:MLRefreshControlViewStyleFollow originalTopInset:self.tableView.contentInset.top scrollToTopAfterEndRefreshing:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.tableView.lastRefreshTime) {
        if ([self autoRefreshWhenFirstDidAppear]) {
            if (self.tableView.refreshView&&![self autoObserveFirstRequest]) {
                [self.tableView beginRefreshing];
            }else{
                [self.tableView doRefresh];
            }
        }
    }
}

#pragma mark - config
- (BOOL)autoEnableMLRefreshControl {
    return YES;
}

- (BOOL)autoRefreshWhenFirstDidAppear {
    return YES;
}

- (BOOL)autoObserveFirstRequest {
    return YES;
}

- (nullable NSString*)configureKeyOfEntryIDForDeduplication {
    return nil;
}

- (NSInteger)configureLazyLoadSection {
    return 0;
}

- (NSInteger)configureExceptTopRowCount {
    return 0;
}

- (nullable MLLazyLoadTableViewCell*)configureLazyLoadCell {
    return nil;
}

- (LazyLoadAPIHelper *)lazyLoadHelperWithRefreshing:(BOOL)refreshing {
    [self doesNotRecognizeSelector:_cmd];
    //for analyze
    return [LazyLoadAPIHelper new];
}

- (UIView*)configureBackgroundViewIfEmptyList {
    return nil;
}

#pragma mark - request
- (void)beforeRequest:(MLAPIHelper *)apiHelper {
    if ([apiHelper isKindOfClass:[LazyLoadAPIHelper class]]) {
        return;
    }
    [super beforeRequest:apiHelper];
}

- (void)afterRequestCompleted:(MLAPIHelper *)apiHelper {
    if ([apiHelper isKindOfClass:[LazyLoadAPIHelper class]]) {
        return;
    }
    [super afterRequestCompleted:apiHelper];
}

- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper {
    if ([apiHelper isEqual:self.tableView.requestingAPIHelper]) {
        _hasRequestSucceedOnce = YES;
        
        LazyLoadAPIHelper *helper = (LazyLoadAPIHelper*)apiHelper;
        
        NSMutableArray *rows = [helper.r_rows mutableCopy];
        
        BOOL noMore = rows.count<helper.p_pageSize;
        
        //deduplication
        if (!self.tableView.refreshing&&rows.count>0) {
            if ([_keyOfEntryIDForDeduplication isNotBlank]) {
                //check whether keyOfEntryID exist
                BOOL exist = [[[rows firstObject] class]xx_containsPropertyKey:_keyOfEntryIDForDeduplication];
                NSAssert(exist, @"_keyOfEntryIDForDeduplication is not exist in entry of `r_rows`");
                if (exist) {
                    [rows removeNilAndDuplicateValueObjectsForKeyPath:_keyOfEntryIDForDeduplication andSameValueObjectsWithOtherObjects:self.tableView.entries];
                }
            }
        }
        
        if (self.tableView.refreshing) {
            self.currentPageNo = 1;
            
            self.tableView.backgroundView = (rows.count<=0)?_backgroundViewIfEmptyList:nil;
        }else{
            self.currentPageNo++;
        }
        //append to list
        [self.tableView appendEntries:rows noMore:noMore apiHelper:helper];
    }
}

- (void)afterRequestFailed:(MLAPIHelper *)apiHelper {
    if ([apiHelper isEqual:self.tableView.requestingAPIHelper]) {
        [self.tableView requestFailedWithAPIHelper:apiHelper];
    }else if ([apiHelper isKindOfClass:[LazyLoadAPIHelper class]]){
        if (MLAPI_IsErrorCancelled(apiHelper.responseError)) {
            DDLogInfo(@"有懒加载请求被取消，一般由于下拉刷新请求开始了，其优先级比较高，这很正常");
            return;
        }
    }
    
    [super afterRequestFailed:apiHelper];
}

- (void)afterRequestError:(MLAPIHelper *)apiHelper {
    [super afterRequestError:apiHelper];
}

#pragma mark - operations
- (void)deleteRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation {
    if (!entry) {
        return;
    }
    [self.tableView deleteRowsInLazyLoadSectionWithEntry:entry withRowAnimation:animation];
    
    if (self.tableView.entries.count<=0) {
        self.tableView.backgroundView = _backgroundViewIfEmptyList;
    }
}
- (void)deleteRowsInLazyLoadSectionWithEntryID:(nullable id)entryID rowAnimation:(UITableViewRowAnimation)animation {
    NSAssert(_keyOfEntryIDForDeduplication, @"_keyOfEntryIDForDeduplication must be provided if using `%@`",NSStringFromSelector(_cmd));
    [self.tableView deleteRowsInLazyLoadSectionWithEntryID:entryID keyOfEntryID:_keyOfEntryIDForDeduplication rowAnimation:animation];
    
    if (self.tableView.entries.count<=0) {
        self.tableView.backgroundView = _backgroundViewIfEmptyList;
    }
}

- (void)reloadRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation {
    if (!entry) {
        return;
    }
    [self.tableView reloadRowsInLazyLoadSectionWithEntry:entry withRowAnimation:animation];
}

- (void)replaceEntriesAndReloadRowsWithEntry:(id)entry rowAnimation:(UITableViewRowAnimation)animation {
    NSAssert(_keyOfEntryIDForDeduplication, @"_keyOfEntryIDForDeduplication must be provided if using `%@`",NSStringFromSelector(_cmd));
    if (!entry) {
        return;
    }
    [self.tableView replaceEntriesAndReloadRowsWithEntry:entry keyOfEntryID:_keyOfEntryIDForDeduplication rowAnimation:animation];
}

@end
