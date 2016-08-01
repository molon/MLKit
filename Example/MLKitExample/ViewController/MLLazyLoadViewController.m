//
//  MLLazyLoadViewController.m
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLLazyLoadViewController.h"
#import "MLLazyLoadTableView.h"
#import <MLRefreshControl.h>
#import "UIViewController+MLAPI.h"
#import "BaseAPIHelper.h"

@interface MLLazyLoadViewController ()

@property (nonatomic, strong) MLLazyLoadTableView *tableView;
@property (nonatomic, assign) NSInteger currentPageNo;

@end

@implementation MLLazyLoadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (!_tableView) {
        _tableView = ({
            MLLazyLoadTableView *tableView = [[MLLazyLoadTableView alloc]initWithLazyLoadSection:[self lazyLoadSection] exceptTopRowCount:[self exceptTopRowCount] lazyLoadCell:[self lazyLoadCell]];
            tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
            tableView.proxyDataSource = self;
            tableView.proxyDelegate = self;
            tableView;
        });
        
        _tableView.contentInsetTop = [self navigationBarBottomY];
        _tableView.contentInsetBottom = [self tabBarOccupiedHeight];
        
        WEAK_SELF
        [_tableView setRequestingAPIHelperBlock:^MLAPIHelper * _Nonnull(MLLazyLoadTableView * _Nonnull tableView, BOOL refreshing) {
            STRONG_SELF
            LazyLoadAPIHelper *helper = [self lazyLoadHelper];
            NSAssert(helper, @"`lazyLoadHelper` can not return nil");
            if (refreshing) {
                helper.p_pageNo = 1;
            }else{
                helper.p_pageNo = self.currentPageNo+1;
            }
            
            [helper requestWithCallbackObject:self];
            
            return helper;
        }];
    }
    
    [self.view addSubview:_tableView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _tableView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_tableView.refreshView) {
        WEAK_SELF
        [_tableView enableRefreshingWithAction:^{
            STRONG_SELF
            [self.tableView doRefresh];
        } style:MLRefreshControlViewStyleFixed scrollToTopAfterEndRefreshing:YES];
        
        if ([self autoRefreshAtFirstDisplay]) {
            [_tableView beginRefreshing];
        }
    }
}

- (BOOL)autoRefreshAtFirstDisplay
{
    return YES;
}

- (NSInteger)lazyLoadSection
{
    return 0;
}

- (NSInteger)exceptTopRowCount
{
    return 0;
}

- (MLLazyLoadTableViewCell*)lazyLoadCell
{
    return nil;
}

- (NSString*)keyOfEntryIDForDeduplication
{
    return nil;
}

- (LazyLoadAPIHelper *)lazyLoadHelper {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - request
- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper
{
    if ([apiHelper isEqual:_tableView.requestingAPIHelper]) {
        LazyLoadAPIHelper *helper = (LazyLoadAPIHelper*)apiHelper;
        
        NSMutableArray *rows = [helper.r_rows mutableCopy];
        
        BOOL noMore = rows.count<helper.p_pageSize;
        
        //deduplication
        if (!_tableView.refreshing&&rows.count>0) {
            NSString *keyOfEntryID = [self keyOfEntryIDForDeduplication];
            if (keyOfEntryID) {
                //check whether keyOfEntryID exist
                BOOL exist = [[[rows firstObject] class]yy_containsPropertyKey:keyOfEntryID];
                NSAssert(exist, @"keyOfEntryID is not exist in entry of `r_rows`");
                
                [rows removeNilAndDuplicateValueObjectsForKeyPath:keyOfEntryID andSameValueObjectsWithOtherObjects:_tableView.entries];
            }
        }
        
        if (_tableView.refreshing) {
            self.currentPageNo = 1;
        }else{
            self.currentPageNo++;
        }
        
        //append to list
        [_tableView appendEntries:rows noMore:noMore apiHelper:helper];
    }
}

- (void)afterRequestFailed:(MLAPIHelper *)apiHelper
{
    if ([apiHelper isEqual:_tableView.requestingAPIHelper]) {
        [_tableView requestFailedWithAPIHelper:apiHelper];
    }
    
    [super afterRequestFailed:apiHelper];
}

@end
