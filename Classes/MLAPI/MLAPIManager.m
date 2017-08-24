//
//  MLAPIManager.m
//  MLKitExample
//
//  Created by molon on 16/7/14.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAPIManager.h"
#import "MLKitMacro.h"
#import "MLAPIHelper.h"
#import "NSObject+MLAPI.h"
#import "NSNotificationCenter+MLAdd.h"
#import "MLThread.h"
#import <YYCache/YYCache.h>
#import "NSString+MLAdd.h"
#import "MLAPICacheItem.h"

NSString * const MLAPIHelperStateDidChangeNotificationNamePrefix = @"com.molon.MLAPI.didChangeStateForAPIHelper.";
NSString * const MLAPIHelperStateDidChangeNotificationAPIHelperKeyForUserInfo = @"apiHelper";
NSString * const MLAPIHelperStateDidChangeNotificationPostTagKeyForUserInfo = @"postTag";

NSString * const MLAPICacheRootDirectoryName = @"MLAPICache";

static inline void mlapi_dispatch_async_on_main_queue(void (^block)()) {
    if (dispatch_is_main_queue()) {
        block();
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), block);
}

#define ASSERT_MUST_EXCUTE_ON_MAIN_THREAD NSAssert(dispatch_is_main_queue(), @"%@ method of MLAPIManager must be excuted on main thread",NSStringFromSelector(_cmd));

#pragma mark - Category helper of other class
@interface MLAPIHelper(Private)

@property (nonatomic, assign) MLAPIHelperState state;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, weak) id callbackObject;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, assign) BOOL isRespondWithCache;
@property (nonatomic, assign) BOOL hasPreloaded;

- (void)reset;
- (NSURL*)apiURLWithParameters:(NSDictionary*)parameters;

@end

@interface AFHTTPSessionManager(MLAPI)
@end
@implementation AFHTTPSessionManager(MLAPI)

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                       baseURL:(NSURL*)baseURL
                    parameters:(id)parameters
             requestSerializer:(AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBodyWithBlock
  constructingRequestWithBlock:(void (^)(NSMutableURLRequest *request))constructingRequestWithBlock
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerializer?:self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:baseURL.scheme?baseURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:constructingBodyWithBlock error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }

    if (constructingRequestWithBlock) {
        constructingRequestWithBlock(request);
    }
    
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:uploadProgress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(task, error);
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                         baseURL:(NSURL*)baseURL
                                      parameters:(id)parameters
                               requestSerializer:(AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer
                    constructingRequestWithBlock:(void (^)(NSMutableURLRequest *request))constructingRequestWithBlock
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerializer?:self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:baseURL.scheme?baseURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    if (constructingRequestWithBlock) {
        constructingRequestWithBlock(request);
    }
    
    if (![method isEqualToString:@"GET"]) {
        downloadProgress = nil;
    }
    if (![method isEqualToString:@"POST"]) {
        uploadProgress = nil;
    }
    
    __block NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:request
                          uploadProgress:uploadProgress
                        downloadProgress:downloadProgress
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (error) {
                               if (failure) {
                                   failure(dataTask, error);
                               }
                           } else {
                               if (success) {
                                   success(dataTask, responseObject);
                               }
                           }
                       }];
    
    return dataTask;
}

@end

#pragma mark - MLAPIManager
@interface MLAPIManager()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@property (nonatomic, strong) YYCache *cache;

@end

@implementation MLAPIManager

+ (instancetype)defaultManager {
    static id _defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[self class] new];
    });
    
    return _defaultManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [YYCache cacheWithName:MLAPICacheRootDirectoryName];
    }
    return self;
}

