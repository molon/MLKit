//
//  ViewController.m
//  MLKitExample
//
//  Created by molon on 16/5/26.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "ViewController.h"
#import "TestAPIHelper.h"
#import "UIViewController+MLAPI.h"
#import "ArticleListViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self careAboutMLAPIHelperClass:[UUIDAPIHelper class]];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self careAboutMLAPIHelperClass:[UUIDAPIHelper class]];
}

- (UIButton *)button
{
    if (!_button) {
        UIButton *button = [[UIButton alloc]init];
        [button setTitle:@"测试" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
        
        _button = button;
    }
    return _button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    [self.view addSubview:self.tableView];
    [self.view addSubview:self.button];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(gotoList)];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.button.frame = [self.view centerFrameWithWidth:100 height:50];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - event
- (void)gotoList {
    ArticleListViewController *vc = [ArticleListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)test
{
    TestAPIHelper *helper = [TestAPIHelper new];
    helper.p_test = @"testParam";
    helper.p_test2 = 100;
//    helper.cacheType = MLAPIHelperCacheTypeReturnCacheThenAlwaysRequest;
    
    //只用callbackObject的例子
    //        [helper requestWithCallbackObject:self];
    
    [helper requestWithBefore:^(MLAPIHelper * _Nonnull apiHelper) {
        DDLogInfo(@"请求之前咯:%@",helper);
    } uploadProgress:nil downloadProgress:nil cachePreload:^(MLAPIHelper * _Nonnull apiHelper) {
        DDLogInfo(@"预加载咯: %@",helper.r_rows);
    } complete:^(MLAPIHelper * _Nonnull apiHelper) {
        DDLogInfo(@"请求结束咯:%@",helper);
    } success:^(MLAPIHelper * _Nonnull apiHelper) {
        DDLogInfo(@"请求成功咯:%@",helper.r_rows);
    } failure:^(MLAPIHelper * _Nonnull apiHelper, NSError * _Nonnull error) {
        DDLogInfo(@"请求失败咯:%@",helper.responseError.localizedDescription);
    } error:^(MLAPIHelper * _Nonnull apiHelper, NSError * _Nonnull error) {
        DDLogInfo(@"请求错误咯:%@",helper.responseError.localizedDescription);
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    DDLogInfo(@"alert");
}

#pragma mark - request
- (void)afterCachePreloaded:(MLAPIHelper *)apiHelper {
    if ([apiHelper isMemberOfClass:[TestAPIHelper class]]) {
        TestAPIHelper *helper = (TestAPIHelper*)apiHelper;
        DDLogInfo(@"预加载回调 %@",helper.r_rows);
    }
}

- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper {
    if ([apiHelper isMemberOfClass:[TestAPIHelper class]]) {
        TestAPIHelper *helper = (TestAPIHelper*)apiHelper;
        DDLogInfo(@"请求成功回调 %@",helper.r_rows);
    }
}

- (void)afterRequestFailed:(MLAPIHelper *)apiHelper {
    if ([apiHelper isMemberOfClass:[TestAPIHelper class]]) {
        DDLogError(@"请求失败回调 %@",apiHelper.responseError.localizedDescription);
    }else{
        [super afterRequestFailed:apiHelper];
    }
}

- (void)afterRequestSucceedForCaredAboutAPIHelper:(MLAPIHelper*)apiHelper {
    if ([apiHelper isKindOfClass:[UUIDAPIHelper class]]) {
        DDLogInfo(@"关心请求成功 %@",apiHelper);
    }
}

@end
