//
//  UIButton+MLAdd.m
//  Pods
//
//  Created by molon on 2017/6/15.
//
//

#import "UIButton+MLAdd.h"
#import "MLKitMacro.h"

SYNTH_DUMMY_CLASS(UIButton_MLAdd)

@implementation UIButton (MLAdd)

- (void)changeDisplayToLeftTitleRightImage:(BOOL)ltri {
    if (ltri) {
        self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }else{
        self.transform = CGAffineTransformIdentity;
        self.titleLabel.transform = CGAffineTransformIdentity;
        self.imageView.transform = CGAffineTransformIdentity;
    }
}

@end
