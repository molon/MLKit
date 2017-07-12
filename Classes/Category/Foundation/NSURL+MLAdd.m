//
//  NSURL+MLAdd.m
//  Pods
//
//  Created by molon on 2017/7/12.
//
//

#import "NSURL+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(NSURL_MLAdd)

@implementation NSURL (MLAdd)

- (NSURL*)URLByAddingParams:(NSDictionary*)params {
    NSURLComponents *c = [[NSURLComponents alloc]initWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableArray *arr = [c.queryItems mutableCopy];
    if (!arr) {
        arr = [NSMutableArray array];
    }
    for (NSString *key in [params allKeys]) {
        id value = params[key];
        if ([value isKindOfClass:[NSString class]]) {
            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:value];
            [arr addObject:item];
        }
    }
    c.queryItems = arr;
    return c.URL;
}

@end
