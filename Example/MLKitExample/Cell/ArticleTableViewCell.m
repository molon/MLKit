//
//  ArticleTableViewCell.m
//  MLKitExample
//
//  Created by molon on 16/8/1.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "ArticleTableViewCell.h"
#import "Article.h"

@interface ArticleTableViewCell()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ArticleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        __block NSInteger tag = 1000;
        self.contentView.tag = tag++;
        
#define kFontSize 14.0f
        _timeLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 1;
            label.font = [UIFont boldSystemFontOfSize:kFontSize];
            label.textColor = [UIColor grayColor];
            label.tag = tag++;
            [self.contentView addSubview:label];
            label;
        });
        
        _titleLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 1;
            label.font = [UIFont boldSystemFontOfSize:kFontSize];
            label.textColor = [UIColor darkTextColor];
            label.tag = tag++;
            [self.contentView addSubview:label];
            label;
        });
        
        self.layoutOfContentView = [MLLayout layoutWithTagView:self.contentView block:^(MLLayout * _Nonnull l) {
            l.flexDirection = MLLayoutFlexDirectionColumn;
            l.alignItems = MLLayoutAlignmentFlexStart;
            l.padding = UIEdgeInsetsMake(8, 8, 8, 8);
            l.sublayouts = @[
                             [MLLayout layoutWithTagView:_timeLabel block:nil],
                             [MLLayout layoutWithTagView:_titleLabel block:^(MLLayout * _Nonnull l) {
                                 l.marginTop = 8.0f;
                             }],
                             ];
        }];
    }
    return self;
}

- (void)layoutSubviewsIfNoFrameRecord {
    [self.layoutOfContentView dirtyAllRelatedLayoutsAndLayoutViewsWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, kMLLayoutUndefined)];
    //    NSLog(@"\n\n%@\n\n",[self.layoutOfContentView debugDescriptionWithMode:MLLayoutDebugModeViewLayoutFrame|MLLayoutDebugModeSublayout]);
}

- (void)setArticle:(Article *)article {
    _article = article;
    
    _timeLabel.text = [[NSDate dateWithTimeIntervalSince1970:article.createTime]stringWithGeneralTimeFormat];
    _titleLabel.text = article.name;
    
    [self setNeedsLayout];
}

@end
