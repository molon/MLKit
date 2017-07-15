//
//  MLAPIHelper.m
//  MLKitExample
//
//  Created by molon on 16/7/14.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAPIHelper.h"
#import <MLPersonalModel/YYModel.h>
#import "NSString+MLAdd.h"
#import "MLKitMacro.h"
#import "MLAPIManager.h"
#import "MLAPICacheItem.h"
#import "NSObject+MLAdd.h"

NSTimeInterval const MLAPIHelperDefaultTimeoutInterval = 5.0f;

NSInteger const MLAPIHelperCommonPrefixLength = 2;
NSString * const MLAPIHelperParamPrefix = @"p_";
NSString * const MLAPIHelperResponsePrefix = @"r_";

NSString * const MLAPIHelperResponseModelArrayKey = @"responseModels";
NSString * const MLAPIHelperResponseModelKey = @"responseModel";

NSString * const MLAPIHelperRequestModelKey = @"requestModel";

static inline NSDictionary *kResetResponseProtypeDictionary(Class cls) {
    static NSMutableDictionary *protypeResponses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protypeResponses = [NSMutableDictionary dictionary];
    });
    
    NSString *clsName = NSStringFromClass(cls);
    if (!protypeResponses[clsName]) {
        NSDictionary<NSString *, YYClassPropertyInfo *> *propertyInfos = [cls yy_propertyInfosUntilClass:[MLAPIHelper class] ignoreUntilClass:YES];
        
        NSMutableDictionary *protypeResponse = [NSMutableDictionary dictionary];
        //先保证所有代表返回结果的属性值全部会被重置
        if (propertyInfos[MLAPIHelperResponseModelArrayKey]) {
            YYClassPropertyInfo *info = propertyInfos[MLAPIHelperResponseModelArrayKey];
            if (![info.cls isSubclassOfClass:[NSArray class]]||!info.pseudoGenericCls) {
                NSCAssert(@"接口类%@的%@属性必须是实现了有效伪泛型的NSArray类型",clsName,MLAPIHelperResponseModelArrayKey);
            }else{
                protypeResponse[MLAPIHelperResponseModelArrayKey] = (id)kCFNull;
            }
        }
        if (propertyInfos[MLAPIHelperResponseModelKey]) {
            protypeResponse[MLAPIHelperResponseModelKey] = (id)kCFNull;
        }
        for (NSString *key in [propertyInfos allKeys]) {
            if ([key hasPrefix:MLAPIHelperResponsePrefix]) {
                protypeResponse[key] = (id)kCFNull;
            }
        }
        protypeResponses[clsName] = protypeResponse;
    }
    return protypeResponses[clsName];
}

NSString * MLAPI_HTTPMethod(MLAPIHelperRequestMethod requestMethod) {
    static NSArray *methodNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        methodNames = @[@"GET",@"POST",@"PUT",@"DELETE",@"HEAD",@"PATCH"];
    });
    return methodNames[requestMethod];
}

BOOL MLAPI_IsErrorCancelled(NSError *error) {
    return ([error.domain isEqualToString:NSURLErrorDomain]
            &&error.code==NSURLErrorCancelled);
}

@interface MLAPIHelperUploadParam()

@property (nonatomic, copy) NSString *key; //参数名字
@property (nonatomic, strong) id data; //可NSData，可fileURL
@property (nonatomic, copy) NSString *mimeType;

@end

@implementation MLAPIHelperUploadParam

+ (instancetype)uploadParamWithKey:(NSString*)key data:(id)data mimeType:(NSString*)mimeType {
    MLAPIHelperUploadParam *p = [[self class]new];
    p.key = key;
    p.data = data;
    p.mimeType = mimeType;
    return p;
}

- (void)setData:(id)data {
    _data = data;
    
    NSAssert(!data||[data isKindOfClass:[NSData class]]||([data isKindOfClass:[NSURL class]]&&[(NSURL*)data isFileURL]), @"(MLAPIHelperUploadParam)setData: data必须是NSData或者fileURL才有效");
}

