//
//  MLListViewController.m
//  MLKitExample
//
//  Created by molon on 16/8/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLListViewController.h"
#import <DefaultMLAPIObserverView.h>
#import <MLAutoRecordFrameTableView.h>
#import <MLRefreshControl.h>

@interface MLListViewController ()

@property (nonatomic, strong) MLAutoRecordFrameTableView *tableView;
@property (nonatomic, strong) DefaultMLAPIObserverView *apiObserverView;

@end

@implementation MLListViewController

- (void)loadTableView {
    
}

- (void)loadAPIObserverView {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadAPIObserverView];
    
    if (!_apiObserverView) {
        _apiObserverView = ({
            DefaultMLAPIObserverView *observerView = [DefaultMLAPIObserverView new];
            observerView.backgroundColor = self.view.backgroundColor;
            observerView;
        });
    }else if (_apiObserverView.superview) {
        [_apiObserverView removeFromSuperview];
    }
    
    [self loadTableView];
    
    if (!_tableView) {
        _tableView = ({
            MLAutoRecordFrameTableView *tableView = [[MLAutoRecordFrameTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView;
        });
    }else if (_tableView.superview) {
        [_tableView removeFromSuperview];
    }
    
    _tableView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_tableView];
    [self.view addSubview:_apiObserverView];
    
    [self adjustTableViewContentInset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helper
- (void)adjustTableViewContentInset {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL sel = @selector(setContentInsetAdjustmentBehavior:);
    if (class_getInstanceMethod([UIScrollView class], sel)||class_getInstanceMethod([UITableView class], sel)) {
        @try {
            [_tableView performSelectorWithArgs:sel,2]; //setContentInsetAdjustmentBehavior:Nerver
        } @catch  (NSException *exception) {
            NSLog(@"%@",exception);
        }
    }
#pragma clang diagnostic pop
    
    _tableView.contentInsetBottom = [self tabBarOccupiedHeight];
    
    CGFloat topInset = [self navigationBarBottom];
    //如果有refreshView则使用其来设置inset.top,其内部也会自动对tableView的进行设置
    if (_tableView.refreshView) {
        _tableView.refreshView.originalTopInset = topInset;
    }else{
        _tableView.contentInsetTop = topInset;
    }
}

#pragma mark - layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _tableView.frame = self.view.bounds;
    _apiObserverView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.view bringSubviewToFront:_apiObserverView];
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

#pragma mark - rotate
//在屏幕旋转后自动修正tableView的头部和底部inset
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self adjustTableViewContentInset];
}

@end
