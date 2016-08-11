//
//  BaseAPIHelper.m
//  MLKitExample
//
//  Created by molon on 16/7/25.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "BaseAPIHelper.h"

NSString * const MLAPICommonRequestFailedErrorDomain = @"com.molon.molonapi.MLAPICommonErrorDomainForRequestFailed";
NSInteger const MLAPICommonRequestFailedErrorCode = NSURLErrorUnknown;
NSString * const MLAPICommonRequestFailedErrorDescription = @"未知错误";

@interface MLAPIHelper(Private)

@property (nonatomic, assign) MLAPIHelperState state;

@end

@implementation BaseAPIHelper

- (nullable NSError*)errorOfResponseObject:(id)responseObject {
    if ([self.dataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = SUBCLASS(NSHTTPURLResponse, self.dataTask.response);
        if (response.statusCode == 200) {
            NSString *status = [responseObject stringValueForKey:@"status" default:@"fail"];
            if ([status isEqualToString:@"ok"]) {
                return nil;
            }
            
            NSDictionary *errorDictionary = responseObject[@"error"];
            if (!errorDictionary) {
                return [NSError errorWithDomain:MLAPICommonRequestFailedErrorDomain code:MLAPICommonRequestFailedErrorCode userInfo:@{NSLocalizedDescriptionKey:MLAPICommonRequestFailedErrorDescription}];
            }
            
            NSInteger code = [errorDictionary integerValueForKey:@"code" default:MLAPICommonRequestFailedErrorCode];
            NSString *description = [errorDictionary stringValueForKey:@"message" default:MLAPICommonRequestFailedErrorDescription];
            
            return [NSError errorWithDomain:MLAPICommonRequestFailedErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:description}];
        }
    }
    //其他的表示成功的statusCode(一般都是2打头的)的内容我们也没必要去关心，直接返回成功了即可
    //当然这个关心与否，根据自身业务情况决定，不是必须这样，这里只是给了个例子罢了
    return nil;
}

- (id)responseEntryOfResponseObject:(id)responseObject {
    if ([self.dataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = SUBCLASS(NSHTTPURLResponse, self.dataTask.response);
        if (response.statusCode == 200) {
            return responseObject[@"entry"];
        }
    }
    return nil;
}

- (NSString*)currentCacheDomainName {
    //如果登录之后应该返回用户唯一标识符
    return nil;
}

- (nullable NSURL*)configureBaseURL {
    return [NSURL URLWithString:@"http://192.168.100.5:8080"];
//    return [NSURL URLWithString:@"http://10.17.72.108:8080"];
//    return [NSURL URLWithString:@"http://localhost:8080"];
}

- (void)treatWithConstructedRequest:(NSMutableURLRequest *)mutableRequest {
    [super treatWithConstructedRequest:mutableRequest];
    
    //这个回调实际上不应该做这件事，但是只有这里适合做这件事。。。
    DDLogInfo(@"\n\n%@\n",[mutableRequest cURLCommandStringWithDumpHeader:NO jsonPP:YES]);
}

#ifdef DEBUG
- (void)setState:(MLAPIHelperState)state {
    [super setState:state];
    
    if (state==MLAPIHelperStateCachePreloaded) {
        DDLogInfo(@"预加载:%@",self);
    }else if (state==MLAPIHelperStateRequesting) {
        
    }else if (state==MLAPIHelperStateRequestSucceed) {
        if (self.isRespondWithCache) {
            DDLogInfo(@"直接使用缓存:%@",self);
        }
    }
}
#endif

@end

@implementation UUIDAPIHelper
- (instancetype)init
{
    self = [super init];
    if (self) {
        _p_uuid = [UIDevice currentDevice].UUID;
    }
    return self;
}
@end

@implementation LazyLoadAPIHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _p_pageSize = 20;
    }
    return self;
}

- (MLAPIHelperRequestMethod)configureRequestMethod {
    return MLAPIHelperRequestMethodGET;
}

@end