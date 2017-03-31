//
//  AppDelegate.m
//  MLKitExample
//
//  Created by molon on 16/7/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "AppDelegate.h"

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
    
//    [self printGFWHostsForProxifier];
    
    return YES;
}

- (void)printGFWHostsForProxifier {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"gfw" ofType:@"json"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *strs = [string objectFromJSONString];
    __block NSString *resultString = @"";
    for (NSString *s in strs) {
        [s enumerateRegexMatches:@"[a-zA-Z0-9]+\\.[a-zA-Z]{2,5}$" options:NSRegularExpressionCaseInsensitive usingBlock:^(NSString * _Nonnull match, NSRange matchRange, BOOL * _Nonnull stop) {
            resultString = [resultString stringByAppendingFormat:@"*.%@;",match];
            *stop = YES;
        }];
    }
    DDLogDebug(@"%@",resultString);
}
@end
