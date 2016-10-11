//
//  FakeTouch.h
//  MLKitExample
//
//  Created by molon on 2016/10/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeTouch : NSObject

+ (void)tapAtPoint:(CGPoint)point moveOffset:(UIOffset)moveOffset window:(UIWindow*)window;
+ (void)tapAtPoint:(CGPoint)point moveOffset:(UIOffset)moveOffset;
+ (void)tapAtPoint:(CGPoint)point;
+ (void)defaultTap5OffsetAtPoint:(CGPoint)point;

@end

@interface UITouch (FakeTouch)

@end

@interface UIEvent (FakeTouch)

@end