- (BOOL)isValid {
    if ([_data isKindOfClass:[NSData class]]&&((NSData*)_data).length>0) {
        return YES;
    }
    
    if ([_data isKindOfClass:[NSURL class]]) {
        NSURL *file = (NSURL*)_data;
        if ([file isFileURL]) {
            BOOL isDirectory = NO;
            if ([[NSFileManager defaultManager]fileExistsAtPath:[file path] isDirectory:&isDirectory]&&!isDirectory) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSString *)description {
    if (![self isValid]) {
        return [NSString stringWithFormat:@"key->%@,file->无效,mimeType->%@",_key,_mimeType];
    }
    
    if ([_data isKindOfClass:[NSData class]]) {
        return [NSString stringWithFormat:@"key->%@,file->%d字节Data,mimeType->%@",_key,((NSData*)_data).length,_mimeType];
    }
    
    if ([_data isKindOfClass:[NSURL class]]) {
        return [NSString stringWithFormat:@"key->%@,file->%@,mimeType->%@",_key,([(NSURL*)_data path]).length,_mimeType];
    }
    return @"异常MLAPIHelperUploadParam";
}

@end

@interface MLAPIHelper()

@property (nonatomic, copy) NSString *apiName;
@property (nonatomic, assign) MLAPIHelperRequestMethod requestMethod;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSNumber *nilNumber;

@property (nonatomic, assign) MLAPIHelperState state;
@property (nonatomic, strong) id responseEntry;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError *responseError;
@property (nonatomic, assign) BOOL isRespondWithCache;
@property (nonatomic, assign) BOOL hasPreloaded;
@property (nonatomic, weak) id callbackObject;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation MLAPIHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        [self yy_resetAllPropertyValues];
        
        NSURL *baseURL = [self configureBaseURL];
        // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
        if ([[baseURL path] length] > 0 && ![[baseURL absoluteString] hasSuffix:@"/"]) {
            baseURL = [baseURL URLByAppendingPathComponent:@""];
        }
        _baseURL = baseURL;
        NSAssert(_baseURL, @"接口%@的baseURL无效",NSStringFromClass([self class]));
        
        _apiName = [[self configureAPIName]copy];
        NSAssert([_apiName isNotBlank], @"接口%@的apiName不可为空",NSStringFromClass([self class]));
        
        _requestMethod = [self configureRequestMethod];
        
        _nilNumber = [self configureNilNumber];
        NSAssert(_nilNumber, @"必须设置一个nilNumber");
        
        //if subclass override setState: , the setting is useful.
        self.state = MLAPIHelperStateInit;
    }
    return self;
}

#pragma mark - setter
- (void)setCacheType:(MLAPIHelperCacheType)cacheType {
    _cacheType = cacheType;
    
    NSAssert(cacheType==MLAPIHelperCacheTypeNone||(cacheType!=MLAPIHelperCacheTypeNone&&_requestMethod==MLAPIHelperRequestMethodGET), @"只有GET请求才支持缓存");
}

#pragma mark - outcall
- (BOOL)isRequestCompleted {
    return _state == MLAPIHelperStateRequestSucceed||_state==MLAPIHelperStateRequestFailed||_state == MLAPIHelperStateRequestError;
}

- (NSDictionary*)allRequestParams {
    [self beforeConstructRequestParams];
    NSMutableDictionary *params = [self constructRequestParams];
    [self treatWithConstructedRequestParams:params];
    return params;
}

- (NSURL *)apiURL {
    return [self apiURLWithParameters:[self allRequestParams]];
}

- (NSURL*)apiURLWithParameters:(NSDictionary*)parameters {
    NSURL *apiURL = [NSURL URLWithString:_apiName relativeToURL:_baseURL];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializer]?:([MLAPIManager defaultManager].httpSessionManager.requestSerializer);
    if ([requestSerializer.HTTPMethodsEncodingParametersInURI containsObject:MLAPI_HTTPMethod(_requestMethod)]) {
        NSString *query = AFQueryStringFromParameters(parameters);
        if (query && query.length > 0) {
            apiURL = [NSURL URLWithString:[[apiURL absoluteString] stringByAppendingFormat:apiURL.query ? @"&%@" : @"?%@", query]];
        }
    }
    return apiURL;
}

- (MLAPICacheItem*)cache {
    return [[MLAPIManager defaultManager]cacheForAPIHelper:self];
}

- (void)cancel {
    if (_state==MLAPIHelperStateRequesting&&_dataTask) {
        [_dataTask cancel];
    }
}

