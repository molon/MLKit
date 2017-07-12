//
//  NSString+MLAdd.m
//  MLKit
//
//  Created by molon on 16/6/6.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "NSString+MLAdd.h"
#import "MLKitMacro.h"
#import "NSData+MLAdd.h"
#import "NSNumber+MLAdd.h"
#import "UIScreen+MLAdd.h"
#import "NSAttributedString+MLAdd.h"
#import "UIImage+MLAdd.h"

SYNTH_DUMMY_CLASS(NSString_MLAdd)

@implementation NSString (MLAdd)

- (NSString *)md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5String];
}

- (NSString *)crc32String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] crc32String];
}

- (NSString *)base64EncodedString {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

+ (NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString {
    NSData *data = [NSData dataWithBase64EncodedString:base64EncodedString];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)stringByURLEncode {
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        /**
         AFNetworking/AFURLRequestSerialization.m
         
         Returns a percent-escaped string following RFC 3986 for a query string key or value.
         RFC 3986 states that the following characters are "reserved" characters.
         - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
         - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
         In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
         query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
         should be percent-escaped in the query string.
         - parameter string: The string to be percent-escaped.
         - returns: The percent-escaped string.
         */
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)stringByURLDecode {
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)stringByEscapingHTML {
    NSUInteger len = self.length;
    if (!len) return self;
    
    unichar *buf = malloc(sizeof(unichar) * len);
    if (!buf) return nil;
    [self getCharacters:buf range:NSMakeRange(0, len)];
    
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        unichar c = buf[i];
        NSString *esc = nil;
        switch (c) {
            case 34: esc = @"&quot;"; break;
            case 38: esc = @"&amp;"; break;
            case 39: esc = @"&apos;"; break;
            case 60: esc = @"&lt;"; break;
            case 62: esc = @"&gt;"; break;
            default: break;
        }
        if (esc) {
            [result appendString:esc];
        } else {
            CFStringAppendCharacters((CFMutableStringRef)result, &c, 1);
        }
    }
    free(buf);
    return result;
}

- (NSString *)stringByEscapingQuotes {
    return [self stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}

- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}

- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement; {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return self;
    return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}

- (char)charValue {
    return self.numberValue.charValue;
}

- (unsigned char)unsignedCharValue {
    return self.numberValue.unsignedCharValue;
}

- (short)shortValue {
    return self.numberValue.shortValue;
}

- (unsigned short)unsignedShortValue {
    return self.numberValue.unsignedShortValue;
}

- (unsigned int)unsignedIntValue {
    return self.numberValue.unsignedIntValue;
}

- (long)longValue {
    return self.numberValue.longValue;
}

- (unsigned long)unsignedLongValue {
    return self.numberValue.unsignedLongValue;
}

- (unsigned long long)unsignedLongLongValue {
    return self.numberValue.unsignedLongLongValue;
}

- (NSUInteger)unsignedIntegerValue {
    return self.numberValue.unsignedIntegerValue;
}

- (NSNumber *)numberValue {
    return [NSNumber numberWithString:self];
}

- (NSString *)stringByTrim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString*)stringByRemoveBlanks
{
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]componentsJoinedByString:@""];
}

- (BOOL)isNotBlank {
    if (self.length<=0) {
        return NO;
    }
    return ([self stringByRemoveBlanks].length>0);
}

- (BOOL)isPureInteger {
    NSScanner *scan = [NSScanner scannerWithString:self];
    unsigned long long val;
    return [scan scanUnsignedLongLong:&val] && [scan isAtEnd];
}

- (BOOL)isPureDecimal{
    NSScanner *scan = [NSScanner scannerWithString:self];
    NSDecimal val;
    return [scan scanDecimal:&val] && [scan isAtEnd];
}

- (NSString *)firstLetter {
    if (self.length<=0) {
        return @"#";
    }
    
    NSString *noBlankString = [self stringByRemoveBlanks];
    if (noBlankString.length<=0) {
        return @"#";
    }
    
    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (__bridge CFMutableStringRef)[NSMutableString stringWithString:noBlankString]);
    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);
    NSMutableString *aNSString = (__bridge_transfer NSMutableString *)string;
    if (aNSString.length<=0) {
        return @"#";
    }
    
    unichar firstLetter = [aNSString characterAtIndex:0];
    if (firstLetter>=65 && firstLetter<=90) { //A..Z
        return [NSString stringWithFormat:@"%C",firstLetter];
    }else if (firstLetter>=97 && firstLetter<=122) { //a..z
        return [[NSString stringWithFormat:@"%C",firstLetter]uppercaseString];
    }
    
    return @"#";
}

- (NSString*)firstLineString {
    NSArray* lines = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return [lines firstObject];
}

- (BOOL)containsString:(NSString *)string {
    if (string == nil) return NO;
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)containsCharacterSet:(NSCharacterSet *)set {
    if (set == nil) return NO;
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

- (NSString *)normalizedPhoneNumber {
    NSCharacterSet *nonNumericSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet];
    return [[self componentsSeparatedByCharactersInSet:nonNumericSet] componentsJoinedByString:@""];
}

