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

//这个resetPrevious设置为YES的意思表示方法执行完的时候，最终_previousLocationInWindow会被重置为和_locationInWindow相等
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

+ (void)tapAtPoint:(CGPoint)point moveOffset:(UIOffset)moveOffset window:(UIWindow*)window {
    UITouch *touch = [UITouch touchWithPoint:point window:window];
    
    //begin
    UIEvent *beginEvent = [[UIEvent alloc] initWithTouch:touch];
    [touch.view touchesBegan:[beginEvent allTouches] withEvent:beginEvent];
    
    void (^endBlock)() = ^{
        //end
        [touch setPhase:UITouchPhaseEnded];
        UIEvent *endEvent = [[UIEvent alloc] initWithTouch:touch];
        [touch.view touchesEnded:[endEvent allTouches] withEvent:endEvent];
    };
    
    if (UIOffsetEqualToOffset(moveOffset, UIOffsetZero)) {
        //虽说是0.01f。但是实际运行起来没那么准确的，刚好也真实点
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            endBlock();
        });
        return;
    }
    
    //move
    //模拟几个移动点
    NSInteger t = (int)(fmax(ABS(moveOffset.horizontal), ABS(moveOffset.vertical)));
    NSInteger movePointCount = fmax(1, (t==0?0:arc4random()%t)); //最多N个轨迹点，N由offset来决定
    
    NSMutableArray *xs = [NSMutableArray arrayWithCapacity:movePointCount];
    NSMutableArray *ys = [NSMutableArray arrayWithCapacity:movePointCount];
    NSMutableArray *movePoints = [NSMutableArray arrayWithCapacity:movePointCount];
    for (NSInteger i=0; i<movePointCount; i++) {
        CGFloat randomOffsetX = (moveOffset.horizontal==0?0:arc4random()%((int)(moveOffset.horizontal))) * (moveOffset.horizontal>0?1:-1);
        CGFloat randomOffsetY = (moveOffset.vertical==0?0:arc4random()%((int)(moveOffset.vertical))) * (moveOffset.vertical>0?1:-1);
        
        [xs addObject:@(point.x+randomOffsetX)];
        [ys addObject:@(point.y+randomOffsetY)];
    }
    //整理xs和ys，使轨迹走正常方向
    [xs sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:moveOffset.horizontal>0]]];
    [ys sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:moveOffset.vertical>0]]];
    
    for (NSInteger i=0; i<movePointCount; i++) {
        [movePoints addObject:[NSValue valueWithCGPoint:CGPointMake([xs[i] doubleValue], [ys[i] doubleValue])]];
    }
    
    [self _moveTouch:touch locations:movePoints locationIndex:0 endBlock:endBlock];
}

+ (void)_moveTouch:(UITouch*)touch locations:(NSArray*)locations locationIndex:(NSInteger)locationIndex endBlock:(void(^)())endBlock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (locationIndex>=locations.count) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                endBlock();
            });
            return;
        }
        
        CGPoint location = [locations[locationIndex]CGPointValue];
        //如果和上一个相同就忽略这个
        if (CGPointEqualToPoint(location, [touch locationInView:touch.view])) {
            [self _moveTouch:touch locations:locations locationIndex:locationIndex+1 endBlock:endBlock];
            return;
        }
        
        [touch setPhase:UITouchPhaseMoved];
        [touch _setLocationInWindow:location resetPrevious:NO];
        UIEvent *moveEvent = [[UIEvent alloc]initWithTouch:touch];
        [touch.view touchesMoved:[moveEvent allTouches] withEvent:moveEvent];
        
        [self _moveTouch:touch locations:locations locationIndex:locationIndex+1 endBlock:endBlock];
    });
}

+ (void)tapAtPoint:(CGPoint)point moveOffset:(UIOffset)moveOffset {
    [self tapAtPoint:point moveOffset:moveOffset window:[UIApplication sharedApplication].keyWindow];
}

+ (void)tapAtPoint:(CGPoint)point {
    [self tapAtPoint:point moveOffset:UIOffsetZero];
}

+ (void)defaultTap5OffsetAtPoint:(CGPoint)point {
    [self tapAtPoint:point moveOffset:UIOffsetMake(5.0F, 5.0f)];
}

@end
