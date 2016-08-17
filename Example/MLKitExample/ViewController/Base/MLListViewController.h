//
//  MLListViewController.h
//  MLKitExample
//
//  Created by molon on 16/8/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLAutoRecordFrameTableView;
@interface MLListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong, readonly) MLAutoRecordFrameTableView *tableView;
@property (nonatomic, strong, readonly) MLAPIObserverView *apiObserverView;

/**
 Like `loadView`
 */
- (void)loadTableView;

/**
 Like `loadView`
 */
- (void)loadAPIObserverView;

@end

NS_ASSUME_NONNULL_END
