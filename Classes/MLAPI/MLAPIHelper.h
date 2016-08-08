//
//  MLAPIHelper.h
//  MLKitExample
//
//  Created by molon on 16/7/14.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFURLRequestSerialization.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MLAPIHelperState) {
    MLAPIHelperStateInit = 0, //初始状态
    MLAPIHelperStateCachePreloaded, //缓存预加载，只有缓存先返回并且去请求的行为才会认作是预加载，若没有去请求则认作是直接请求成功了。
    MLAPIHelperStateRequesting, //请求中
    MLAPIHelperStateRequestSucceed, //请求成功
    MLAPIHelperStateRequestFailed,//请求失败
    MLAPIHelperStateRequestError,//请求错误
};

typedef NS_ENUM(NSUInteger, MLAPIHelperCacheType) {
    MLAPIHelperCacheTypeNone = 0, //不缓存任何东西
    MLAPIHelperCacheTypeReturnValidCacheElseRequest, //缓存有效则返回它，否则去请求
    MLAPIHelperCacheTypeReturnCacheThenRequestIfCacheIsInvalid, //无论缓存是否有效都先返回它，但若缓存是无效状态的话会去执行请求过程，否则不执行，无效缓存先返回这个认作是预加载
    MLAPIHelperCacheTypeReturnCacheThenAlwaysRequest, //无论缓存是否有效都先返回它，然后总是去执行请求过程，这个type下的缓存就不是为了减少网络吞吐量了，完全是为了让数据更快的显示在页面上，提高用户体验。缓存先返回这个认作是预加载
};

typedef NS_ENUM(NSUInteger, MLAPIHelperRequestMethod) {
    MLAPIHelperRequestMethodGET = 0,
    MLAPIHelperRequestMethodPOST,
    MLAPIHelperRequestMethodPUT,
    MLAPIHelperRequestMethodDELETE,
    MLAPIHelperRequestMethodHEAD,
    MLAPIHelperRequestMethodPATCH,
};

FOUNDATION_EXPORT NSTimeInterval const MLAPIHelperDefaultTimeoutInterval;

FOUNDATION_EXPORT NSString * const MLAPIHelperStateDidChangeNotificationNamePrefix;
FOUNDATION_EXPORT NSString * const MLAPIHelperStateDidChangeNotificationAPIHelperKeyForUserInfo;

FOUNDATION_EXPORT NSString * MLAPI_HTTPMethod(MLAPIHelperRequestMethod requestMethod);
FOUNDATION_EXPORT BOOL MLAPI_IsErrorCancelled(NSError *error);

FOUNDATION_EXPORT NSString * MLAPI_AFQueryStringFromParameters(NSDictionary *parameters);

@class MLAPICacheItem;
@interface MLAPIHelper : NSObject

/**
 缓存类型，默认不缓存，缓存也只对MLAPIHelperRequestMethodGET类型有效
 */
@property (nonatomic, assign) MLAPIHelperCacheType cacheType;

/**
 只是为了方便传递对象罢了,爱用不用
 */
@property (nonatomic, strong, nullable) id userInfo;

#pragma mark - 只读的一些属性
/**
 base url
 */
@property (nonatomic, strong, readonly, nullable) NSURL *baseURL;

/**
 api name
 */
@property (nonatomic, copy, readonly) NSString *apiName;

/**
 request method GET POST ....
 */
@property (nonatomic, assign, readonly) MLAPIHelperRequestMethod requestMethod;

/**
 当前的请求状态
 */
@property (nonatomic, assign, readonly) MLAPIHelperState state;

/**
 接口返回的原始数据，便于自定义
 */
@property (nonatomic, strong, readonly, nullable) id responseEntry;

/**
 接口如果失败或者错误之后返回的信息
 */
@property (nonatomic, strong, readonly, nullable) NSError *responseError;

/**
 最后一次调用请求所使用的task记录
 */
@property (nonatomic, strong, readonly, nullable) NSURLSessionDataTask *dataTask;

/**
 结果是否是以缓存响应的
 */
@property (nonatomic, assign, readonly) BOOL isRespondWithCache;

/**
 当前的回调对象
 */
@property (nonatomic, weak, readonly, nullable) id callbackObject;

#pragma mark - 每个helper都必须继承的方法

/**
 配置接口名称
 */
- (NSString*)configureAPIName;

/**
 配置接口请求方式
 */
- (MLAPIHelperRequestMethod)configureRequestMethod;

#pragma mark - 必须实现的方法，一般在项目的接口基类里去实现
/**
 返回响应数据所表示的错误，如果返回nil，则表示此响应代表着成功的
 */
- (nullable NSError*)errorOfResponseObject:(id)responseObject;

/**
 返回相应数据里表示实体的部分，例如responseObject[@"data"]
 */
- (nullable id)responseEntryOfResponseObject:(id)responseObject;

/**
 缓存的域，通常情况下是用户的唯一标识，用来区分不同用户的缓存内容，如果返回nil或空，则表示根
 MLAPICache -
    xxxxmd5
    [13612341234]yyyymd5
    [13612341234]zzzzmd5
    [13688888888]zzzzmd5
 */
- (nullable NSString*)currentCacheDomainName;

/**
 自定义根URL
 */
- (nullable NSURL*)configureBaseURL;

#pragma mark - 可选继承的方法
/**
 自定义超时时间，以秒为单位，默认是15
 */
- (NSTimeInterval)timeoutInterval;

/**
 缓存有效时长，以秒为单位，默认为-1，使用缓存的话请重载这个方法
 */
- (NSTimeInterval)cacheLifeTime;

/**
 自定义requestSerializer，否则就使用[MLAPIManager defaultManager].httpSessionManager里的
 */