#pragma mark - helper
- (NSMutableDictionary*)constructRequestParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if ([[self class]yy_containsPropertyKey:MLAPIHelperRequestModelKey untilClass:[MLAPIHelper class] ignoreUntilClass:YES]) {
        id requestModel = [self valueForKey:MLAPIHelperRequestModelKey];
        if (requestModel) {
            id requestModelDict = [requestModel yy_modelToJSONObjectOrRootSelf:NO];
            NSAssert([requestModelDict isKindOfClass:[NSDictionary class]], @"%@只支持可转换为NSDictionary的对象",MLAPIHelperRequestModelKey);
            if ([requestModelDict isKindOfClass:[NSDictionary class]]) {
                [params addEntriesFromDictionary:requestModelDict];
            }
        }
    }
    
    NSDictionary *paramKeyMapper = [[self class]customRequestParamKeyMapper];
    if (paramKeyMapper.count<=0) {
        paramKeyMapper = nil;
    }
    
    //找到p_开头的属性，如果其不为空，则认作是有效参数传过去
    NSDictionary<NSString *, YYClassPropertyInfo *> *propertyInfos = [[self class] yy_propertyInfosUntilClass:[MLAPIHelper class] ignoreUntilClass:YES];
    for (NSString *key in [propertyInfos allKeys]) {
        if (![key hasPrefix:MLAPIHelperParamPrefix]&&!paramKeyMapper[key]) {
            continue;
        }
        
        id object = [self valueForKey:key];
        if (object && object!= (id)kCFNull) {
            if ([object isKindOfClass:[NSNumber class]]&&
                ([object isEqualToNumber:_nilNumber]||[object isEqualToNumber:[NSDecimalNumber notANumber]])) {
                continue;
            }
            
            //如果是空字符串也直接忽略
            if ([object isKindOfClass:[NSString class]]&&![object isNotBlank]) {
                continue;
            }
            
            NSString *paramKey = nil;
            if (paramKeyMapper[key]) {
                paramKey = paramKeyMapper[key];
            }else{
                //去除前缀的名称
                paramKey = [key substringFromIndex:MLAPIHelperCommonPrefixLength];
            }
            if ([object isKindOfClass:[NSURL class]]) {
                NSAssert(![object isFileURL], @"作为参数的属性值不可谓 FileURL");
                params[paramKey] = [object absoluteString];
            }else{
                params[paramKey] = [object yy_modelToJSONObjectOrRootSelf:YES];
            }
        }
    }
    
    return params;
}


- (NSString*)description {
    NSDictionary *params = [self allRequestParams];
    if (params.count<=0) {
        return [NSString stringWithFormat:@"\n%@ -> \n%@:%@\n",[super description],MLAPI_HTTPMethod(_requestMethod),[[self apiURL] absoluteString]];
    }
    
    return [NSString stringWithFormat:@"\n%@ -> \n%@:%@\nParams:%@\n",[super description],MLAPI_HTTPMethod(_requestMethod),[[self apiURL] absoluteString],params];
}

- (void)reset {
    [self cancel];
    
    _hasPreloaded = NO;
    _isRespondWithCache = NO;
    _responseObject = nil;
    _responseEntry = nil;
    _responseError = nil;
    _dataTask = nil;
    _callbackObject = nil;
    
    //重置response相关的属性
    NSMutableDictionary *response = [kResetResponseProtypeDictionary([self class]) mutableCopy];
    [self yy_modelSetWithJSON:response];
    
    self.state = MLAPIHelperStateInit;
}

#pragma mark - must override
- (NSString*)configureAPIName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (MLAPIHelperRequestMethod)configureRequestMethod {
    return MLAPIHelperRequestMethodGET;
}

- (NSNumber *)configureNilNumber {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - must implement
- (nullable NSError*)errorOfResponseObject:(id)responseObject {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)responseEntryOfResponseObject:(id)responseObject {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString*)currentCacheDomainName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSURL*)configureBaseURL {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber *)nilNumberParam {
    [self doesNotRecognizeSelector:_cmd];
    return [NSDecimalNumber notANumber];
}

#pragma mark - override optionally
- (NSTimeInterval)timeoutInterval {
    return MLAPIHelperDefaultTimeoutInterval;
}

