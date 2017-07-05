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
 whether click background to retry when retry button displays
 */
@property (nonatomic, assign) BOOL canClickBackgroundToRetry;

/**
 custom retry button image
 */
@property (nonatomic, strong) UIImage *retryButtonImage;

/**
 *  whether penetrable
 */
@property (nonatomic, assign) BOOL penetrable;

@end
