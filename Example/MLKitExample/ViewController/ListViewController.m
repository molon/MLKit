//
//  ListViewController.m
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "ListViewController.h"
#import "MLLazyLoadTableView.h"
#import <MLRefreshControl.h>
#import "TestLazyLoadAPIHelper.h"
#import "ArticleTableViewCell.h"

@interface ListViewController ()

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:[ArticleTableViewCell class] forCellReuseIdentifier:[ArticleTableViewCell cellReuseIdentifier]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell cellReuseIdentifier]];
    
    WEAK_SELF
    [self.tableView setRequestingAPIHelperBlock:^MLAPIHelper * _Nonnull(MLLazyLoadTableView * _Nonnull tableView, BOOL refreshing) {
        STRONG_SELF
        TestLazyLoadAPIHelper *helper = [TestLazyLoadAPIHelper new];
        
        if (refreshing) {
            helper.p_pageNo = 1;
        }else{
            helper.p_pageNo = self.currentPageNo+1;
        }
        
        [helper requestWithCallbackObject:self];
        
        return helper;
    }];
}

- (NSString*)keyOfEntryIDForDeduplication {
    return @"ID";
}

#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell cellReuseIdentifier] forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

@end
