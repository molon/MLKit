//
//  ObserveFirstRequestLazyLoadViewController.m
//  MLKitExample
//
//  Created by molon on 16/8/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "ObserveFirstRequestLazyLoadViewController.h"
#import "MLLazyLoadTableView.h"
#import <MLRefreshControl/MLRefreshControl.h>
#import "BaseAPIHelper.h"

@interface ObserveFirstRequestLazyLoadViewController()

@property (nonatomic, strong) DefaultMLAPIObserverView *observerView;

@end

@implementation ObserveFirstRequestLazyLoadViewController {
    BOOL _hasRequested;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!_observerView) {
        _observerView = ({
            DefaultMLAPIObserverView *observerView = [DefaultMLAPIObserverView new];
            observerView.backgroundColor = [UIColor whiteColor];
            WEAK_SELF
            [observerView setDidClickRetryButtonBlock:^(DefaultMLAPIObserverView *v) {
                STRONG_SELF
                [self.tableView doRefresh];
                v.observingAPIHelper =  self.tableView.requestingAPIHelper;
            }];
            observerView;
        });
    }
    
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
        
        self.observerView.observingAPIHelper =  self->_hasRequested?nil:helper;//(!refreshing||tableView.lastRefreshTime)?nil:helper;
        self->_hasRequested = YES;
        
        return helper;
    }];
    
    [self.view addSubview:_observerView];
}

- (BOOL)autoRefreshAtFirstDidAppear {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.tableView.lastRefreshTime) {
        [self.tableView doRefresh];
    }
}

#pragma mark - layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _observerView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.view bringSubviewToFront:_observerView];
}
@end