- (NSTimeInterval)cacheLifeTime {
    return -1.0f;
}

- (AFHTTPRequestSerializer *)requestSerializer {
    return nil;
}

- (void)beforeConstructRequestParams{}
- (void)treatWithConstructedRequestParams:(NSMutableDictionary*)params{}
- (void)treatWithConstructedRequest:(NSMutableURLRequest*)mutableRequest{}
- (void)beforeRequest{}
- (void)afterCachePreloaded{}
- (void)uploadProgress:(NSProgress *)progress{}
- (void)downloadProgress:(NSProgress *)progress{}
- (void)afterRequestCompleted{}
- (void)afterRequestSucceed{}
- (void)afterRequestFailed{}
- (void)afterRequestError{}

- (void)handleResponseError:(NSError*)responseError {
    _responseError = responseError;
}

- (void)handleResponseEntry:(id)responseEntry {
    _responseEntry = responseEntry;
    
    NSMutableDictionary *response = [kResetResponseProtypeDictionary([self class]) mutableCopy];
    
    //检测是否顶层就是数组
    if ([responseEntry isKindOfClass:[NSArray class]]) {
        //这种情况下，接口类就必须要存在名称为MLAPIHelperResponseModelArrayKey的属性，否则转不了
        if (response[MLAPIHelperResponseModelArrayKey]) {
            response[MLAPIHelperResponseModelArrayKey] = responseEntry;
        }else{
            DDLogError(@"接口类%@必须包含名称为%@且实现了有效伪泛型的NSArray属性才可以对接口返回数据进行处理",NSStringFromClass([self class]),MLAPIHelperResponseModelArrayKey);
            NSAssert(@"接口类%@必须包含名称为%@且实现了有效伪泛型的NSArray属性才可以对接口返回数据进行处理",NSStringFromClass([self class]),MLAPIHelperResponseModelArrayKey);
        }
    }else if ([responseEntry isKindOfClass:[NSDictionary class]]) {
        if (response[MLAPIHelperResponseModelKey]) {
            //有MLAPIHelperResponseModelKey名称的属性，就认作根级就是一个model，直接转了
            response[MLAPIHelperResponseModelKey] = responseEntry;
        }else{
            //则是r_开头的需要关心下，其他不用管
            for (NSString *key in [response allKeys]) {
                if ([key hasPrefix:MLAPIHelperResponsePrefix]) {
                    NSString *responseKey = [key substringFromIndex:MLAPIHelperCommonPrefixLength];
                    if (responseEntry[responseKey]) {
                        response[key] = responseEntry[responseKey];
                    }
                }
            }
        }
    }
    
    [self yy_modelSetWithJSON:response];
}

+ (NSDictionary *)modelCustomPropertyDefaultValueMapper {
    return @{};
}

+ (NSDictionary *)customRequestParamKeyMapper {
    return @{};
}

