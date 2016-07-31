//
//  MLRefreshControlTypes.h
//
//  Created by molon on 15/8/19.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#pragma once

/**
 The height of refresh control
 */
#define kMLRefreshControlViewHeight 50.0f

/**
 The animate duration
 */
#define kMLRefreshControlAnimateDuration .25f

/**
 The executing block when refreshing
 */
typedef void (^MLRefreshControlActionBlock)(void);

/**
 Current state of refresh control
 */
typedef NS_ENUM(NSUInteger, MLRefreshControlState) {
    /**
     Normal
     */
    MLRefreshControlStateNormal = 0,
    /**
     Pulling, but has not reached the critical point
     */
    MLRefreshControlStatePulling,
    /**
     Overstep the critical point, refresh if stop dragging.
     */
    MLRefreshControlStateOverstep,
    /**
     Refreshing
     */
    MLRefreshControlStateRefreshing,
};

typedef NS_ENUM(NSUInteger, MLRefreshControlViewStyle) {
    /**
     The refresh control will follow the scrolling of scrollView
     */
    MLRefreshControlViewStyleFollow = 0,
    /**
     The refresh control will not follow the scrolling of scrollView
     */
    MLRefreshControlViewStyleFixed,
};

