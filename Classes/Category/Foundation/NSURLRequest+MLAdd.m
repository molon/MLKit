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
