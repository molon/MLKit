//
//  UIViewController+MLAPI.m
//  MLKitExample
//
//  Created by molon on 16/7/28.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIViewController+MLAPI.h"

@implementation UIViewController (MLAPI)

- (void)afterRequestFailed:(MLAPIHelper *)apiHelper {
    DDLogError(@"请求失败:%@",apiHelper.responseError.localizedDescription);
}

- (void)afterRequestError:(MLAPIHelper *)apiHelper {
    [self afterRequestFailed:apiHelper];
}

@end
