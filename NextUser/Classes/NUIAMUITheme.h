//
//  NUIAMUITheme.h
//  NextUserKit
//
//  Created by Dino on 3/17/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NUIAMUITheme : NSObject <NSCoding>

+ (instancetype)defautTheme;
+ (instancetype)themeWithBackgroundColor:(UIColor *)backgroundColor
                               textColor:(UIColor *)textColor
                                textFont:(UIFont *)textFont;

@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UIColor *textColor;
@property (nonatomic, readonly) UIFont *textFont;

@end
