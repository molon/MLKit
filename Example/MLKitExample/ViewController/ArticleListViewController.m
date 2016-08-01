//
//  ArticleListViewController.m
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "ArticleListViewController.h"
#import "MLLazyLoadTableView.h"
#import <MLRefreshControl.h>
#import "TestLazyLoadAPIHelper.h"
#import "ArticleTableViewCell.h"

@interface ArticleListViewController ()

@end

@implementation ArticleListViewController

DEALLOC_SELF_DLOG

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSStringFromClass([self class]);
    
    [self.tableView registerClass:[ArticleTableViewCell class] forCellReuseIdentifier:[ArticleTableViewCell cellReuseIdentifier]];
    
    //如果第一页有缓存，我们从缓存里先直接把数据拿出来显示
    //这里只是个演示特殊的拿缓存使用的例子罢了，不用太关心
    TestLazyLoadAPIHelper *helper = [TestLazyLoadAPIHelper new];
    helper.p_pageNo = 1;
    MLAPICacheItem *cache = [helper cache];
    if (cache) {
        [helper handleResponseEntry:cache.responseEntry];
        [self.tableView.entries addObjectsFromArray:helper.r_rows];
    }
}

- (NSString*)keyOfEntryIDForDeduplication {
    return @"ID";
}

- (LazyLoadAPIHelper *)lazyLoadHelperWithRefreshing:(BOOL)refreshing {
    TestLazyLoadAPIHelper *helper = [TestLazyLoadAPIHelper new];
    if (refreshing) {
        helper.cacheType = MLAPIHelperCacheTypeReturnCacheThenAlwaysRequest;
    }
    return helper;
}


#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ArticleTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
    cell.article = self.tableView.entries[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ArticleTableViewCell heightForRowUsingPureMLLayoutAtIndexPath:indexPath tableView:(MLAutoRecordFrameTableView*)tableView beforeLayout:^(UITableViewCell * _Nonnull protypeCell) {
        ((ArticleTableViewCell*)protypeCell).article = self.tableView.entries[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Article *article = self.tableView.entries[indexPath.row];
    
    [[UIApplication sharedApplication]openURL:article.url];
}

@end