- (NSData *)dataValue {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (NSArray*)componentsSeparatedWithoutBlankByString:(NSString*)str {
    NSMutableArray *arr = [[self componentsSeparatedByString:str]mutableCopy];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isNotBlank]) {
            [indexes addIndex:idx];
        }
    }];
    if (indexes.count>0) {
        [arr removeObjectsAtIndexes:indexes];
    }
    return arr;
}

- (NSAttributedString*)attributedStringWithRegex:(NSRegularExpression*)regex block:(NSAttributedString*(^)(NSRange range, NSArray *groups, BOOL * _Nonnull stop))block {
    NSAttributedString *attStr = [[NSAttributedString alloc]initWithString:self];
    return [attStr attributedStringWithRegex:regex block:block];
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    NSAssert(font!=nil, @"sizeForFont:size:mode: must be given a font");
    if (self.length<=0) {
        return CGSizeZero;
    }
    
    CGSize result;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    
    CGFloat scale = kScreenScale;
    result.height = ceil(result.height * scale)/scale;
    result.width = ceil(result.width * scale)/scale;
    return result;
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size {
    return [self sizeForFont:font size:size mode:NSLineBreakByWordWrapping];
}

- (CGSize)sizeForFont:(UIFont *)font width:(CGFloat)width {
    return [self sizeForFont:font size:CGSizeMake(width, HUGE)];
}

- (CGSize)sizeForFont:(UIFont *)font {
    return [self sizeForFont:font width:HUGE];
}

- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width {
    return [self sizeForFont:font width:width].height;
}

- (CGSize)singleLineSizeForFont:(UIFont *)font {
    NSString *firstLineString = [self firstLineString];
    return [firstLineString sizeForFont:font size:CGSizeMake(HUGE, HUGE)];
}

- (CGSize)singleLineSizeForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self singleLineSizeForFont:font];
    size.width = fmin(size.width, width);
    return size;
}

- (CGFloat)singleLineWidthForFont:(UIFont *)font width:(CGFloat)width {
    return [self singleLineSizeForFont:font width:width].width;
}

- (CGFloat)singleLineHeightForFont:(UIFont *)font {
    return [self singleLineSizeForFont:font].height;
}

- (void)drawAtPoint:(CGPoint)point
              angle:(CGFloat)angle
               font:(UIFont *)font
              color:(UIColor*)color {
    CGSize textSize = [self sizeForFont:font];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform t = CGAffineTransformMakeTranslation(point.x, point.y);
    CGAffineTransform r = CGAffineTransformMakeRotation(angle);
    
    CGContextConcatCTM(context, t);
    CGContextConcatCTM(context, r);
    
    NSDictionary *attribute = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
    [self drawAtPoint:CGPointMake(-1 * textSize.width / 2, -1 * textSize.height / 2)
       withAttributes:attribute];
    
    CGContextConcatCTM(context, CGAffineTransformInvert(r));
    CGContextConcatCTM(context, CGAffineTransformInvert(t));
}

- (id)objectFromJSONString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data objectFromJSONData];
}

- (id)mutableObjectFromJSONString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data mutableObjectFromJSONData];
}

- (nullable UIImage*)QRCodeImageWithSide:(CGFloat)side logo:(UIImage*)logo logoRatio:(CGFloat)logoRatio {
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 2、设置数据
    // 将字符串转换成 NSdata (虽然二维码本质上是字符串, 但是这里需要转换, 不转换就崩溃)
    NSData *qrImageData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    // 设置过滤器的输入值, KVC赋值
    [filter setValue:qrImageData forKey:@"inputMessage"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    // 图片小于(27,27),我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    
    // 4、将CIImage类型转成UIImage类型
    UIImage *start_image = [UIImage imageWithCIImage:outputImage];
    
    // - - - - - - - - - - - - - - - - 添加中间小图标 - - - - - - - - - - - - - - - -
    // 5、开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContextWithOptions(start_image.size, NO, kScreenScale);
    
    // 把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [start_image drawInRect:CGRectMake(0, 0, start_image.size.width, start_image.size.height)];
    
    // 再把小图片画上去
    if (logo) {
        UIImage *icon_image = logo;
        CGFloat icon_imageW = start_image.size.width * logoRatio;
        CGFloat icon_imageH = start_image.size.height * logoRatio;
        CGFloat icon_imageX = (start_image.size.width - icon_imageW) * 0.5;
        CGFloat icon_imageY = (start_image.size.height - icon_imageH) * 0.5;
        
        [icon_image drawInRect:CGRectMake(icon_imageX, icon_imageY, icon_imageW, icon_imageH)];
    }
    
    // 6、获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 7、关闭图形上下文
    UIGraphicsEndImageContext();
    
    return [final_image imageByResizeToSize:CGSizeMake(side, side)];
}

@end
