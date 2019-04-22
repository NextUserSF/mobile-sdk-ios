#import <Foundation/Foundation.h>
#import "NUInAppMsgViewHelper.h"
#import "UIColor+CreateMethods.h"
#import "NSString+LGUtils.h"

#define DEFAULT_TEXT_COLOR @"#000000"
#define DEFAULT_BG_COLOR @"#FFFFFF"
#define DEFAULT_ALPHA_OPAQUE @"1"
#define DEFAULT_ALPHA_TRANSPARENT @"0"

@implementation InAppMsgViewHelper

+(NSTextAlignment) toTextAlignment:(InAppMsgAlign) align
{
    switch (align) {
        case LEFT:
            return NSTextAlignmentLeft;
        case RIGHT:
            return NSTextAlignmentRight;
        case CENTER:
            return NSTextAlignmentCenter;
        default:
            return NSTextAlignmentLeft;
    }
}

+(UIColor*) textColor:(NSString*)hexStr alpha:(CGFloat) alpha
{
    return [UIColor colorWithHex:[NSString lg_isEmptyString:hexStr] ? DEFAULT_TEXT_COLOR:hexStr alpha:alpha];
}

+(UIColor*) textColor:(NSString*)hexStr
{
    return [UIColor colorWithHex:[NSString lg_isEmptyString:hexStr] ? DEFAULT_TEXT_COLOR:hexStr alpha:[DEFAULT_ALPHA_OPAQUE floatValue]];
}

+(UIColor*) bgColor:(NSString*)hexStr
{
    return [UIColor colorWithHex:[NSString lg_isEmptyString:hexStr] ? DEFAULT_BG_COLOR:hexStr alpha:[DEFAULT_ALPHA_OPAQUE floatValue]];
}

@end
