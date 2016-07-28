//
//  BaseAPIHelper.m
//  MLKitExample
//
//  Created by molon on 16/7/25.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "BaseAPIHelper.h"
#import "MLKit.h"

NSString * const MLAPICommonErrorDomainForRequestFailed = @"com.molon.molonapi.MLAPICommonErrorDomainForRequestFailed";
NSInteger const MLAPICommonErrorCodeForRequestFailed = -1;
NSString * const MLAPICommonErrorDescriptionForRequestFailed = @"未知错误";

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
                return [NSError errorWithDomain:MLAPICommonErrorDomainForRequestFailed code:MLAPICommonErrorCodeForRequestFailed userInfo:@{NSLocalizedDescriptionKey:MLAPICommonErrorDescriptionForRequestFailed}];
            }
            NSInteger code = [errorDictionary integerValueForKey:@"code" default:MLAPICommonErrorCodeForRequestFailed];
            NSString *description = [errorDictionary stringValueForKey:@"message" default:MLAPICommonErrorDescriptionForRequestFailed];
            
            return [NSError errorWithDomain:MLAPICommonErrorDomainForRequestFailed code:code userInfo:@{NSLocalizedDescriptionKey:description}];
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
    return nil;
}

- (nullable NSURL*)configureBaseURL {
    return [NSURL URLWithString:@"http://localhost:8080"];
}

#ifdef DEBUG
- (void)setState:(MLAPIHelperState)state {
    [super setState:state];
    
    if (state==MLAPIHelperStateCachePreloaded) {
        DDLogInfo(@"预加载:%@",self);
    }else if (state==MLAPIHelperStateRequesting) {
        
        NSURLRequest *request = self.dataTask.currentRequest;
        
        NSString *params = [[NSString alloc]initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        
        DDLogInfo(@"\n开始请求: curl -X %@ %@%@ | json_pp",request.HTTPMethod,params.length>0?[NSString stringWithFormat:@"-d \"%@\" ",params]:@"",request.URL);

    }else if (state==MLAPIHelperStateRequestSucceed) {
        if (self.isRespondWithCache) {
            DDLogInfo(@"直接使用缓存:%@",self);
        }
    }
}
#endif

@end
