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
    return [self themeWithBackgroundColor:[self defaultBackgroundColor]
                                textColor:[self defaultTextColor]
                                 textFont:[self defaultTextFont]];
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

#pragma mark -

- (UIColor *)backgroundColor
{
    if (_backgroundColor) {
        return _backgroundColor;
    } else {
        return [self.class defaultBackgroundColor];
    }
}

- (UIColor *)textColor
{
    if (_textColor) {
        return _textColor;
    } else {
        return [self.class defaultTextColor];
    }
}

- (UIFont *)textFont
{
    if (_textFont) {
        return _textFont;
    } else {
        return [self.class defaultTextFont];
    }
}

#pragma mark - Private

+ (UIColor *)defaultBackgroundColor
{
    return [UIColor lightGrayColor];
}

+ (UIColor *)defaultTextColor
{
    return [UIColor whiteColor];
}

+ (UIFont *)defaultTextFont
{
    return [UIFont systemFontOfSize:15];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _backgroundColor = [decoder decodeObjectForKey:@"backgroundColor"];
    _textColor = [decoder decodeObjectForKey:@"textColor"];
    _textFont = [decoder decodeObjectForKey:@"textFont"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_backgroundColor forKey:@"backgroundColor"];
    [encoder encodeObject:_textColor forKey:@"textColor"];
    [encoder encodeObject:_textFont forKey:@"textFont"];
}

@end