- (void)setupWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration {
    mlapi_dispatch_async_on_main_queue(^{
        _httpSessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configuration];
        _httpSessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
}

- (AFHTTPSessionManager *)httpSessionManager {
    ASSERT_MUST_EXCUTE_ON_MAIN_THREAD
    
    return _httpSessionManager;
}

- (void)requestWithAPIHelper:(MLAPIHelper*)apiHelper
                      before:(nullable BOOL (^)(MLAPIHelper *apiHelper))beforeBlock
              uploadProgress:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSProgress *uploadProgress))uploadProgressBlock
            downloadProgress:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSProgress *downloadProgress))downloadProgressBlock
                cachePreload:(nullable BOOL (^)(MLAPIHelper *apiHelper))cachePreloadBlock
                    complete:(nullable BOOL (^)(MLAPIHelper *apiHelper))completeBlock
                     success:(nullable BOOL (^)(MLAPIHelper *apiHelper))successBlock
                     failure:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                       error:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock
              callbackObject:(nullable id)callbackObject {
    mlapi_dispatch_async_on_main_queue(^{
        NSAssert(_httpSessionManager, @"在请求之前请先setup MLAPIManager");
        NSParameterAssert(apiHelper);
        NSAssert(apiHelper.state==MLAPIHelperStateInit||[apiHelper isRequestCompleted], @"接口对象%@已经在请求过程中，不可重复请求",apiHelper);
        if (apiHelper.state!=MLAPIHelperStateInit&&![apiHelper isRequestCompleted]) {
            //在Release下可能会走到这，直接return吧
            return;
        }
        
        //先定义缓存key
        __block NSString *cacheKey = nil;
        
        //回调wrapper
        void (^uploadProgressWrapper)(NSProgress *) = ^(NSProgress *uploadProgress) {
            mlapi_dispatch_async_on_main_queue(^{
                [apiHelper uploadProgress:uploadProgress];
                BOOL goon = YES;
                if (uploadProgressBlock) {
                    goon = uploadProgressBlock(apiHelper,uploadProgress);
                }
                if (goon&&[callbackObject respondsToSelector:@selector(uploadProgress:forAPIHelper:)] ) {
                    [(id<MLAPICallbackProtocol>)callbackObject uploadProgress:uploadProgress forAPIHelper:apiHelper];
                }
            });
        };
        
        void (^downloadProgressWrapper)(NSProgress *) = ^(NSProgress *downloadProgress) {
            mlapi_dispatch_async_on_main_queue(^{
                [apiHelper downloadProgress:downloadProgress];
                BOOL goon = YES;
                if (downloadProgressBlock) {
                    goon = downloadProgressBlock(apiHelper,downloadProgress);
                }
                if (goon&&[callbackObject respondsToSelector:@selector(downloadProgress:forAPIHelper:)] ) {
                    [(id<MLAPICallbackProtocol>)callbackObject downloadProgress:downloadProgress forAPIHelper:apiHelper];
                }
            });
        };
        
#define GOON_CALLBACK(_method_) \
if (goon&&[callbackObject respondsToSelector:@selector(_method_:)]) { \
[(id<MLAPICallbackProtocol>)callbackObject _method_:apiHelper]; \
}
        
#define JUST_RETURN_APIHELPER_CALLBACK(_method_,_block_) \
{ \
[apiHelper _method_]; \
BOOL goon = YES; \
if (_block_) { \
goon = _block_(apiHelper); \
} \
GOON_CALLBACK(_method_) \
}
        
#define RETURN_APIHELPER_AND_ERROR_CALLBACK(_method_,_block_) \
{ \
[apiHelper _method_]; \
BOOL goon = YES; \
if (_block_) { \
goon = _block_(apiHelper,error); \
} \
GOON_CALLBACK(_method_) \
}
        
        void (^completeWrapper)() = ^{
            JUST_RETURN_APIHELPER_CALLBACK(afterRequestCompleted,completeBlock)
        };
        
        void (^successWrapper)(id) = ^(id responseEntry) {
            [apiHelper handleResponseEntry:responseEntry];
            apiHelper.state = MLAPIHelperStateRequestSucceed;
            
            //要先执行结束回调
            completeWrapper();
            
            JUST_RETURN_APIHELPER_CALLBACK(afterRequestSucceed,successBlock)
            
            //通知关心者
            [self postStateDidChangeNotificationForAPIHelper:apiHelper];
        };
        
        void (^requestSuccessWrapper)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject) {
            mlapi_dispatch_async_on_main_queue(^{
                apiHelper.responseObject = responseObject;
                
                NSError *error = [apiHelper errorOfResponseObject:responseObject];
                if (!error) {
                    //代表请求成功
                    id responseEntry = [apiHelper responseEntryOfResponseObject:responseObject];
                    //有缓存key，就做缓存
                    if (cacheKey) {
                        [self cacheResponseEntry:responseEntry forKey:cacheKey];
                    }
                    //执行业务成功wrapper
                    successWrapper(responseEntry);
                }else{
                    //代表请求失败
                    [apiHelper handleResponseError:error];
                    apiHelper.state = MLAPIHelperStateRequestFailed;
                    
                    //要先执行结束回调
                    completeWrapper();
                    
                    RETURN_APIHELPER_AND_ERROR_CALLBACK(afterRequestFailed,failureBlock)
                    
                    //通知关心者
                    [self postStateDidChangeNotificationForAPIHelper:apiHelper];
                }
            });
        };
        
        void (^errorWrapper)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
            mlapi_dispatch_async_on_main_queue(^{
                [apiHelper handleResponseError:error];
                apiHelper.state = MLAPIHelperStateRequestError;
                
                //要先执行结束回调
                completeWrapper();
                
                RETURN_APIHELPER_AND_ERROR_CALLBACK(afterRequestError,errorBlock)
                //通知关心者
                [self postStateDidChangeNotificationForAPIHelper:apiHelper];
            });
        };
        
        //重置请求
        [apiHelper reset];
        
        //标记当前的callbackObject
        apiHelper.callbackObject = callbackObject;
        
        //构造请求参数
        NSDictionary *params = [apiHelper allRequestParams];
        
        
        BOOL beforeCallbackCalled = NO;
        
        //缓存相关
        if (apiHelper.cacheType!=MLAPIHelperCacheTypeNone) {
            NSAssert(apiHelper.requestMethod==MLAPIHelperRequestMethodGET, @"非GET请求不支持缓存");
            if (apiHelper.requestMethod==MLAPIHelperRequestMethodGET) {
                JUST_RETURN_APIHELPER_CALLBACK(beforeRequest,beforeBlock)
                beforeCallbackCalled = YES;
                
                cacheKey = [self cacheKeyWithDomain:[apiHelper currentCacheDomainName] apiURL:[apiHelper apiURLWithParameters:params]];
                MLAPICacheItem *cacheItem = (MLAPICacheItem*)[_cache objectForKey:cacheKey];
                NSAssert(!cacheItem||[cacheItem isKindOfClass:[MLAPICacheItem class]], @"返回的缓存一定要是MLAPICacheItem才正常");
                if (cacheItem) {
                    BOOL preload = NO;
                    if (apiHelper.cacheType==MLAPIHelperCacheTypeReturnCacheThenAlwaysRequest) {
                        preload = YES;
                    }
                    if (!preload) {
                        //判断是否是要直接认作请求成功
                        if (![cacheItem isExpiredForLifeTime:[apiHelper cacheLifeTime]]) {
                            if (apiHelper.cacheType==MLAPIHelperCacheTypeReturnValidCacheElseRequest
                                ||apiHelper.cacheType==MLAPIHelperCacheTypeReturnCacheThenRequestIfCacheIsInvalid) {
                                apiHelper.isRespondWithCache = YES;
                                //直接返回成功即可，无需请求
                                successWrapper(cacheItem.responseEntry);
                                return;
                            }
                        }else if(apiHelper.cacheType==MLAPIHelperCacheTypeReturnCacheThenRequestIfCacheIsInvalid) {
                            preload = YES;
                        }
                    }
                    if (preload) {
                        [apiHelper handleResponseEntry:cacheItem.responseEntry];
                        apiHelper.hasPreloaded = YES;
                        apiHelper.state = MLAPIHelperStateCachePreloaded;
                        
                        JUST_RETURN_APIHELPER_CALLBACK(afterCachePreloaded,cachePreloadBlock)
                        
                        //通知关心者
                        [self postStateDidChangeNotificationForAPIHelper:apiHelper];
                    }
                }
            }
        }
        
        AFHTTPRequestSerializer <AFURLRequestSerialization> *requestSerializer = [apiHelper requestSerializer];
        //如果是上传api
        if ([apiHelper isUploadAPI]) {
            NSAssert(apiHelper.requestMethod==MLAPIHelperRequestMethodPOST, @"上传接口%@的请求方法必须得是MLAPIHelperRequestMethodPOST",apiHelper);
            
            NSDictionary *uploadParams = [apiHelper allUploadParams];
            NSAssert(uploadParams.count>0, @"上传接口%@没有有效上传内容",apiHelper);
            
            //执行上传行为
            if (!beforeCallbackCalled) {
                JUST_RETURN_APIHELPER_CALLBACK(beforeRequest,beforeBlock)
            }
            apiHelper.dataTask = [self.httpSessionManager POST:apiHelper.apiName baseURL:apiHelper.baseURL parameters:params requestSerializer:requestSerializer constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                for (NSString *key in [uploadParams allKeys]) {
                    MLAPIHelperUploadParam *p = uploadParams[key];
                    if ([p.data isKindOfClass:[NSData class]]) {
                        [formData appendPartWithFileData:p.data name:key fileName:key mimeType:p.mimeType];
                    }else if ([p.data isKindOfClass:[NSURL class]]) {
                        NSError *error = nil;
                        [formData appendPartWithFileURL:p.data name:key fileName:key mimeType:p.mimeType error:&error];
                        if (error) {
                            DDLogError(@"appendPartWithFileURL:name:fileName:mimeType:error:->%@",error);
                        }
                    }
                }
            } constructingRequestWithBlock:^(NSMutableURLRequest *request) {
                NSTimeInterval timeoutInterval = [apiHelper timeoutInterval];
                if (timeoutInterval<10.0f) {
                    DDLogWarn(@"上传接口%@的超时时间小于10秒",apiHelper);
                }
                
                if (timeoutInterval>0) {
                    [request setTimeoutInterval:timeoutInterval];
                }
                [apiHelper treatWithConstructedRequest:request requestParams:params uploadParams:uploadParams];
            } progress:uploadProgressWrapper success:requestSuccessWrapper failure:errorWrapper];
        }else{
            //执行标准的请求方式
            if (!beforeCallbackCalled) {
                JUST_RETURN_APIHELPER_CALLBACK(beforeRequest,beforeBlock)
            }
            apiHelper.dataTask = [self.httpSessionManager dataTaskWithHTTPMethod:MLAPI_HTTPMethod(apiHelper.requestMethod) URLString:apiHelper.apiName baseURL:apiHelper.baseURL parameters:params requestSerializer:requestSerializer constructingRequestWithBlock:^(NSMutableURLRequest *request) {
                    NSTimeInterval timeoutInterval = [apiHelper timeoutInterval];
                    if (timeoutInterval>0) {
                        [request setTimeoutInterval:timeoutInterval];
                    }
                [apiHelper treatWithConstructedRequest:request requestParams:params uploadParams:nil];
            } uploadProgress:uploadProgressWrapper downloadProgress:downloadProgressWrapper success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (apiHelper.requestMethod==MLAPIHelperRequestMethodHEAD) {
                    responseObject = nil;
                }
                requestSuccessWrapper(task,responseObject);
            } failure:errorWrapper];
            
            [apiHelper.dataTask resume];
        }
        
        //标记请求中
        apiHelper.state = MLAPIHelperStateRequesting;
        //通知关心者
        [self postStateDidChangeNotificationForAPIHelper:apiHelper];
    });
}

