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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell cellReuseIdentifier]];
}

- (NSString*)keyOfEntryIDForDeduplication {
    return @"ID";
}

- (LazyLoadAPIHelper *)lazyLoadHelper {
    TestLazyLoadAPIHelper *helper = [TestLazyLoadAPIHelper new];
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
