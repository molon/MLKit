//
//  NSFileManager+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/16.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NSFileManager+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(NSFileManager_MLAdd)

@implementation NSFileManager (MLAdd)

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path {
    NSURL *URL = [NSURL fileURLWithPath:path];
    
    NSAssert([self fileExistsAtPath:[URL path]], @"path must be a exist file path string(addSkipBackupAttributeToItemAtPath:)");
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@(YES)
                                  forKey:NSURLIsExcludedFromBackupKey error:&error];
    if(!success){
        DDLogError(@"Error excluding %@ from backup %@",[URL lastPathComponent],error);
    }
    return success;
}

@end
