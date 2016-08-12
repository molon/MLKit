//
//  MLUserDefaults.h
//  MLKitExample
//
//  Created by molon on 16/8/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLUserDefaults : NSObject

+ (instancetype)sharedInstance;

/**
 *  disable auto synchronize temporarily
 */
@property (nonatomic, assign) BOOL disableSynchronize;

#pragma mark - for override
/**
 for special default values, feather of MLPersonalModel
 */
+ (NSDictionary *)modelCustomPropertyDefaultValueMapper __attribute__((objc_requires_super));

/**
 keys which will be ignored by auto set-get from StandardUserDefaults
 */
- (nullable NSArray *)configureIgnoreKeys;

/**
 override the method if need do something after first set values from StandardUserDefaults
 */
- (void)afterFirstSetValuesFromStandardUserDefaults;

@end

NS_ASSUME_NONNULL_END