#pragma mark - Helper
- (void)postStateDidChangeNotificationForAPIHelper:(MLAPIHelper*)apiHelper {
    ASSERT_MUST_EXCUTE_ON_MAIN_THREAD
    
    //每一次投递行为的唯一标识
    static NSInteger postTag = 0;
    if (postTag==NSIntegerMax) {
        postTag = 0;
    }
    postTag++;
    
    NSDictionary *userInfo = @{
                               MLAPIHelperStateDidChangeNotificationPostTagKeyForUserInfo:@(postTag),
                               MLAPIHelperStateDidChangeNotificationAPIHelperKeyForUserInfo:apiHelper};
    
    //父类也要通知到，直到MLAPIHelper不需要通知了
    Class cls = [apiHelper class];
    Class untilCls = [MLAPIHelper class];
    while ([cls isSubclassOfClass:untilCls]&&cls!=untilCls) {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[NSString stringWithFormat:@"%@%@",MLAPIHelperStateDidChangeNotificationNamePrefix,NSStringFromClass(cls)] object:nil userInfo:userInfo];
        cls = [cls superclass];
    }
}

#pragma mark - Cache Helper
- (void)cacheResponseEntry:(id)responseEntry forKey:(NSString*)key {
    ASSERT_MUST_EXCUTE_ON_MAIN_THREAD
    
    if (responseEntry&&![responseEntry conformsToProtocol:@protocol(NSCoding)]) {
        DDLogError(@"想要缓存的数据%@必须实现了NSCoding协议才可以",responseEntry);
        return;
    }
    
    id cache = [[MLAPICacheItem alloc]initWithUnixTime:[[NSDate date]timeIntervalSince1970] responseEntry:responseEntry];
    [_cache setObject:cache forKey:key withBlock:nil];
}

- (NSString*)cacheKeyWithDomain:(NSString*)domain apiURL:(NSURL*)apiURL {
    ASSERT_MUST_EXCUTE_ON_MAIN_THREAD
    
    return [NSString stringWithFormat:@"%@%@",domain.length>0?[NSString stringWithFormat:@"[%@]",domain]:@"",[[apiURL absoluteString]md5String]];
}

- (MLAPICacheItem *)cacheForAPIHelper:(MLAPIHelper*)apiHelper {
    ASSERT_MUST_EXCUTE_ON_MAIN_THREAD
    
    NSAssert(apiHelper.requestMethod==MLAPIHelperRequestMethodGET, @"非GET请求不支持缓存");
    if (apiHelper.requestMethod!=MLAPIHelperRequestMethodGET) {
        return nil;
    }
    
    NSString *key = [self cacheKeyWithDomain:[apiHelper currentCacheDomainName] apiURL:[apiHelper apiURL]];
    id cache = [_cache objectForKey:key];
    NSAssert(!cache||[cache isKindOfClass:[MLAPICacheItem class]], @"获取的cache异常，非MLAPICacheItem:%@",cache);
    return [cache isKindOfClass:[MLAPICacheItem class]]?cache:nil;
}

@end
