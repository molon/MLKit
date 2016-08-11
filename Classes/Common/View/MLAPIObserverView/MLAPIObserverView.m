//
//  MLAPIObserverView.m
//  MLKitExample
//
//  Created by molon on 16/8/11.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAPIObserverView.h"

@interface MLAPIObserverView()

@end

@implementation MLAPIObserverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.state = MLAPIHelperStateInit;
    }
    return self;
}

#pragma mark - dealloc
- (void)dealloc
{
    [_observingAPIHelper removeObserver:self forKeyPath:@"state" context:nil];
}

#pragma mark - setter
- (void)setObservingAPIHelper:(MLAPIHelper *)observingAPIHelper
{
    [_observingAPIHelper removeObserver:self forKeyPath:@"state" context:nil];
    
    _observingAPIHelper = observingAPIHelper;
    
    if (_observingAPIHelper) {
        [_observingAPIHelper addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    }else{
        self.state = MLAPIHelperStateInit;
    }
}

- (void)setState:(MLAPIHelperState)state
{
    _state = state;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"state" isEqualToString:keyPath]) {
        if ([object isEqual:_observingAPIHelper]) {
            self.state = _observingAPIHelper.state;
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
