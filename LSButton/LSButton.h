//
//  LSButton.h
//  LSButton
//
//  Created by Yang on 2015/01/16.
//  Copyright (c) 2015 Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface LSButton : UIButton

@property (nonatomic) IBInspectable CGFloat titleShadowOffsetX;
@property (nonatomic) IBInspectable CGFloat titleShadowOffsetY;
@property (nonatomic) IBInspectable CGFloat titleShadowLength;
@property (nonatomic) IBInspectable CGFloat titleShadowAngel;
@property (nonatomic) IBInspectable BOOL hideTitleStringShadow;
@property (nonatomic) IBInspectable BOOL hideTitleImageShadow;

+ (LSButton *)buttonWithFrame:(CGRect)frame
                         icon:(UIImage*)icon
                  buttonColor:(UIColor*)buttonColor
             titleShadowColor:(UIColor*)titleShadowColor
                    tintColor:(UIColor*)tintColor
                       radius:(CGFloat)radius
                        titleShadowAngel:(CGFloat)titleShadowAngel
                      target:(id)tar
                      action:(SEL)sel;
@end
