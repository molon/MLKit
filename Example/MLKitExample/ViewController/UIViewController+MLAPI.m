//
//  UIViewController+MLAPI.m
//  MLKitExample
//
//  Created by molon on 16/7/28.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIViewController+MLAPI.h"

@implementation UIViewController (MLAPI)
//都写上是为了防止某VC不注意调用super的某些方法而其并不存在
- (void)afterCachePreloaded:(MLAPIHelper *)apiHelper{}
- (void)uploadProgress:(NSProgress *)progress forAPIHelper:(MLAPIHelper *)apiHelper{}
- (void)downloadProgress:(NSProgress *)progress forAPIHelper:(MLAPIHelper *)apiHelper{}
- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper{}

#warning SHOW HUD得搞成自动显示hud的通用处理
- (void)beforeRequest:(MLAPIHelper *)apiHelper{}
#warning HIDE HUD得搞成自动消失hud的通用处理
- (void)afterRequestCompleted:(MLAPIHelper *)apiHelper{}

#warning SHOW ERROR TIPS得搞成错误信息显示的通用处理
- (void)afterRequestFailed:(MLAPIHelper *)apiHelper {
    DDLogError(@"请求失败:%@",apiHelper.responseError.localizedDescription);
}

- (void)afterRequestError:(MLAPIHelper *)apiHelper {
    [self afterRequestFailed:apiHelper];
}

@end
