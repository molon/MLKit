//
//  MLKitManager.h
//  MLKitExample
//
//  Created by molon on 16/7/13.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLKitManager : NSObject

+ (instancetype)defaultManager;

- (void)setupWithDDLog:(BOOL)ddlog;

@end

NS_ASSUME_NONNULL_END