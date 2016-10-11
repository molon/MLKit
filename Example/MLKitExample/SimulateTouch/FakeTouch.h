//
//  FakeTouch.h
//  MLKitExample
//
//  Created by molon on 2016/10/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeTouch : NSObject

+ (void)fakeTouchAtPoint:(CGPoint)point;
+ (void)fakeTouchAtPoint:(CGPoint)point window:(UIWindow*)window;

@end

@interface UITouch (FakeTouch)

@end

@interface UIEvent (FakeTouch)

@end
