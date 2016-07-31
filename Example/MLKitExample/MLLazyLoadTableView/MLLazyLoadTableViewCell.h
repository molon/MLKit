//
//  MLLazyLoadTableViewCell.h
//  TycoonBuy
//
//  Created by molon on 16/4/18.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 status for lazy-loading
 */
typedef NS_ENUM(NSUInteger, MLLazyLoadCellStatus) {
    /**
     init or refreshing
     */
    MLLazyLoadCellStatusInit,
    /**
     lazy-loading
     */
    MLLazyLoadCellStatusLoading,
    /**
     lazy load failed
     */
    MLLazyLoadCellStatusLoadFailed,
    /**
     no more entries
     */
    MLLazyLoadCellStatusNoMore,
    /**
     no entries
     */
    MLLazyLoadCellStatusEmpty,
};

@interface MLLazyLoadTableViewCell : UITableViewCell

@property (nonatomic, assign) MLLazyLoadCellStatus status;

@property (nonatomic, copy) void(^clickForRetryBlock)();

- (CGFloat)preferredHeightWithMaxWidth:(CGFloat)maxWidth;

@end
