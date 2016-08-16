//
//  BaseTableViewCell.m
//  MLKitExample
//
//  Created by molon on 16/8/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)layoutSubviewsIfNoFrameRecord {
    //如果使用heightForRowUsingPureMLLayoutAtIndexPath:tableView:beforeLayout: 的话，此方法不会被执行的，在计算高度的时候已经根据layoutOfContentView自动得出布局结果了。
    [self.layoutOfContentView dirtyAllRelatedLayoutsAndLayoutViewsWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, kMLLayoutUndefined)];
    //    NSLog(@"\n\n%@\n\n",[self.layoutOfContentView debugDescriptionWithMode:MLLayoutDebugModeViewLayoutFrame|MLLayoutDebugModeSublayout]);
}

@end
