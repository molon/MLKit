//
//  CALayer+MLAdd.h
//  MLKitExample
//
//  Created by molon on 16/7/12.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `CALayer`.
 */
@interface CALayer (MLAdd)

@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGPoint center;      ///< Shortcut for center.
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic, getter=frameSize, setter=setFrameSize:) CGSize  size; ///< Shortcut for frame.size.


@property (nonatomic) CGFloat transformRotation;     ///< key path "tranform.rotation"
@property (nonatomic) CGFloat transformRotationX;    ///< key path "tranform.rotation.x"
@property (nonatomic) CGFloat transformRotationY;    ///< key path "tranform.rotation.y"
@property (nonatomic) CGFloat transformRotationZ;    ///< key path "tranform.rotation.z"
@property (nonatomic) CGFloat transformScale;        ///< key path "tranform.scale"
@property (nonatomic) CGFloat transformScaleX;       ///< key path "tranform.scale.x"
@property (nonatomic) CGFloat transformScaleY;       ///< key path "tranform.scale.y"
@property (nonatomic) CGFloat transformScaleZ;       ///< key path "tranform.scale.z"
@property (nonatomic) CGFloat transformTranslationX; ///< key path "tranform.translation.x"
@property (nonatomic) CGFloat transformTranslationY; ///< key path "tranform.translation.y"
@property (nonatomic) CGFloat transformTranslationZ; ///< key path "tranform.translation.z"

/**
 Shortcut for transform.m34, -1/1000 is a good value.
 It should be set before other transform shortcut.
 */
@property (nonatomic) CGFloat transformDepth;

/**
 Wrapper for `contentsGravity` property.
 */
@property (nonatomic) UIViewContentMode contentMode;

/**
 Remove all sublayers.
 */
- (void)removeAllSublayers;


@end

NS_ASSUME_NONNULL_END
