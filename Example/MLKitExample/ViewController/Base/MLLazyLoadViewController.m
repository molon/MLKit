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
#import "BaseAPIHelper.h"

@interface MLListViewController(Private)

@property (nonatomic, strong) MLAutoRecordFrameTableView *tableView;

@end

@interface MLLazyLoadViewController ()

@property (nonatomic, assign) NSInteger currentPageNo;

@property (nonatomic, copy) NSString *keyOfEntryIDForDeduplication;
@property (nonatomic, strong) UIView *backgroundViewIfEmptyList;

@end

@implementation MLLazyLoadViewController {
    BOOL _hasRequested;
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
        
        self.apiObserverView.observingAPIHelper =  self->_hasRequested?nil:([self autoObserveFirstRequest]?helper:nil);
        self->_hasRequested = YES;
        
        //hide backgroundViewIfEmptyList
        tableView.backgroundView = nil;
        
        return helper;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //MLRefreshControl
    if ([self autoEnableMLRefreshControl]) {
        WEAK_SELF
        [self.tableView enableRefreshingWithAction:^{
            STRONG_SELF
            [self.tableView doRefresh];
        } style:MLRefreshControlViewStyleFixed originalTopInset:[self navigationBarBottomY] scrollToTopAfterEndRefreshing:NO];
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
- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper {
    if ([apiHelper isEqual:self.tableView.requestingAPIHelper]) {
        LazyLoadAPIHelper *helper = (LazyLoadAPIHelper*)apiHelper;
        
        NSMutableArray *rows = [helper.r_rows mutableCopy];
        
        BOOL noMore = rows.count<helper.p_pageSize;
        
        //deduplication
        if (!self.tableView.refreshing&&rows.count>0) {
            if ([_keyOfEntryIDForDeduplication isNotBlank]) {
                //check whether keyOfEntryID exist
                BOOL exist = [[[rows firstObject] class]yy_containsPropertyKey:_keyOfEntryIDForDeduplication];
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

#pragma mark - operations
- (void)deleteRowsInLazyLoadSectionWithEntryID:(nullable NSString*)entryID rowAnimation:(UITableViewRowAnimation)animation {
    NSAssert(_keyOfEntryIDForDeduplication, @"_keyOfEntryIDForDeduplication must be provided if using `deleteRowsInLazyLoadSectionWithEntryID:rowAnimation:`");
    [self.tableView deleteRowsInLazyLoadSectionWithEntryID:entryID keyOfEntryID:_keyOfEntryIDForDeduplication rowAnimation:animation];
    
    if (self.tableView.entries.count<=0) {
        self.tableView.backgroundView = _backgroundViewIfEmptyList;
    }
}

- (void)deleteRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation {
    [self.tableView deleteRowsInLazyLoadSectionWithEntry:entry withRowAnimation:animation];
    
    if (self.tableView.entries.count<=0) {
        self.tableView.backgroundView = _backgroundViewIfEmptyList;
    }
}

- (void)reloadRowsInLazyLoadSectionWithEntryID:(nullable NSString*)entryID rowAnimation:(UITableViewRowAnimation)animation {
    NSAssert(_keyOfEntryIDForDeduplication, @"_keyOfEntryIDForDeduplication must be provided if using `deleteRowsInLazyLoadSectionWithEntryID:rowAnimation:`");
    [self.tableView reloadRowsInLazyLoadSectionWithEntryID:entryID keyOfEntryID:_keyOfEntryIDForDeduplication rowAnimation:animation];
}

- (void)reloadRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation {
    [self.tableView reloadRowsInLazyLoadSectionWithEntry:entry withRowAnimation:animation];
}

@end
