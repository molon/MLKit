//
//  UICollectionViewCell+MLAdd.h
//  MLKit
//
//  Created by molon on 16/6/17.
//  Copyright © 2016年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UICollectionViewCell`.
 */
@interface UICollectionViewCell (MLAdd)

//=============================================================================
/// @name Other
///=============================================================================

/**
 Return reuse identifier named NSStringFromClass(self class)
 
 @return reuse identifier
 */
+ (NSString *)cellReuseIdentifier;

@end

NS_ASSUME_NONNULL_END