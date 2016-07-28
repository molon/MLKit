//
//  MLAPIManager.h
//  MLKitExample
//
//  Created by molon on 16/7/14.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@class MLAPIHelper;
@class MLAPICacheItem;

@interface MLAPIManager : NSObject

@property (nonatomic, strong, readonly) AFHTTPSessionManager *httpSessionManager;

/**
 单例
 */
+ (instancetype)defaultManager;

/**
 初始化安装，一般在程序刚启动时候执行，baseURL和configuration和AFHTTPSessionManager用法一致
 */
- (void)setupWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration;

/**
 使用接口对象请求
 */
- (void)requestWithAPIHelper:(MLAPIHelper*)apiHelper
                      before:(nullable BOOL (^)(MLAPIHelper *apiHelper))beforeBlock
              uploadProgress:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSProgress *uploadProgress))uploadProgressBlock
            downloadProgress:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSProgress *downloadProgress))downloadProgressBlock
                cachePreload:(nullable BOOL (^)(MLAPIHelper *apiHelper))cachePreloadBlock
                    complete:(nullable BOOL (^)(MLAPIHelper *apiHelper))completeBlock
                     success:(nullable BOOL (^)(MLAPIHelper *apiHelper))successBlock
                     failure:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                       error:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock
              callbackObject:(nullable id)callbackObject;

/**
 获取某接口对象当前所对应的缓存内容,同步方法
 */
- (nullable MLAPICacheItem*)cacheForAPIHelper:(MLAPIHelper*)apiHelper;

@end

NS_ASSUME_NONNULL_END