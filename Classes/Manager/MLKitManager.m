//
//  MLKitManager.m
//  MLKitExample
//
//  Created by molon on 16/7/13.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLKitManager.h"
#import "MLKitMacro.h"

@interface MLKitManager()

@property (nonatomic, strong) DDFileLogger *fileLogger;

@end

@implementation MLKitManager

+ (instancetype)defaultManager {
    static id _defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[[self class] alloc] init];
    });
    
    return _defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //default ddlog color
        setenv("XcodeColors", "YES", 0);
        
        DDTTYLogger *logger = [DDTTYLogger sharedInstance];
        if (!logger.colorsEnabled) {
            [logger setColorsEnabled:YES];
            [logger setForegroundColor:[UIColor colorWithRed:0.839 green:0.224 blue:0.118 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagError];
            [logger setForegroundColor:[UIColor colorWithRed:0.800 green:0.475 blue:0.125 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagWarning];
            [logger setForegroundColor:[UIColor colorWithRed:0.256 green:0.446 blue:1.000 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagInfo];
            [logger setForegroundColor:[UIColor blackColor] backgroundColor:nil forFlag:DDLogFlagDebug];
            [logger setForegroundColor:[UIColor grayColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
        }
    }
    return self;
}

- (void)setupWithDDLog:(BOOL)ddlog {
    if (ddlog) {
        [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
        [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
        
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        self.fileLogger = fileLogger;
        [DDLog addLogger:fileLogger];
        
        DDLogDebug(@"DDLog setup succeed, currentLogFileInfo: %@",fileLogger.currentLogFileInfo);
    }
}
@end
