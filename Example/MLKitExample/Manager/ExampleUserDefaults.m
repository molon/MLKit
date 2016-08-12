//
//  ExampleUserDefaults.m
//  MLKitExample
//
//  Created by molon on 16/8/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "ExampleUserDefaults.h"

@implementation ExampleUserDefaults

+ (NSDictionary *)modelCustomPropertyDefaultValueMapper {
    NSMutableDictionary *dict = [[super modelCustomPropertyDefaultValueMapper]mutableCopy];
    [dict addEntriesFromDictionary:@{
                                    @"username":@"molon",
                                    @"password":@"123455"
                                    }];
    return dict;
}

@end
