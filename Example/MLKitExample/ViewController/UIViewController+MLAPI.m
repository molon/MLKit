//
//  UIViewController+MLAPI.m
//  MLKitExample
//
//  Created by molon on 16/7/28.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIViewController+MLAPI.h"
#import "MLProgressHUD.h"

@implementation UIViewController (MLAPI)
//都写上是为了防止某VC不注意调用super的某些方法而其并不存在
- (void)afterCachePreloaded:(MLAPIHelper *)apiHelper{}
- (void)uploadProgress:(NSProgress *)progress forAPIHelper:(MLAPIHelper *)apiHelper{}
- (void)downloadProgress:(NSProgress *)progress forAPIHelper:(MLAPIHelper *)apiHelper{}
- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper{}

- (void)beforeRequest:(MLAPIHelper *)apiHelper{
    [MLProgressHUD showIndeterminateHUDOnView:self.view message:nil detailMessage:nil yOffset:0];
}

- (void)afterRequestCompleted:(MLAPIHelper *)apiHelper{
    [MLProgressHUD hideIndeterminateHUDsOnView:self.view];
}

- (void)afterRequestFailed:(MLAPIHelper *)apiHelper {
    [MLProgressHUD showOnView:kAppDelegate.window message:nil detailMessage:apiHelper.responseError.localizedDescription customView:nil userInteractionEnabled:NO yOffset:-50.0f hideDelay:1.5f];
}

- (void)afterRequestError:(MLAPIHelper *)apiHelper {
    [self afterRequestFailed:apiHelper];
}

@end
