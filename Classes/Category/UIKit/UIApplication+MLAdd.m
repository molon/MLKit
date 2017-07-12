//
//  UIApplication+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "UIApplication+MLAdd.h"
#import "NSArray+MLAdd.h"
#import "NSObject+MLAdd.h"
#import "MLKitMacro.h"
#import "UIDevice+MLAdd.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <objc/runtime.h>
#import "NSString+MLAdd.h"
#import "NSDictionary+MLAdd.h"

SYNTH_DUMMY_CLASS(UIApplication_MLAdd)

#define kNetworkIndicatorDelay (1/30.0)
@interface _MLUIApplicationNetworkIndicatorInfo : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation _MLUIApplicationNetworkIndicatorInfo
@end


@implementation UIApplication (MLAdd)

- (NSURL *)documentsURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)cachesURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSCachesDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)cachesPath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)libraryURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSLibraryDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)libraryPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

- (BOOL)isPirated {
    if ([[UIDevice currentDevice] isSimulator]) return YES; // Simulator is not from appstore
    
    if (getgid() <= 10) return YES; // process ID shouldn't be root
    
    if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"]) {
        return YES;
    }
    
    if (![self ____fileExistInMainBundle:@"_CodeSignature"]) {
        return YES;
    }
    
    if (![self ____fileExistInMainBundle:@"SC_Info"]) {
        return YES;
    }
    
    //if someone really want to crack your app, this method is useless..
    //you may change this method's name, encrypt the code and do more check..
    return NO;
}

- (BOOL)____fileExistInMainBundle:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", bundlePath, name];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSString *)appDisplayName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (NSString *)appBundleName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)appBundleID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)appBuildNumber {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (UIStatusBarStyle)appDefaultStatusBarStyle {
    static UIStatusBarStyle appBaseStatusBarStyle = UIStatusBarStyleDefault;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *statusBarStyles = @[@"UIStatusBarStyleDefault",@"UIStatusBarStyleLightContent",@"UIStatusBarStyleBlackTranslucent",@"UIStatusBarStyleBlackOpaque"];
        appBaseStatusBarStyle = [statusBarStyles indexOfObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIStatusBarStyle"]];
        if ((NSInteger)appBaseStatusBarStyle==NSNotFound) {
            appBaseStatusBarStyle = UIStatusBarStyleDefault;
        }
    });
    
    return appBaseStatusBarStyle;
}

- (BOOL)isBeingDebugged {
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc info;
    int ret = 0, name[4];
    memset(&info, 0, sizeof(struct kinfo_proc));
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID; name[3] = getpid();
    
    if (ret == (sysctl(name, 4, &info, &size, NULL, 0))) {
        return ret != 0;
    }
    return (info.kp_proc.p_flag & P_TRACED) ? YES : NO;
}

- (int64_t)memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kern = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kern != KERN_SUCCESS) return -1;
    return info.resident_size;
}

- (float)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

SYNTH_DYNAMIC_PROPERTY_OBJECT(networkActivityInfo, setNetworkActivityInfo:, RETAIN_NONATOMIC, _MLUIApplicationNetworkIndicatorInfo *);

- (void)_delaySetActivity:(NSTimer *)timer {
    NSNumber *visiable = timer.userInfo;
    if (self.networkActivityIndicatorVisible != visiable.boolValue) {
        [self setNetworkActivityIndicatorVisible:visiable.boolValue];
    }
    [timer invalidate];
}

- (void)_changeNetworkActivityCount:(NSInteger)delta {
    @synchronized(self){
        dispatch_async(dispatch_get_main_queue(),^{
            _MLUIApplicationNetworkIndicatorInfo *info = [self networkActivityInfo];
            if (!info) {
                info = [_MLUIApplicationNetworkIndicatorInfo new];
                [self setNetworkActivityInfo:info];
            }
            NSInteger count = info.count;
            count += delta;
            info.count = count;
            [info.timer invalidate];
            info.timer = [NSTimer timerWithTimeInterval:kNetworkIndicatorDelay target:self selector:@selector(_delaySetActivity:) userInfo:@(info.count > 0) repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:info.timer forMode:NSRunLoopCommonModes];
        });
    }
}

