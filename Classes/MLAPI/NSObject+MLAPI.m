//
//  NSObject+MLAPI.m
//  MLKitExample
//
//  Created by molon on 16/7/19.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NSObject+MLAPI.h"
#import <objc/runtime.h>
#import "MLAPIHelper.h"
#import "MLKitMacro.h"

@interface CareAboutAPIHelperNotificationObserver : NSObject

@property (nonatomic, strong) NSMutableArray *careAboutAPIHelperNotificationNames;
@property (nonatomic, weak) id<MLAPICareAboutCallbackProtocol> delegate;

@end

@implementation CareAboutAPIHelperNotificationObserver

- (void)dealloc {
    //移除观察者
    if (self.careAboutAPIHelperNotificationNames.count>0) {
//        [self.careAboutAPIHelperNotificationNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [[NSNotificationCenter defaultCenter]removeObserver:self name:obj object:nil];
//        }];
        //这个类只会add关心请求的通知，没有其他的，直接移除全部观察者就OK啦
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}

- (void)careAboutAPIHelperClass:(Class)apiHelperClass {
    NSString *notificationName = [NSString stringWithFormat:@"%@%@",MLAPIHelperStateDidChangeNotificationNamePrefix,NSStringFromClass(apiHelperClass)];
    if ([self.careAboutAPIHelperNotificationNames containsObject:notificationName]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(careAboutAPIHelperNotificationCallback:) name:notificationName object:nil];
    
    //记录下
    if (!self.careAboutAPIHelperNotificationNames) {
        self.careAboutAPIHelperNotificationNames = [NSMutableArray array];
    }
    [self.careAboutAPIHelperNotificationNames addObject:notificationName];
}

- (void)careAboutAPIHelperNotificationCallback:(NSNotification*)notification {
    MLAPIHelper *apiHelper = notification.userInfo[MLAPIHelperStateDidChangeNotificationAPIHelperKeyForUserInfo];
    if (apiHelper.state==MLAPIHelperStateRequestSucceed) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(afterRequestSucceedForCaredAboutAPIHelper:)]) {
            [self.delegate afterRequestSucceedForCaredAboutAPIHelper:apiHelper];
        }
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didChangeStateForCaredAboutAPIHelper:)]) {
        [self.delegate didChangeStateForCaredAboutAPIHelper:apiHelper];
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
