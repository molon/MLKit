//
//  MLUserDefaults.m
//  MLKitExample
//
//  Created by molon on 16/8/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "MLUserDefaults.h"
#import <MLPersonalModel/YYModel.h>

NSString * const PrefixKeyOfMLUserDefaults = @"com.molon.MLUserDefaults.";

@interface MLUserDefaults()

@property (nonatomic, strong) NSArray *ignoreKeys;

@end

@implementation MLUserDefaults

+ (instancetype)defaults {
    static MLUserDefaults *_defaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSAssert([self class]!=[MLUserDefaults class], @"You must use subclass of MLUserDefaults!!");
        _defaults = [[[self class] alloc]init];
    });
    return _defaults;
}

- (void)afterFirstSetValuesFromStandardUserDefaults {
}

- (NSArray *)configureIgnoreKeys {
    return nil;
}

+ (NSDictionary *)modelCustomPropertyDefaultValueMapper {
    return @{};
}

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.ignoreKeys = [self configureIgnoreKeys];
        
        //get the propertyInfos of self, dont contain MLUserDefaults's
        NSDictionary<NSString *, YYClassPropertyInfo *> *propertyInfos = [[self class]yy_propertyInfosUntilClass:[MLUserDefaults class] ignoreUntilClass:YES];
        
        //get the standardUserDefaults
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        //create a dict for setting
        NSMutableDictionary *setterDict = [NSMutableDictionary dictionaryWithCapacity:propertyInfos.count];
        
        for (NSString *key in [propertyInfos allKeys]) {
            if ([_ignoreKeys containsObject:key]) {
                setterDict[key] = (id)kCFNull; //just reset
                continue;
            }
            
            id object = [def objectForKey:[NSString stringWithFormat:@"%@%@",PrefixKeyOfMLUserDefaults,key]];
            //if is null, the default value will be set
            setterDict[key] = object?object:(id)kCFNull;
        }
        
        //set
        [self yy_modelSetWithDictionary:setterDict];
        
        //add kvo
        for (NSString *key in [propertyInfos allKeys]) {
            if ([_ignoreKeys containsObject:key]) {
                continue;
            }
            [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        }
        
        [self afterFirstSetValuesFromStandardUserDefaults];
    }
    return self;
}

- (void)dealloc {
    NSDictionary<NSString *, YYClassPropertyInfo *> *propertyInfos = [[self class]yy_propertyInfosUntilClass:[MLUserDefaults class] ignoreUntilClass:YES];
    
    for (NSString *key in [propertyInfos allKeys]) {
        if ([_ignoreKeys containsObject:key]) {
            continue;
        }
        
        //remove kvo
        [self removeObserver:self forKeyPath:key context:nil];
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    
    if ([kind integerValue] == NSKeyValueChangeSetting) {
        id newObject = [change objectForKey:NSKeyValueChangeNewKey];
        [self writeIntoStandardUserDefaultsWithObject:newObject forKey:keyPath];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - setter
- (void)setDisableSynchronize:(BOOL)disableSynchronize {
    _disableSynchronize = disableSynchronize;
    if (!disableSynchronize) {
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - helper
- (void)writeIntoStandardUserDefaultsWithObject:(id)object forKey:(NSString*)key {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *archiveKey = [NSString stringWithFormat:@"%@%@",PrefixKeyOfMLUserDefaults,key];
    
    if (!object || object == (id)kCFNull) {
        [def removeObjectForKey:archiveKey];
    }else{
        id archiveObject = [object yy_modelToJSONObject];
        if (!archiveObject) {
            [def setObject:object forKey:archiveKey];
        }else{
            [def setObject:archiveObject forKey:archiveKey];
        }
    }
    
    if (!_disableSynchronize) {
        [def synchronize];
    }
}
@end