#pragma mark - 请求方法
- (void)requestWithBefore:(nullable BOOL (^)(MLAPIHelper *apiHelper))beforeBlock
           uploadProgress:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSProgress *uploadProgress))uploadProgressBlock
         downloadProgress:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSProgress *downloadProgress))downloadProgressBlock
             cachePreload:(nullable BOOL (^)(MLAPIHelper *apiHelper))cachePreloadBlock
                 complete:(nullable BOOL (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable BOOL (^)(MLAPIHelper *apiHelper))successBlock
                  failure:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                    error:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock
           callbackObject:(nullable id)callbackObject {
    [[MLAPIManager defaultManager]requestWithAPIHelper:self before:beforeBlock uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock cachePreload:cachePreloadBlock complete:completeBlock success:successBlock failure:failureBlock error:errorBlock callbackObject:callbackObject];
}

- (void)requestWithBefore:(nullable BOOL (^)(MLAPIHelper *apiHelper))beforeBlock
                 complete:(nullable BOOL (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable BOOL (^)(MLAPIHelper *apiHelper))successBlock
                  failure:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                    error:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock
           callbackObject:(nullable id)callbackObject {
    [self requestWithBefore:beforeBlock uploadProgress:nil downloadProgress:nil cachePreload:nil complete:completeBlock success:successBlock failure:failureBlock error:errorBlock callbackObject:callbackObject];
}

- (void)requestWithBefore:(nullable BOOL (^)(MLAPIHelper *apiHelper))beforeBlock
                 complete:(nullable BOOL (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable BOOL (^)(MLAPIHelper *apiHelper))successBlock
           failureOrError:(nullable BOOL (^)(MLAPIHelper *apiHelper, NSError *error))failureOrErrorBlock
           callbackObject:(nullable id)callbackObject {
    [self requestWithBefore:beforeBlock uploadProgress:nil downloadProgress:nil cachePreload:nil complete:completeBlock success:successBlock failure:failureOrErrorBlock error:failureOrErrorBlock callbackObject:callbackObject];
}

- (void)requestWithBefore:(nullable void (^)(MLAPIHelper * apiHelper))beforeBlock
           uploadProgress:(nullable void (^)(MLAPIHelper *apiHelper, NSProgress *uploadProgress))uploadProgressBlock
         downloadProgress:(nullable void (^)(MLAPIHelper *apiHelper, NSProgress *downloadProgress))downloadProgressBlock
             cachePreload:(nullable void (^)(MLAPIHelper *apiHelper))cachePreloadBlock
                 complete:(nullable void (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable void (^)(MLAPIHelper *apiHelper))successBlock
                  failure:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                    error:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock {
    [self requestWithBefore:^BOOL(MLAPIHelper * _Nonnull apiHelper) {
        if (beforeBlock) {
            beforeBlock(apiHelper);
        }
        return NO;
    } uploadProgress:^BOOL(MLAPIHelper * _Nonnull apiHelper, NSProgress * _Nonnull uploadProgress) {
        if (uploadProgressBlock) {
            uploadProgressBlock(apiHelper,uploadProgress);
        }
        return NO;
    } downloadProgress:^BOOL(MLAPIHelper * _Nonnull apiHelper, NSProgress * _Nonnull downloadProgress) {
        if (downloadProgressBlock) {
            downloadProgressBlock(apiHelper,downloadProgress);
        }
        return NO;
    } cachePreload:^BOOL(MLAPIHelper * _Nonnull apiHelper) {
        if (cachePreloadBlock) {
            cachePreloadBlock(apiHelper);
        }
        return NO;
    } complete:^BOOL(MLAPIHelper * _Nonnull apiHelper) {
        if (completeBlock) {
            completeBlock(apiHelper);
        }
        return NO;
    } success:^BOOL(MLAPIHelper * _Nonnull apiHelper) {
        if (successBlock) {
            successBlock(apiHelper);
        }
        return NO;
    } failure:^BOOL(MLAPIHelper * _Nonnull apiHelper, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(apiHelper,error);
        }
        return NO;
    } error:^BOOL(MLAPIHelper * _Nonnull apiHelper, NSError * _Nonnull error) {
        if (errorBlock) {
            errorBlock(apiHelper,error);
        }
        return NO;
    } callbackObject:nil];
}

- (void)requestWithBefore:(nullable void (^)(MLAPIHelper *apiHelper))beforeBlock
                 complete:(nullable void (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable void (^)(MLAPIHelper *apiHelper))successBlock
                  failure:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))failureBlock
                    error:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))errorBlock {
    [self requestWithBefore:beforeBlock uploadProgress:nil downloadProgress:nil cachePreload:nil complete:completeBlock success:successBlock failure:failureBlock error:errorBlock];
}

- (void)requestWithBefore:(nullable void (^)(MLAPIHelper *apiHelper))beforeBlock
                 complete:(nullable void (^)(MLAPIHelper *apiHelper))completeBlock
                  success:(nullable void (^)(MLAPIHelper *apiHelper))successBlock
           failureOrError:(nullable void (^)(MLAPIHelper *apiHelper, NSError *error))failureOrErrorBlock {
    [self requestWithBefore:beforeBlock complete:completeBlock success:successBlock failure:failureOrErrorBlock error:failureOrErrorBlock];
}

- (void)requestWithCallbackObject:(nullable id)callbackObject {
    [self requestWithBefore:nil uploadProgress:nil downloadProgress:nil cachePreload:nil complete:nil success:nil failure:nil error:nil callbackObject:callbackObject];
}

@end
