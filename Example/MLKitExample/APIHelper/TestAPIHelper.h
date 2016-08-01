//
//  TestAPIHelper.h
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "BaseAPIHelper.h"
#import "Article.h"

@interface TestAPIHelper : UUIDAPIHelper

@property (nonatomic, copy) NSString *p_test;
@property (nonatomic, assign) NSInteger p_test2;
@property (nonatomic, strong) NSArray<Article *><Article> *r_rows;

@end
