//
//  UIView+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/16.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIView`.
 */
@interface UIView (MLAdd)

@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  size;        ///< Shortcut for frame.size.

/**
 Returns the view's view controller (may be nil).
 */
@property (nullable, nonatomic, readonly) UIViewController *viewController;

/**
 Returns the visible alpha on screen, taking into account superview and window.
 */
@property (nonatomic, readonly) CGFloat visibleAlpha;

/**
 Create a snapshot image of the complete view hierarchy.
 */
- (nullable UIImage *)snapshotImage;

/**
 Create a snapshot image of the complete view hierarchy.
 @discussion It's faster than "snapshotImage", but may cause screen updates.
 See -[UIView drawViewHierarchyInRect:afterScreenUpdates:] for more information.
 */
- (nullable UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

/**
 Create a snapshot PDF of the complete view hierarchy.
 */
- (nullable NSData *)snapshotPDF;

/**
 Converts a point from the receiver's coordinate system to that of the specified view or window.
 
 @param point A point specified in the local coordinate system (bounds) of the receiver.
 @param view  The view or window into whose coordinate system point is to be converted.
 If view is nil, this method instead converts to window base coordinates.
 @return The point converted to the coordinate system of view.
 */
- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(nullable UIView *)view;

/**
 Converts a point from the coordinate system of a given view or window to that of the receiver.
 
 @param point A point specified in the local coordinate system (bounds) of view.
 @param view  The view or window with point in its coordinate system.
 If view is nil, this method instead converts from window base coordinates.
 @return The point converted to the local coordinate system (bounds) of the receiver.
 */
- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(nullable UIView *)view;

/**
 Converts a rectangle from the receiver's coordinate system to that of another view or window.
 
 @param rect A rectangle specified in the local coordinate system (bounds) of the receiver.
 @param view The view or window that is the target of the conversion operation. If view is nil, this method instead converts to window base coordinates.
 @return The converted rectangle.
 */
- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(nullable UIView *)view;

/**
 Converts a rectangle from the coordinate system of another view or window to that of the receiver.
 
 @param rect A rectangle specified in the local coordinate system (bounds) of view.
 @param view The view or window with rect in its coordinate system.
 If view is nil, this method instead converts from window base coordinates.
 @return The converted rectangle.
 */
- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(nullable UIView *)view;

/**
 Get the middle frame with width and height
 
 @param width  final width
 @param height final height
 
 @return the middle frame
 */
- (CGRect)centerFrameWithWidth:(CGFloat)width height:(CGFloat)height;

/**
 Shortcut to set the view.layer's shadow
 
 @param color  Shadow Color
 @param offset Shadow offset
 @param radius Shadow radius
 */
- (void)setLayerShadow:(nullable UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

/**
 Shortcut to set the background color and cornerRadius of layer.
 Tips: This method will set the masksToBounds to NO and set view.backgroundColor to clear
 
 @param color        color
 @param cornerRadius cornerRadius
 */
- (void)setLayerBackgroundColor:(UIColor*)color cornerRadius:(CGFloat)cornerRadius;

/**
 Remove all subviews.
 
 @warning Never call this method inside your view's drawRect: method.
 */
- (void)removeAllSubviews;

/**
 Remove subviews with test block
 
 @param comparator test block
 */
- (void)removeSubviewsPassingTest:(BOOL (^)(UIView *subview, BOOL *stop))comparator;

/**
 Detect whether contains one subview with test block
 
 @param comparator test block
 
 @return bool
 */
- (BOOL)containsSubviewPassingTest:(BOOL (^)(UIView *subview))comparator;

/**
 retrieve all descendants with test block
 
 @param comparator test block
 
 @return escendants
 */
- (NSArray*)retrieveDescendantsPassingTest:(BOOL (^)(UIView *v))comparator;

/**
 Detect whether self is descendant of (ancestor with test block, not contains self)
 
 @param comparator test block
 
 @return bool
 */
- (BOOL)isDescendantOfAncestorPassingTest:(BOOL (^)(UIView *ancestor))comparator;

/**
 Detect whether self is descendant of ancestor (not contains self)
 
 @param ancestor ancestor
 
 @return bool
 */
- (BOOL)isDescendantOfAncestor:(UIView *)ancestor;

///=============================================================================
/// @name Nib
///=============================================================================

/**
 Return UINib with nib name([self class])
 
 @return nib
 */
+ (UINib *)nib;

/**
 Return instancetype with nib name([self class])
 
 @return instancetype
 */
+ (instancetype)instanceFromNib;

///=============================================================================
/// @name Badge
///=============================================================================

/**
 Add badge view to self.superview, if badge value is blank, the badge view will be removed.
 @warning self.superview is required before call this method.
 
 @param badgeValue badgeValue
 
 @return the badge view
 */
- (nullable UIView *)addBadgeValue:(NSString *)badgeValue;

/**
 Add badge view to self.superview, if badge value is blank, the badge view will be removed.
 @warning self.superview is required before call this method.
 
 @param badgeValue    badgeValue
 @param displayOffset displayOffset
 
 @return the badge view
 */
- (nullable UIView *)addBadgeValue:(NSString *)badgeValue displayOffset:(UIOffset)displayOffset;

/**
 Remove badge value from self.superview
 @warning self.superview is required before call this method.
 */
- (void)removeBadgeValue;

/*!
 @brief Add point view to self.superview on self.rightUP
 
 @param color         color
 @param size          size
 @param displayOffset displayOffset
 
 @return point view
 */
- (UIView*)addPointViewWithColor:(nullable UIColor *)color size:(CGSize)size displayOffset:(UIOffset)displayOffset;

/*!
 @brief remove point view which binds self from self.superview
 */
- (void)removePointView;

///=============================================================================
/// @name Point Color
///=============================================================================

/**
 Returns the render color at point
 
 @param point point
 
 @return render color
 */
- (UIColor *)renderColorAtPoint:(CGPoint)point;

/**
 Returns whether the render color's alpha is 0
 
 @param point point
 
 @return whether the render color's alpha is 0
 */
- (BOOL)isTansparentAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
