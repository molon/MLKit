//
//  MLRefreshControlAnimateView.h
//
//  Created by molon on 15/8/18.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLRefreshControlTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLRefreshControlAnimateView : UIView

/**
 Current state
 */
@property (nonatomic, assign) MLRefreshControlState state;

/**
 Current pulling progess
 */
@property (nonatomic, assign) float pullingProgress;

@end

NS_ASSUME_NONNULL_END