//
//  TestAPIHelper.m
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "TestAPIHelper.h"

@implementation TestAPIHelper

- (NSString *)configureAPIName {
    return @"hi_json";
}

- (MLAPIHelperRequestMethod)configureRequestMethod {
    return MLAPIHelperRequestMethodPOST;
}

@end
