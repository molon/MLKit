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
 whether click background to refresh when refresh button displays
 */
@property (nonatomic, assign) BOOL clickBackgroundToRefresh;

/**
 custom retry button image
 */
@property (nonatomic, strong) UIImage *retryButtonImage;

/**
 *  whether penetrable
 */
@property (nonatomic, assign) BOOL penetrable;

@end
