//
//  FakeTouch.m
//  MLKitExample
//
//  Created by molon on 2016/10/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import "FakeTouch.h"

//暴露私有方法
@interface UITouch()

- (void)_setIsFirstTouchForView:(BOOL)arg1;
- (void)setIsTap:(BOOL)arg1;
- (void)setPhase:(UITouchPhase)arg1;
- (void)setTapCount:(unsigned int)arg1;
- (void)setTimestamp:(NSTimeInterval)arg1;
- (void)setView:(id)arg1;
- (void)setWindow:(id)arg1;

- (void)_setLocationInWindow:(CGPoint)arg1 resetPrevious:(BOOL)arg2;

@end

@implementation UITouch (FakeTouch)

- (instancetype)initWithPoint:(CGPoint)point window:(UIWindow*)window
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    //设置必要属性
    [self setIsTap:YES];
    [self _setIsFirstTouchForView:YES];
    
    UIView *view = [window hitTest:point withEvent:nil];
    
    [self setView:view];
    [self setWindow:view.window];
    
    [self _setLocationInWindow:point resetPrevious:YES];
    
    [self setTapCount:1];
    [self setPhase:UITouchPhaseBegan];
    [self setTimestamp:[NSDate timeIntervalSinceReferenceDate]];
    
    //    [self setValue:view forKey:@"_view"];
    //    [self setValue:window forKey:@"_window"];
    //
    //    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    //    [self setValue:pointValue forKey:@"_locationInWindow"];
    //    [self setValue:pointValue forKey:@"_previousLocationInWindow"];
    //
    //    [self setValue:@(1) forKey:@"_tapCount"];
    //    [self setValue:@(UITouchPhaseBegan) forKey:@"_phase"];
    //    [self setValue:@([NSDate timeIntervalSinceReferenceDate]) forKey:@"_timestamp"];
    
    return self;
}

+ (instancetype)touchWithPoint:(CGPoint)point window:(UIWindow*)window
{
    return [[self alloc]initWithPoint:point window:window];
}

@end

//dummy class for - (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12; of UIEvent
@interface GSEventProxy : NSObject
{
@public
    unsigned int flags;
    unsigned int type;
    unsigned int ignored1;
    float x1;
    float y1;
    float x2;
    float y2;
    unsigned int ignored2[10];
    unsigned int ignored3[7];
    float sizeX;
    float sizeY;
    float x3;
    float y3;
    unsigned int ignored4[3];
}
@end
@implementation GSEventProxy
@end

//暴露私有方法
@interface UIEvent()

- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;

@end

@implementation UIEvent (FakeTouch)

- (id)initWithTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:touch.window];
    GSEventProxy *gsEventProxy = [[GSEventProxy alloc] init];
    gsEventProxy->x1 = location.x;
    gsEventProxy->y1 = location.y;
    gsEventProxy->x2 = location.x;
    gsEventProxy->y2 = location.y;
    gsEventProxy->x3 = location.x;
    gsEventProxy->y3 = location.y;
    gsEventProxy->sizeX = 1.0;
    gsEventProxy->sizeY = 1.0;
    gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    gsEventProxy->type = 3001;
    
    Class touchesEventClass = objc_getClass("UITouchesEvent");
    if (touchesEventClass && ![[self class] isEqual:touchesEventClass]) {
        self = [touchesEventClass alloc];
    }
    
    return [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
}

@end

@interface FakeTouch()
@end

@implementation FakeTouch

+ (void)fakeTouchAtPoint:(CGPoint)point window:(UIWindow*)window {
    UITouch *touch = [UITouch touchWithPoint:point window:window];
    
    //begin
    UIEvent *eventDown = [[UIEvent alloc] initWithTouch:touch];
    [touch.view touchesBegan:[eventDown allTouches] withEvent:eventDown];
    
    [touch setPhase:UITouchPhaseEnded];
    UIEvent *eventUp = [[UIEvent alloc] initWithTouch:touch];
    [touch.view touchesEnded:[eventUp allTouches] withEvent:eventUp];
}

+ (void)fakeTouchAtPoint:(CGPoint)point {
    [self fakeTouchAtPoint:point window:[UIApplication sharedApplication].keyWindow];
}

@end
