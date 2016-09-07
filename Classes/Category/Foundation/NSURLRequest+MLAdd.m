//
//  NSURLRequest+MLAdd.m
//  Pods
//
//  Created by molon on 16/8/9.
//
//

#import "NSURLRequest+MLAdd.h"
#import "MLKitMacro.h"
#import "NSString+MLAdd.h"

SYNTH_DUMMY_CLASS(NSURLRequest_MLAdd)

@implementation NSURLRequest (MLAdd)

- (NSString *)cURLCommandString {
    return [self cURLCommandStringWithDumpHeader:YES jsonPP:NO];
}

- (NSString *)cURLCommandStringWithDumpHeader:(BOOL)dumpHeader jsonPP:(BOOL)jsonPP {
    NSMutableString *curlString = [NSMutableString stringWithFormat:@"curl -k -X %@", self.HTTPMethod];
    
    if (dumpHeader) {
        [curlString appendString:@" --dump-header -"];
    }
    
    for (NSString *key in self.allHTTPHeaderFields.allKeys) {
        NSString *headerKey = [key stringByEscapingQuotes];
        NSString *headerValue = [self.allHTTPHeaderFields[key] stringByEscapingQuotes];
        
        [curlString appendFormat:@" -H \"%@: %@\"", headerKey, headerValue];
    }
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookiesForURL:self.URL];
    if (cookies.count>0) {
        NSMutableString *cookieString = [NSMutableString stringWithString:@"--cookie \""];
        for (NSHTTPCookie *cookie in cookies) {
            NSString *cookieKey = [cookie.name stringByEscapingQuotes];
            NSString *cookieValue = [cookie.value stringByEscapingQuotes];
            [cookieString appendFormat:@"%@=%@; ", cookieKey, cookieValue];
        }
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length-2, 2)];
        [cookieString appendString:@"\""];
        
        [curlString appendFormat:@" %@",cookieString];
    }
    
    NSString *bodyDataString = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
    if ([bodyDataString isNotBlank]) {
        bodyDataString = [bodyDataString stringByEscapingQuotes];
        
        [curlString appendFormat:@" -d \"%@\"", bodyDataString];
    }
    
    [curlString appendFormat:@" \"%@\"", self.URL.absoluteString];
    
    if (jsonPP) {
        [curlString appendString:@" | json_pp"];
    }
    
    return curlString;
}

@end
