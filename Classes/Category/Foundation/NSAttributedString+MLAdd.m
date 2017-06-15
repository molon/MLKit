//
//  NSAttributedString+MLAdd.m
//  Pods
//
//  Created by molon on 2017/6/14.
//
//

#import "NSAttributedString+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(NSAttributedString_MLAdd)

@implementation NSAttributedString (MLAdd)

- (NSAttributedString*)attributedStringWithRegex:(NSRegularExpression*)regex block:(NSAttributedString*(^)(NSRange range, NSArray *groups, BOOL * _Nonnull stop))block {
    NSParameterAssert(regex);
    
    NSInteger length = [self length];
    if (length<=0) {
        return self;
    }
    
    NSMutableAttributedString *resultAttributedString = [NSMutableAttributedString new];
    
    //正则匹配所有内容
    NSArray *results = [regex matchesInString:self.string
                                          options:NSMatchingWithTransparentBounds
                                            range:NSMakeRange(0, length)];
    
    //遍历结果，找到结果中被()包裹的区域作为显示内容
    NSUInteger location = 0;
    for (NSTextCheckingResult *result in results) {
        NSRange range = result.range;
        
        //把前面的非匹配出来的区域加进来
        NSAttributedString *subAttrStr = [self attributedSubstringFromRange:NSMakeRange(location, range.location - location)];
        [resultAttributedString appendAttributedString:subAttrStr];
        //下次循环从当前匹配区域的下一个位置开始
        location = NSMaxRange(range);
        
        NSMutableArray *groups = [NSMutableArray array];
        for (NSInteger i=0; i<[result numberOfRanges]; i++) {
            [groups addObject:[self attributedSubstringFromRange:[result rangeAtIndex:i]]];
        }
        
        if (block) {
            BOOL stop = NO;
            NSAttributedString *append = block(range,groups,&stop);
            if (append) {
                [resultAttributedString appendAttributedString:append];
            }
            if (stop) {
                break;
            }
        }
    }
    
    if (location < length) {
        //到这说明最后面还有非表情字符串
        NSRange range = NSMakeRange(location, length - location);
        NSAttributedString *subAttrStr = [self attributedSubstringFromRange:range];
        [resultAttributedString appendAttributedString:subAttrStr];
    }
    
    return resultAttributedString;
}

@end
