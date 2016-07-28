//
//  UIColor+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIColor`.
 */
@interface UIColor (MLAdd)

/**
 *  Support multiple format
 *  {123} {123,0.9} {123,124,125} {123,124,125,0.9}
 *  [123/255.0f] [123/255.0f,0.9]
 *  #RRGGBB  0xRRGGBB  #RRGGBB0.9 0xRRGGBB0.9
 *  0.9 means the alpha
 */
+ (UIColor*)colorWithFormat:(NSString*)format;

@end

NS_ASSUME_NONNULL_END

/*
 Shortcut of colorWithMLString, only support hex string
 */
#ifndef UIColorHex
#define UIColorHex(_hex_) [UIColor colorWithFormat:((__bridge NSString *)CFSTR(#_hex_))]
#endif