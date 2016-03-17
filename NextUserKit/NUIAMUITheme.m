//
//  NUIAMUITheme.m
//  NextUserKit
//
//  Created by Dino on 3/17/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUIAMUITheme.h"

@interface NUIAMUITheme ()

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIFont *textFont;

@end

@implementation NUIAMUITheme

+ (instancetype)defautTheme
{
    return [self themeWithBackgroundColor:[UIColor grayColor]
                                textColor:[UIColor whiteColor]
                                 textFont:[UIFont systemFontOfSize:15]];
}

+ (instancetype)themeWithBackgroundColor:(UIColor *)backgroundColor
                               textColor:(UIColor *)textColor
                                textFont:(UIFont *)textFont
{
    NUIAMUITheme *theme = [[NUIAMUITheme alloc] init];
    
    theme.backgroundColor = backgroundColor;
    theme.textColor = textColor;
    theme.textFont = textFont;
    
    return theme;
}

@end
