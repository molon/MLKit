//
//  Article.h
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Article
@end
@interface Article : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSTimeInterval createTime;

@end
