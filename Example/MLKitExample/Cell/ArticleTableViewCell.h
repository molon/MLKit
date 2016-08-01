//
//  ArticleTableViewCell.h
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <MLAutoRecordFrameTableViewCell.h>

@class Article;

@interface ArticleTableViewCell : MLAutoRecordFrameTableViewCell

@property (nonatomic, strong) Article *article;

@end
