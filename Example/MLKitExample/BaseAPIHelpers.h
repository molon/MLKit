//
//  BaseAPIHelpers.h
//  MLKitExample
//
//  Created by molon on 16/7/25.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAPIHelper.h"

//业务接口的错误domain
FOUNDATION_EXPORT NSString * const MLAPICommonRequestFailedErrorDomain;

//业务接口的未知错误code
FOUNDATION_EXPORT NSInteger const MLAPICommonRequestFailedUnknownErrorCode;

//业务接口的未知错误描述
FOUNDATION_EXPORT NSString * const MLAPICommonRequestFailedUnknownErrorDescription;


@interface BaseAPIHelper : MLAPIHelper

@end

@interface UUIDAPIHelper : BaseAPIHelper

@property (nonatomic, copy) NSString *p_uuid;

@end

@interface LazyLoadAPIHelper : BaseAPIHelper

@property (nonatomic, assign) NSInteger p_pageNo;
@property (nonatomic, assign) NSInteger p_pageSize;

@property (nonatomic, strong) NSArray *r_rows;

@end