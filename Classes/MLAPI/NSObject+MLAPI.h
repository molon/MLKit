//
//  NSObject+MLAPI.h
//  MLKitExample
//
//  Created by molon on 16/7/19.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLAPIHelper;

/*
 MLAutoReplace regex replacer config ->
 
 regex:
 ^\s*(\s*\}\s*else\s*|)(\w+APIHelper)\/if$
 
 replaceContent:
 <{0}>if ([apiHelper isMemberOfClass:[<{1}> class]]) {
 <{1}> *helper = (<{1}>*)apiHelper;
 <#custom#>
 }
 
 Example:
 Input `TextAPIHelper/if`
 Auto replace to
 `
 if ([apiHelper isMemberOfClass:[TestAPIHelper class]]) {
 TestAPIHelper *helper = (TestAPIHelper*)apiHelper;
 <#custom#>
 }
 `
 
 regex replacer config 2:
 
 regex:
 ^\s*(\w+APIHelper)\/s$
 
 replaceContent:
 <{0}> *helper = (<{0}>*)apiHelper;
 
 Example:
 Input `TextAPIHelper/s`
 Auto replace to `TestAPIHelper *helper = (TestAPIHelper*)apiHelper;`
 */

@protocol MLAPICareAboutCallbackProtocol <NSObject>

@optional
/**
 关心的请求的状态有改动就会调用此方法，此方法均会在请求回调对象执行完回调后执行
 */
- (void)didChangeStateForCaredAboutAPIHelper:(MLAPIHelper*)apiHelper;

/**
 关心的请求变成成功状态就会调用此方法，便捷使用的方法，此方法会在didChangeStateForCaredAboutAPIHelper方法执行完毕后执行
 */
- (void)afterRequestSucceedForCaredAboutAPIHelper:(MLAPIHelper*)apiHelper;

@end

@protocol MLAPICallbackProtocol <MLAPICareAboutCallbackProtocol>

@optional

/**
 开始请求之前
 */
- (void)beforeRequest:(MLAPIHelper *)apiHelper;

/**
 请求预加载后
 */
- (void)afterCachePreloaded:(MLAPIHelper *)apiHelper;

/**
 上传进度
 */
- (void)uploadProgress:(NSProgress *)progress forAPIHelper:(MLAPIHelper *)apiHelper;

/**
 下载进度
 */
- (void)downloadProgress:(NSProgress *)progress forAPIHelper:(MLAPIHelper *)apiHelper;

/**
 请求完毕后，无论是成功失败还是错误，都会先执行
 */
- (void)afterRequestCompleted:(MLAPIHelper *)apiHelper;

/**
 请求成功后
 */
- (void)afterRequestSucceed:(MLAPIHelper *)apiHelper;

/**
 请求失败后
 */
- (void)afterRequestFailed:(MLAPIHelper *)apiHelper;

/**
 请求错误后
 */
- (void)afterRequestError:(MLAPIHelper *)apiHelper;

@end

@interface NSObject (MLAPI)

#pragma mark - 便捷关心机制
/**
 关心某请求类，这样无论这个请求是从哪里发出的就会收到讯息，执行相应操作，主要是为了做数据同步
 */
- (void)careAboutMLAPIHelperClass:(Class)apiHelperClass;

@end

NS_ASSUME_NONNULL_END
