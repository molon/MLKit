//
//  DefaultMLAPIObserverView.h
//  MLKitExample
//
//  Created by molon on 16/8/11.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAPIObserverView.h"

@interface DefaultMLAPIObserverView : MLAPIObserverView

/**
 *  whether penetrable
 */
@property (nonatomic, assign) BOOL penetrable;

/**
 *  block should excuting after click retry button
 */
@property (nonatomic, copy) void (^didClickRetryButtonBlock)(DefaultMLAPIObserverView *view);

@end
