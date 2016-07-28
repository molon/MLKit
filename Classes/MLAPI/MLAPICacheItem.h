//
//  MLAPICacheItem.h
//  MLKitExample
//
//  Created by molon on 16/7/22.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLAPICacheItem : NSObject<NSCoding>

@property (nonatomic, assign, readonly) NSTimeInterval unixTime;
@property (nonatomic, strong, readonly, nullable) id responseEntry;

- (instancetype)initWithUnixTime:(NSTimeInterval)unixTime responseEntry:(nullable id)responseEntry;

- (BOOL)isExpiredForLifeTime:(NSTimeInterval)lifeTime;

@end

NS_ASSUME_NONNULL_END