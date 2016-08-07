//
//  BaseAPIHelper.h
//  MLKitExample
//
//  Created by molon on 16/7/25.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLAPIHelper.h"

FOUNDATION_EXPORT NSString * const MLAPICommonRequestFailedErrorDomain;
FOUNDATION_EXPORT NSInteger const MLAPICommonRequestFailedErrorCode;
FOUNDATION_EXPORT NSString * const MLAPICommonRequestFailedErrorDescription;

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