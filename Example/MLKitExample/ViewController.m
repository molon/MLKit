//
//  ViewController.m
//  MLKitExample
//
//  Created by molon on 16/5/26.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "ViewController.h"
#import "BaseAPIHelper.h"
#import "UIViewController+MLAPI.h"

@protocol Article
@end
@interface Article : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSTimeInterval createTime;

@end
@implementation Article
@end

@interface TestAPIHelper: BaseAPIHelper

@property (nonatomic, copy) NSString *p_test;
@property (nonatomic, assign) NSInteger p_test2;
@property (nonatomic, strong) NSArray<Article *><Article> *r_rows;

@end
@implementation TestAPIHelper

- (NSString *)configureAPIName {
    return @"hi_json";
}

- (NSTimeInterval)cacheLifeTime {
    return 10.0f;
}

- (MLAPIHelperRequestMethod)configureRequestMethod {
    return MLAPIHelperRequestMethodPOST;
}

@end

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]init];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        _tableView = tableView;
    }
    return _tableView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _imageView = imageView;
    }
    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    [self.view addSubview:self.tableView];
    [self.view addSubview:self.imageView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"测试" style:UIBarButtonItemStylePlain target:self action:@selector(test)];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
    
    self.imageView.frame = [self.view centerFrameWithWidth:100 height:100];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}

#pragma mark - right item test
- (void)test
{
    TestAPIHelper *helper = [TestAPIHelper new];
    helper.p_test = @"testParam";
    helper.p_test2 = 100;
//    helper.cacheType = MLAPIHelperCacheTypeReturnCacheThenAlwaysRequest;
    
    //只用callbackObject的例子
    //        [helper requestWithCallbackObject:self];
    
    [helper requestWithBefore:^(MLAPIHelper * _Nonnull apiHelper) {
        DDLogDebug(@"请求之前咯:%@",helper);
    } uploadProgress:nil downloadProgress:nil cachePreload:^(MLAPIHelper * _Nonnull apiHelper) {
        DDLogInfo(@"预加载咯: %@",helper.r_rows);
    } complete:^(MLAPIHelper * _Nonnull apiHelper) {
        DDLogDebug(@"请求结束咯:%@",helper);
    } success:^(MLAPIHelper * _Nonnull apiHelper) {
        DDLogDebug(@"请求成功咯:%@",helper.r_rows);
    } failure:^(MLAPIHelper * _Nonnull apiHelper, NSError * _Nonnull error) {
        DDLogDebug(@"请求失败咯:%@",helper.responseError.localizedDescription);
    } error:^(MLAPIHelper * _Nonnull apiHelper, NSError * _Nonnull error) {
        DDLogDebug(@"请求错误咯:%@",helper.responseError.localizedDescription);
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    DDLogDebug(@"alert");
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

@end
