//
//  NSObject+MLAPI.m
//  MLKitExample
//
//  Created by molon on 16/7/19.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NSObject+MLAPI.h"
#import <objc/runtime.h>
#import "MLAPIManager.h"
#import "MLKitMacro.h"
#import "MLAPIHelper.h"

@interface CareAboutAPIHelperNotificationObserver : NSObject

@property (nonatomic, weak) id<MLAPICareAboutCallbackProtocol> delegate;

@end

@implementation CareAboutAPIHelperNotificationObserver {
    NSMutableArray *_careAboutAPIHelperNotificationNames;
    NSInteger _lastPostTag;
}

- (void)dealloc {
    //移除观察者
    if (_careAboutAPIHelperNotificationNames.count>0) {
        //这个类只会add关心请求的通知，没有其他的，直接移除全部观察者就OK啦
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}

- (void)careAboutAPIHelperClass:(Class)apiHelperClass {
    NSString *notificationName = [NSString stringWithFormat:@"%@%@",MLAPIHelperStateDidChangeNotificationNamePrefix,NSStringFromClass(apiHelperClass)];
    if ([_careAboutAPIHelperNotificationNames containsObject:notificationName]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(careAboutAPIHelperNotificationCallback:) name:notificationName object:nil];
    
    //记录下
    if (!_careAboutAPIHelperNotificationNames) {
        _careAboutAPIHelperNotificationNames = [NSMutableArray array];
    }
    [_careAboutAPIHelperNotificationNames addObject:notificationName];
}

- (void)careAboutAPIHelperNotificationCallback:(NSNotification*)notification {
    NSInteger postTag = [notification.userInfo[MLAPIHelperStateDidChangeNotificationPostTagKeyForUserInfo] integerValue];
    if (postTag==_lastPostTag) {
        return;
    }
    _lastPostTag = postTag;
    
    MLAPIHelper *apiHelper = notification.userInfo[MLAPIHelperStateDidChangeNotificationAPIHelperKeyForUserInfo];
    if (apiHelper) {
        if (apiHelper.state==MLAPIHelperStateRequestSucceed) {
            if (_delegate&&[_delegate respondsToSelector:@selector(afterRequestSucceedForCaredAboutAPIHelper:)]) {
                [_delegate afterRequestSucceedForCaredAboutAPIHelper:apiHelper];
            }
        }
        if (_delegate&&[_delegate respondsToSelector:@selector(didChangeStateForCaredAboutAPIHelper:)]) {
            [_delegate didChangeStateForCaredAboutAPIHelper:apiHelper];
        }
    }
}

@end

@interface NSObject()

@property (nonatomic, strong) CareAboutAPIHelperNotificationObserver *careAboutMLAPIHelperNotificationObserver;

@end

@implementation NSObject (MLAPI)

SYNTH_DYNAMIC_PROPERTY_OBJECT(careAboutMLAPIHelperNotificationObserver, setCareAboutMLAPIHelperNotificationObserver:, RETAIN_NONATOMIC, CareAboutAPIHelperNotificationObserver *)

- (void)careAboutMLAPIHelperClass:(Class)apiHelperClass {
    if (!self.careAboutMLAPIHelperNotificationObserver) {
        self.careAboutMLAPIHelperNotificationObserver = [CareAboutAPIHelperNotificationObserver new];
        self.careAboutMLAPIHelperNotificationObserver.delegate = (id<MLAPICareAboutCallbackProtocol>)self;
    }
    
    [self.careAboutMLAPIHelperNotificationObserver careAboutAPIHelperClass:apiHelperClass];
}

@end
