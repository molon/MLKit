//
//  UIApplication+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^UIApplicationCheckVersionPullCallBackBlock)(BOOL succeed,NSString *_Nullable version,NSDate *_Nullable releaseDate, NSString *_Nullable releaseNotes,NSURL *_Nullable updateURL);

/**
 Provides extensions for `UIApplication`.
 */
@interface UIApplication (MLAdd)

/// "Documents" folder in this app's sandbox.
@property (nonatomic, readonly) NSURL *documentsURL;
@property (nonatomic, readonly) NSString *documentsPath;

/// "Caches" folder in this app's sandbox.
@property (nonatomic, readonly) NSURL *cachesURL;
@property (nonatomic, readonly) NSString *cachesPath;

/// "Library" folder in this app's sandbox.
@property (nonatomic, readonly) NSURL *libraryURL;
@property (nonatomic, readonly) NSString *libraryPath;

/// Application's Bundle Display Name (Like "天上人间").
@property (nullable, nonatomic, readonly) NSString *appDisplayName;

/// Application's Bundle Name (show in SpringBoard).
@property (nullable, nonatomic, readonly) NSString *appBundleName;

/// Application's Bundle ID.  e.g. "com.ibireme.MyApp"
@property (nullable, nonatomic, readonly) NSString *appBundleID;

/// Application's Version.  e.g. "1.2.0"
@property (nullable, nonatomic, readonly) NSString *appVersion;

/// Application's Build number. e.g. "123"
@property (nullable, nonatomic, readonly) NSString *appBuildNumber;

/// Application's Default Status Bar Style configured
@property (nonatomic, readonly) UIStatusBarStyle appDefaultStatusBarStyle;

/// Whether this app is pirated (not install from appstore).
@property (nonatomic, readonly) BOOL isPirated;

/// Whether this app is being debugged (debugger attached).
@property (nonatomic, readonly) BOOL isBeingDebugged;

/// Current thread real memory used in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t memoryUsage;

/// Current thread CPU usage, 1.0 means 100%. (-1 when error occurs)
@property (nonatomic, readonly) float cpuUsage;

/**
 Increments the number of active network requests.
 If this number was zero before incrementing, this will start animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
- (void)incrementNetworkActivityCount;

/**
 Decrements the number of active network requests.
 If this number becomes zero after decrementing, this will stop animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
- (void)decrementNetworkActivityCount;

/// Returns YES in App Extension.
+ (BOOL)isAppExtension;

/*!
 Check new version
 
 @param bundleID        bundleID
 @param promptInterval  promptInterval //这个玩意只有mustUpdate返回FALSE时候有效
 @param pullBlock       pullBlock //拉取新版本信息，在拉去了需要更新版本信息后会缓存下来，不会去重复拉取。
 @param mustUpdateBlock mustUpdateBlock //根据version和releaseDate来返回是否需要强制更新，可以实现新版本上线后N久内非强制，然后再强制这种需求等等
 @param promptBlock     promptBlock //外部需要做下UI弹窗逻辑
 */
+ (void)checkNewVersionWithBundleID:(nullable NSString*)bundleID promptInterval:(NSTimeInterval)promptInterval pullBlock:(void (^)(NSString *bundleID, UIApplicationCheckVersionPullCallBackBlock callback))pullBlock mustUpdateBlock:(BOOL(^)(NSString *version,NSDate *releaseDate))mustUpdateBlock promptBlock:(void(^)(BOOL mustUpdate,NSString *version,NSDate *releaseDate,NSString *releaseNotes,NSURL *updateURL))promptBlock;

@end

NS_ASSUME_NONNULL_END

#ifndef kAppDelegate
#define kAppDelegate ([UIApplication sharedApplication].delegate)
#endif

#ifndef kAppDisplayName
#define kAppDisplayName ([UIApplication sharedApplication].appDisplayName)
#endif

#ifndef kAppBundleName
#define kAppBundleName ([UIApplication sharedApplication].appBundleName)
#endif

#ifndef kAppBundleID
#define kAppBundleID ([UIApplication sharedApplication].appBundleID)
#endif

#ifndef kAppVersion
#define kAppVersion ([UIApplication sharedApplication].appVersion)
#endif

#ifndef kAppBuildNumber
#define kAppBuildNumber ([UIApplication sharedApplication].appBuildNumber)
#endif

#ifndef kAppDefaultStatusBarStyle
#define kAppDefaultStatusBarStyle ([UIApplication sharedApplication].appDefaultStatusBarStyle)
#endif


