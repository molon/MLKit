//
//  AppDelegate.m
//  MLKitExample
//
//  Created by molon on 16/7/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "AppDelegate.h"
#import "MLKit.h"
#import <YYModel.h>

@interface MLAPIModelTransformProtocol : YYModelTransformProtocol

@end
@implementation MLAPIModelTransformProtocol

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapperForClass:(Class)cls {
    return @{
             @"ID":@"id",
             };
}

@end


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [YYModelTransformProtocol registerClass:[MLAPIModelTransformProtocol class]];
    
    [[MLKitManager defaultManager]setupWithDDLog:YES];
    [[MLAPIManager defaultManager]setupWithSessionConfiguration:nil];
    
    return YES;
}

@end
