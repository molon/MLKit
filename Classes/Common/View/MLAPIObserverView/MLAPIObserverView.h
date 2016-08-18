//
//  MLAPIObserverView.h
//  MLKitExample
//
//  Created by molon on 16/8/11.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLAPIHelper.h"

@interface MLAPIObserverView : UIView

/**
 the api helper observing
 */
@property (nonatomic, strong) MLAPIHelper *observingAPIHelper;

/**
 state, if no observingAPIHelper, the state would be MLAPIHelperStateInit
 */
@property (nonatomic, assign) MLAPIHelperState state;

/**
 retry block
 */
@property (nonatomic, copy) void (^retryBlock)(MLAPIObserverView *view);

@end
