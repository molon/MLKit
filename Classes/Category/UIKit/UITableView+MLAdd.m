//
//  UITableView+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UITableView+MLAdd.h"
#import "MLKitMacro.h"
#import "UITableView+DHSmartScreenshot.h"
#import "UIImage+MLAdd.h"

SYNTH_DUMMY_CLASS(UITableView_MLAdd)

@interface UITableView()

- (UIImage *)screenshotOfHeaderView;
- (UIImage *)screenshotOfHeaderViewAtSection:(NSUInteger)section excludedHeaderSections:(NSSet *)excludedHeaderSections;
- (UIImage *)screenshotOfCellAtIndexPath:(NSIndexPath *)indexPath excludedIndexPaths:(NSSet *)excludedIndexPaths;
- (UIImage *)screenshotOfFooterViewAtSection:(NSUInteger)section excludedFooterSections:(NSSet *)excludedFooterSections;
- (UIImage *)screenshotOfFooterView;

@end

@implementation UITableView (MLAdd)

- (void)updateWithBlock:(void (^)(UITableView *tableView))block {
    [self beginUpdates];
    block(self);
    [self endUpdates];
}


- (UIImage *)screenshotExcludingHeaderView:(BOOL)excludingHeaderView
                       excludingFooterView:(BOOL)excludingFooterView
{
    return [self screenshotExcludingHeadersAtSections:nil excludingFootersAtSections:nil excludingRowsAtIndexPaths:nil excludingHeaderView:excludingHeaderView excludingFooterView:excludingFooterView];
}

- (UIImage *)screenshotExcludingHeadersAtSections:(NSSet *)excludedHeaderSections
                       excludingFootersAtSections:(NSSet *)excludedFooterSections
                        excludingRowsAtIndexPaths:(NSSet *)excludedIndexPaths
                              excludingHeaderView:(BOOL)excludingHeaderView
                              excludingFooterView:(BOOL)excludingFooterView
{
    NSMutableArray *screenshots = [NSMutableArray array];
    // Header Screenshot
    UIImage *headerScreenshot = excludingHeaderView?nil:[self screenshotOfHeaderView];
    if (headerScreenshot) [screenshots addObject:headerScreenshot];
    for (int section=0; section<self.numberOfSections; section++) {
        // Header Screenshot
        UIImage *headerScreenshot = [self screenshotOfHeaderViewAtSection:section excludedHeaderSections:excludedHeaderSections];
        if (headerScreenshot) [screenshots addObject:headerScreenshot];
        
        // Screenshot of every cell in the  section
        for (int row=0; row<[self numberOfRowsInSection:section]; row++) {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UIImage *cellScreenshot = [self screenshotOfCellAtIndexPath:cellIndexPath excludedIndexPaths:excludedIndexPaths];
            if (cellScreenshot) [screenshots addObject:cellScreenshot];
        }
        
        // Footer Screenshot
        UIImage *footerScreenshot = [self screenshotOfFooterViewAtSection:section excludedFooterSections:excludedFooterSections];
        if (footerScreenshot) [screenshots addObject:footerScreenshot];
    }
    UIImage *footerScreenshot = excludingFooterView?nil:[self screenshotOfFooterView];
    if (footerScreenshot) [screenshots addObject:footerScreenshot];
    return [UIImage verticalImageWithImages:screenshots];
}

@end
