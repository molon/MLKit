//
//  ExampleUserDefaults.h
//  MLKitExample
//
//  Created by molon on 16/8/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <MLUserDefaults.h>
#import "Article.h"

@interface ExampleUserDefaults : MLUserDefaults

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) Article *article;
@property (nonatomic, strong) NSArray<Article *><Article> *articles;

@end
