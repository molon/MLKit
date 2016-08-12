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

@interface LazyLoadEmptyView : UIView

@end

@implementation LazyLoadEmptyView {
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
@interface ArticleListViewController ()

@end

@implementation ArticleListViewController

DEALLOC_SELF_DLOG

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSStringFromClass([self class]);
    
    [self.tableView registerClass:[ArticleTableViewCell class] forCellReuseIdentifier:[ArticleTableViewCell cellReuseIdentifier]];
}

- (NSString*)configureKeyOfEntryIDForDeduplication {
    return @"ID";
}

- (LazyLoadAPIHelper *)lazyLoadHelperWithRefreshing:(BOOL)refreshing {
    TestLazyLoadAPIHelper *helper = [TestLazyLoadAPIHelper new];
    return helper;
}

- (UIView*)configureBackgroundViewIfEmptyList {
    return [LazyLoadEmptyView new];
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