- (void)incrementNetworkActivityCount {
    [self _changeNetworkActivityCount:1];
}

- (void)decrementNetworkActivityCount {
    [self _changeNetworkActivityCount:-1];
}

+ (BOOL)isAppExtension {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if(!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
    return isAppExtension;
}

+ (void)checkWithBundleID:(NSString*)bundleID promptInterval:(NSTimeInterval)promptInterval pullBlock:(void (^)(NSString *bundleID, UIApplicationCheckVersionPullCallBackBlock callback))pullBlock promptBlock:(void(^)(BOOL mustUpdate,NSString *version,NSString *releaseNotes,NSURL *updateURL))promptBlock {
    NSAssert(pullBlock&&promptBlock, @"必须给予pullBlock和promptBlock");
    bundleID = [bundleID isNotBlank]?bundleID:kAppBundleID;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *udJSON = nil;
    
    NSString * const kCheckVersionResultJSONUDKey = @"com.molon.MLVersionCheckerResultJSONUDKey";
    //取出来
    id r = [ud objectForKey:kCheckVersionResultJSONUDKey];
    if ([r isKindOfClass:[NSDictionary class]]) {
        udJSON = r;
    }
    
    //如果bundleID不一致，那之前的缓存就没任何意义
    if (![[udJSON stringValueForKey:@"bundleID" default:nil]isEqualToString:bundleID]) {
        udJSON = nil;
    }
    
    BOOL mustUpdate = [udJSON boolValueForKey:@"mustUpdate" default:NO];
    NSTimeInterval lastPromptTime = [[udJSON numberValueForKey:@"lastPromptTime" default:nil]doubleValue];
    //没到提醒间隔就不需要继续了，但是如果已知是必须更新，就忽略这个间隔
    if (!mustUpdate&&fmax(0, [[NSDate date]timeIntervalSince1970]-lastPromptTime)<promptInterval) {
        return;
    }
    
    BOOL (^doBlock)(NSDictionary *json) = ^BOOL(NSDictionary *json){
        NSString *version = [json stringValueForKey:@"version" default:nil];
        if ([version isNotBlank]&&[kAppVersion compare:version options:NSNumericSearch] == NSOrderedAscending) {
            NSString *releaseNotes = [json stringValueForKey:@"releaseNotes" default:nil];
            NSURL *updateURL = [json URLValueForKey:@"updateURL" default:nil];
            BOOL mustUpdate = [json boolValueForKey:@"mustUpdate" default:NO];
            
            if ([releaseNotes isNotBlank]&&updateURL.scheme) {
                //存储记录
                NSMutableDictionary *mJSON = [json mutableCopy];
                mJSON[@"lastPromptTime"] = @([[NSDate date]timeIntervalSince1970]);
                [ud setObject:mJSON forKey:kCheckVersionResultJSONUDKey];
                [ud synchronize];
                
                promptBlock(mustUpdate,version,releaseNotes,updateURL);
                return YES;
            }
        }
        return NO;
    };
    
    if (doBlock(udJSON)) {
        return;
    }
    
    //执行拉取方法
    void(^pullCallback)(BOOL succeed,BOOL mustUpdate,NSString *version,NSString *releaseNotes,NSURL *updateURL) = ^(BOOL succeed,BOOL mustUpdate,NSString *version,NSString *releaseNotes,NSURL *updateURL){
        if (!succeed) { //没成功就啥也不做呗
            return;
        }
        
        //存储并做处理
        NSDictionary *json = @{
                               @"bundleID":bundleID?:@"",
                               @"version":version?:@"",
                               @"mustUpdate":@(mustUpdate),
                               @"releaseNotes":releaseNotes?:@"",
                               @"updateURL":[updateURL absoluteString]?:@"",
                               };
        doBlock(json);
    };
    pullBlock(bundleID,pullCallback);
}

@end
