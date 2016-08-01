//
//  MLLazyLoadViewController.h
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLLazyLoadTableView,MLLazyLoadTableViewCell;
@interface MLLazyLoadViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong, readonly) MLLazyLoadTableView *tableView;
@property (nonatomic, assign, readonly) NSInteger currentPageNo;

- (BOOL)autoRefreshAtFirstDisplay;
- (NSString*)keyOfEntryIDForDeduplication;

- (NSInteger)lazyLoadSection;
- (NSInteger)exceptTopRowCount;
- (MLLazyLoadTableViewCell*)lazyLoadCell;

- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper  __attribute__((objc_requires_super));
- (void)afterRequestFailed:(MLAPIHelper *)apiHelper  __attribute__((objc_requires_super));

@end
