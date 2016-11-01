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

@interface NSMutableString (____ForNSURLRequest)
- (void)____appendCommandLineArgument:(NSString *)arg;
@end

@implementation NSMutableString (____ForNSURLRequest)

- (void)____appendCommandLineArgument:(NSString *)arg {
    [self appendFormat:@" %@", [arg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

@end

@implementation NSURLRequest (MLAdd)

- (NSString*)curlCommandWithDumpHeader:(BOOL)dumpHeader jsonPP:(BOOL)jsonPP {
    NSAssert(!(dumpHeader&&jsonPP), @"`dumpHeader` and `jsonPP` cant be YES simultaneously!");
    
    NSMutableString *command = [NSMutableString stringWithString:@"curl"];
    
    [command ____appendCommandLineArgument:[NSString stringWithFormat:@"-X %@", [self HTTPMethod]]];
    
    if (dumpHeader) {
        [command ____appendCommandLineArgument:@"--dump-header -"];
    }
    
    if ([[self HTTPBody] length] > 0) {
        NSMutableString *HTTPBodyString = [[NSMutableString alloc] initWithData:[self HTTPBody] encoding:NSUTF8StringEncoding];
        [HTTPBodyString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"`" withString:@"\\`" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [HTTPBodyString replaceOccurrencesOfString:@"$" withString:@"\\$" options:0 range:NSMakeRange(0, [HTTPBodyString length])];
        [command ____appendCommandLineArgument:[NSString stringWithFormat:@"-d \"%@\"", HTTPBodyString]];
    }
    
    NSString *acceptEncodingHeader = [[self allHTTPHeaderFields] valueForKey:@"Accept-Encoding"];
    if ([acceptEncodingHeader rangeOfString:@"gzip"].location != NSNotFound) {
        [command ____appendCommandLineArgument:@"--compressed"];
    }
    
    if ([self URL]) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[self URL]];
        if (cookies.count) {
            NSMutableString *mutableCookieString = [NSMutableString string];
            for (NSHTTPCookie *cookie in cookies) {
                [mutableCookieString appendFormat:@"%@=%@;", cookie.name, cookie.value];
            }
            
            [command ____appendCommandLineArgument:[NSString stringWithFormat:@"--cookie \"%@\"", mutableCookieString]];
        }
    }
    
    for (id field in [self allHTTPHeaderFields]) {
        [command ____appendCommandLineArgument:[NSString stringWithFormat:@"-H %@", [NSString stringWithFormat:@"'%@: %@'", field, [[self valueForHTTPHeaderField:field] stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"]]]];
    }
    
    [command ____appendCommandLineArgument:[NSString stringWithFormat:@"\"%@\"", [[self URL] absoluteString]]];
    
    if (jsonPP) {
        [command ____appendCommandLineArgument:@"| json_pp"];
    }
    
    return [NSString stringWithString:command];
}

@end
