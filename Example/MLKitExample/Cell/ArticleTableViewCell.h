//
//  ArticleTableViewCell.h
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "BaseTableViewCell.h"

@class Article;

@interface ArticleTableViewCell : BaseTableViewCell

@property (nonatomic, strong) Article *article;

@end
