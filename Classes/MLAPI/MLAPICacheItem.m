//
//  MLAPICacheItem.m
//  MLKitExample
//
//  Created by molon on 16/7/22.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAPICacheItem.h"
#import "MLKitMacro.h"
#import "NSDate+MLAdd.h"

@implementation MLAPICacheItem

- (instancetype)initWithUnixTime:(NSTimeInterval)unixTime responseEntry:(id)responseEntry {
    self = [super init];
    if (self) {
        _unixTime = unixTime;
        _responseEntry = responseEntry;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_responseEntry forKey:SELSTR(responseEntry)];
    [aCoder encodeDouble:_unixTime forKey:SELSTR(unixTime)];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    _responseEntry = [aDecoder decodeObjectForKey:SELSTR(responseEntry)];
    _unixTime = [aDecoder decodeDoubleForKey:SELSTR(unixTime)];
    
    return self;
}

- (BOOL)isExpiredForLifeTime:(NSTimeInterval)lifeTime {
    NSTimeInterval nowTime = [[NSDate date]timeIntervalSince1970];
    return (nowTime-_unixTime>lifeTime);
}

@end
