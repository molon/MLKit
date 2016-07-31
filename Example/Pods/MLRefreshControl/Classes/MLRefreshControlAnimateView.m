//
//  MLRefreshControlAnimateView.m
//
//  Created by molon on 15/8/18.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLRefreshControlAnimateView.h"

@implementation MLRefreshControlAnimateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.state = MLRefreshControlStateNormal;
    }
    return self;
}

@end
