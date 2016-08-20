//
//  ArticleListViewController.m
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "ArticleListViewController.h"
#import <MLLazyLoadTableView.h>
#import <MLRefreshControl.h>
#import <DefaultMLLazyLoadTableViewCell.h>

#import "TestLazyLoadAPIHelper.h"
#import "ArticleTableViewCell.h"

@interface ExampleLazyLoadEmptyTipsView : UIView

@end

@implementation ExampleLazyLoadEmptyTipsView {
    UILabel *_contentLabel;
    MLLayout *_layout;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _contentLabel = ({
            UILabel *label = [UILabel new];
            label.text = @"暂无内容";
            label.font = [UIFont systemFontOfSize:15.0f];
            [self addSubview:label];
            label;
        });
        
        _layout = [MLLayout layoutWithView:nil block:^(MLLayout * _Nonnull l) {
            l.justifyContent = MLLayoutJustifyContentCenter;
            l.alignItems = MLLayoutAlignmentCenter;
            l.sublayouts = @[
                             [MLLayout layoutWithView:_contentLabel block:nil],
                             ];
        }];
    }
    return self;
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_layout dirtyAllRelatedLayoutsAndLayoutViewsWithFrame:self.bounds];
}

@end

@interface ExampleLazyLoadTableViewCell : DefaultMLLazyLoadTableViewCell

@end

@implementation ExampleLazyLoadTableViewCell

#pragma mark - setter
- (void)setStatus:(MLLazyLoadCellStatus)status
{
    [super setStatus:status];
    
    //We use ExampleLazyLoadEmptyTipsView to indicate empty. so just set @"" here.
    if (status == MLLazyLoadCellStatusEmpty) {
        self.tipsLabel.text = @"";
    }
    
    [self setNeedsLayout];
}

@end

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
        
        //append to list
        self.currentPageNo = 1;
        [self.tableView appendEntries:helper.r_rows noMore:NO apiHelper:helper];
    }
}

- (BOOL)autoRefreshWhenFirstDidAppear {
    return YES;
}

- (BOOL)autoObserveFirstRequest {
    return NO;
}

- (NSString*)configureKeyOfEntryIDForDeduplication {
    return @"ID";
}

- (LazyLoadAPIHelper *)lazyLoadHelperWithRefreshing:(BOOL)refreshing {
    TestLazyLoadAPIHelper *helper = [TestLazyLoadAPIHelper new];
    return helper;
}

- (UIView*)configureBackgroundViewIfEmptyList {
    return [ExampleLazyLoadEmptyTipsView new];
}

- (MLLazyLoadTableViewCell*)configureLazyLoadCell {
    return [ExampleLazyLoadTableViewCell new];
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
