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

@interface MLLazyLoadViewController ()

@property (nonatomic, strong) MLLazyLoadTableView *tableView;
@property (nonatomic, assign) NSInteger currentPageNo;

@property (nonatomic, copy) NSString *keyOfEntryIDForDeduplication;
@property (nonatomic, strong) UIView *backgroundViewIfEmptyList;

@end

@implementation MLLazyLoadViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (!_tableView) {
        _tableView = ({
            MLLazyLoadTableView *tableView = [[MLLazyLoadTableView alloc]initWithLazyLoadSection:[self configureLazyLoadSection] exceptTopRowCount:[self configureExceptTopRowCount] lazyLoadCell:[self configureLazyLoadCell]];
            tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
            tableView.proxyDataSource = self;
            tableView.proxyDelegate = self;
            tableView;
        });
        
        [self adjustTableViewContentInset];
        
        WEAK_SELF
        [_tableView enableRefreshingWithAction:^{
            STRONG_SELF
            [self.tableView doRefresh];
        } style:MLRefreshControlViewStyleFixed originalTopInset:[self navigationBarBottomY] scrollToTopAfterEndRefreshing:NO];
        
        [_tableView setRequestingAPIHelperBlock:^MLAPIHelper * _Nonnull(MLLazyLoadTableView * _Nonnull tableView, BOOL refreshing) {
            STRONG_SELF
            LazyLoadAPIHelper *helper = [self lazyLoadHelperWithRefreshing:refreshing];
            NSAssert(helper, @"`lazyLoadHelperWithRefreshing` can not return nil");
            if (refreshing) {
                helper.p_pageNo = 1;
            }else{
                helper.p_pageNo = self.currentPageNo+1;
            }
            
            [helper requestWithCallbackObject:self];
            
            //hide backgroundViewIfEmptyList
            tableView.backgroundView = nil;
            
            return helper;
        }];
    }
    
    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_tableView.lastRefreshTime) {
        if ([self autoRefreshWhenFirstDidAppear]) {
            [_tableView beginRefreshing];
        }
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _tableView.frame = self.view.bounds;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self adjustTableViewContentInset];
}

- (BOOL)autoRefreshWhenFirstDidAppear {
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

#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self doesNotRecognizeSelector:_cmd];
    //for analyze
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - request
- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper {
    if ([apiHelper isEqual:_tableView.requestingAPIHelper]) {
        LazyLoadAPIHelper *helper = (LazyLoadAPIHelper*)apiHelper;
        
        NSMutableArray *rows = [helper.r_rows mutableCopy];
        
        BOOL noMore = rows.count<helper.p_pageSize;
        
        //deduplication
        if (!_tableView.refreshing&&rows.count>0) {
            if ([_keyOfEntryIDForDeduplication isNotBlank]) {
                //check whether keyOfEntryID exist
                BOOL exist = [[[rows firstObject] class]yy_containsPropertyKey:_keyOfEntryIDForDeduplication];
                NSAssert(exist, @"_keyOfEntryIDForDeduplication is not exist in entry of `r_rows`");
                if (exist) {
                    [rows removeNilAndDuplicateValueObjectsForKeyPath:_keyOfEntryIDForDeduplication andSameValueObjectsWithOtherObjects:_tableView.entries];
                }
            }
        }
        
        if (_tableView.refreshing) {
            self.currentPageNo = 1;
            
            _tableView.backgroundView = (rows.count<=0)?_backgroundViewIfEmptyList:nil;
        }else{
            self.currentPageNo++;
        }
        //append to list
        [_tableView appendEntries:rows noMore:noMore apiHelper:helper];
    }
}

- (void)afterRequestFailed:(MLAPIHelper *)apiHelper {
    if ([apiHelper isEqual:_tableView.requestingAPIHelper]) {
        [_tableView requestFailedWithAPIHelper:apiHelper];
    }else if ([apiHelper isKindOfClass:[LazyLoadAPIHelper class]]){
        if (MLAPI_IsErrorCancelled(apiHelper.responseError)) {
            DDLogInfo(@"有懒加载请求被取消，一般由于下拉刷新请求开始了，其优先级比较高，这很正常");
            return;
        }
    }
    
    [super afterRequestFailed:apiHelper];
}

#pragma mark - helper
- (void)adjustTableViewContentInset {
    _tableView.contentInsetBottom = [self tabBarOccupiedHeight];
    _tableView.refreshView.originalTopInset = [self navigationBarBottomY];
}


#pragma mark - operations
- (void)deleteRowsInLazyLoadSectionWithEntryID:(nullable NSString*)entryID rowAnimation:(UITableViewRowAnimation)animation {
    NSAssert(_keyOfEntryIDForDeduplication, @"_keyOfEntryIDForDeduplication must be provided if using `deleteRowsInLazyLoadSectionWithEntryID:rowAnimation:`");
    [_tableView deleteRowsInLazyLoadSectionWithEntryID:entryID keyOfEntryID:_keyOfEntryIDForDeduplication rowAnimation:animation];
    
    if (_tableView.entries.count<=0) {
        _tableView.backgroundView = _backgroundViewIfEmptyList;
    }
}

- (void)deleteRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation {
    [_tableView deleteRowsInLazyLoadSectionWithEntry:entry withRowAnimation:animation];
    
    if (_tableView.entries.count<=0) {
        _tableView.backgroundView = _backgroundViewIfEmptyList;
    }
}

- (void)reloadRowsInLazyLoadSectionWithEntryID:(nullable NSString*)entryID rowAnimation:(UITableViewRowAnimation)animation {
    NSAssert(_keyOfEntryIDForDeduplication, @"_keyOfEntryIDForDeduplication must be provided if using `deleteRowsInLazyLoadSectionWithEntryID:rowAnimation:`");
    [_tableView reloadRowsInLazyLoadSectionWithEntryID:entryID keyOfEntryID:_keyOfEntryIDForDeduplication rowAnimation:animation];
}

- (void)reloadRowsInLazyLoadSectionWithEntry:(id)entry withRowAnimation:(UITableViewRowAnimation)animation {
    [_tableView reloadRowsInLazyLoadSectionWithEntry:entry withRowAnimation:animation];
}

@end