- (AFHTTPRequestSerializer *)requestSerializer;

/**
 构造请求参数之前,每次allRequestParams都会调用,请只做请求参数相关内容
 */
- (void)beforeConstructRequestParams __attribute__((objc_requires_super));

/**
 对最终构造的请求参数做额外处理，每次allRequestParams最终都会调用，请只做请求参数相关内容
 */
- (void)treatWithConstructedRequestParams:(NSMutableDictionary*)params __attribute__((objc_requires_super));

/**
 对构造出来的请求URLRequest进行额外处理，例如重新设置HTTPHeaderField啊等等
 */
- (void)treatWithConstructedRequest:(NSMutableURLRequest*)mutableRequest __attribute__((objc_requires_super));

/**
 执行请求之前
 */
- (void)beforeRequest __attribute__((objc_requires_super));

/**
 请求预加载后
 */
- (void)afterCachePreloaded __attribute__((objc_requires_super));

/**
 上传进度
 */
- (void)uploadProgress:(NSProgress *)progress __attribute__((objc_requires_super));

/**
 下载进度
 */
- (void)downloadProgress:(NSProgress *)progress __attribute__((objc_requires_super));

/**
 请求完毕后，无论是成功失败还是错误，都会先执行
 */
- (void)afterRequestCompleted __attribute__((objc_requires_super));

/**
 请求成功后
 */
- (void)afterRequestSucceed __attribute__((objc_requires_super));

/**
 请求失败后
 */
- (void)afterRequestFailed __attribute__((objc_requires_super));

/**
 请求错误后
 */
- (void)afterRequestError __attribute__((objc_requires_super));

/**
 记录并且处理返回数据，做json数据到字典的转换
 */
- (void)handleResponseEntry:(id)responseEntry __attribute__((objc_requires_super));

/**
 记录并处理返回错误
 */
- (void)handleResponseError:(NSError*)responseError __attribute__((objc_requires_super));


#pragma mark - outcall
/**
 返回是否处于请求完成状态，可能是成功，失败，错误。
 */
- (BOOL)isRequestCompleted;

/**
 当前所对应的请求参数
 */
- (NSDictionary*)allRequestParams;

/**
 接口完整地址
 */
- (NSURL*)apiURL;

/**
 获取缓存内容，其为接口返回的原始数据，非MLAPIHelperRequestMethodGET类型直接返回nil
 */
- (nullable MLAPICacheItem*)cache;

/**
 取消请求
 */
- (void)cancel;

#pragma mark - block及callbackObject的混合回调请求方法
/**
 发出请求，指定回调对象，关于回调对象相关方法可查看NSObject+MLAPI
 */
- (void)requestWithBefore:(nullable BOOL (^)(MLAPIHelper *apiHelper))beforeBlock
           uploadProgress:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSProgress *uploadProgress))uploadProgressBlock
         downloadProgress:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSProgress *downloadProgress))downloadProgressBlock
             cachePreload:(nullable BOOL (^)(MLAPIHelper *apiHelper))cachePreloadBlock
                 complete:(nullable BOOL (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable BOOL (^)(MLAPIHelper *apiHelper))successBlock
                  failure:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                    error:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock
           callbackObject:(nullable id)callbackObject;

/**
 去除了上传下载进度的以及预加载回调block的稍简洁写法
 */
- (void)requestWithBefore:(nullable BOOL (^)(MLAPIHelper *apiHelper))beforeBlock
                 complete:(nullable BOOL (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable BOOL (^)(MLAPIHelper *apiHelper))successBlock
                  failure:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                    error:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock
           callbackObject:(nullable id)callbackObject;

/**
 去除了上传下载进度的以及预加载回调block的稍简洁写法，failure和error使用相同的回调
 */
- (void)requestWithBefore:(nullable BOOL (^)(MLAPIHelper *apiHelper))beforeBlock
                 complete:(nullable BOOL (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable BOOL (^)(MLAPIHelper *apiHelper))successBlock
           failureOrError:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))failureOrErrorBlock
           callbackObject:(nullable id)callbackObject;

#pragma mark - 只用block回调的请求方法
/**
 只用block回调的简洁写法
 */
- (void)requestWithBefore:(nullable void (^)(MLAPIHelper *apiHelper))beforeBlock
           uploadProgress:(nullable void (^)(MLAPIHelper *apiHelper, NSProgress *uploadProgress))uploadProgressBlock
         downloadProgress:(nullable void (^)(MLAPIHelper *apiHelper, NSProgress *downloadProgress))downloadProgressBlock
             cachePreload:(nullable void (^)(MLAPIHelper *apiHelper))cachePreloadBlock
                 complete:(nullable void (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable void (^)(MLAPIHelper *apiHelper))successBlock
                  failure:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                    error:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock;

/**
 去除了上传下载进度的以及预加载回调block的无callbackObject的简洁写法
 */
- (void)requestWithBefore:(nullable void (^)(MLAPIHelper *apiHelper))beforeBlock
                 complete:(nullable void (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable void (^)(MLAPIHelper *apiHelper))successBlock
                  failure:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                    error:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock;

/**
 去除了上传下载进度的以及预加载回调block的无callbackObject的简洁写法，failure和error使用相同的回调
 */
- (void)requestWithBefore:(nullable void (^)(MLAPIHelper *apiHelper))beforeBlock
                 complete:(nullable void (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable void (^)(MLAPIHelper *apiHelper))successBlock
           failureOrError:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))failureOrErrorBlock;

#pragma mark - 只用callbackObject回调的请求方法
/**
 只用callbackObject回调的简洁写法
 */
- (void)requestWithCallbackObject:(nullable id)callbackObject;

@end

NS_ASSUME_NONNULL_END



