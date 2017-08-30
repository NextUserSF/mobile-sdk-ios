//
//  InAppMessageEnumTransformer.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import "NUInAppMessageEnumTransformer.h"
#import "NSString+LGUtils.h"

@implementation InAppMessageEnumTransformer

+(InAppMsgLayoutType) toInAppMsgType:(id) type
{
    if (type == nil) {
        return NO_TYPE;
    }
    
    if ([type isKindOfClass:[NSNumber class]]) {
        
        switch ([type integerValue]) {
            case SKINNY:
                return SKINNY;
            case MODAL:
                return MODAL;
            case FULL:
                return FULL;
            case NO_TYPE:
                return NO_TYPE;
            default:
                break;
        }
        
    } else if ([type isKindOfClass:[NSString class]]) {
        if ([@"SKINNY" isEqualToString:type]) {
            return SKINNY;
        } else if ([@"MODAL" isEqualToString:type]) {
            return MODAL;
        } else if ([@"FULL" isEqualToString:type]) {
            return FULL;
        } else if ([NSString lg_isEmptyString:type]) {
            return NO_TYPE;
        }
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgLayoutType: %@", type]];
    @throw error;
}

+(InAppMsgAlign) toInAppMsgAlign:(NSString*) align
{
    if (align == nil) {
        return NO_ALIGN;
    }
    
    if ([align isKindOfClass:[NSNumber class]]) {
        switch ([align integerValue]) {
            case CENTER:
                return CENTER;
            case RIGHT:
                return RIGHT;
            case LEFT:
                return LEFT;
            case TOP:
                return TOP;
            case BOTTOM:
                return BOTTOM;
            case NO_ALIGN:
                return NO_ALIGN;
            default:
                break;
        }
    } else if ([align isKindOfClass:[NSString class]]) {
        
        if ([@"center" isEqualToString:align]) {
            return CENTER;
        } else if ([@"right" isEqualToString:align]) {
            return RIGHT;
        } else if ([@"left" isEqualToString:align]) {
            return LEFT;
        } else if ([@"top" isEqualToString:align]) {
            return TOP;
        } else if ([@"bottom" isEqualToString:align]) {
            return BOTTOM;
        } else if ([NSString lg_isEmptyString:align]) {
            return NO_ALIGN;
        }
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgAlign: %@", align]];
    @throw error;
}

+(InAppMsgAction) toInAppMsgAction:(NSString*) action
{
    if (action == nil) {
        return NO_ACTION;
    }
    
    if ([action isKindOfClass:[NSNumber class]]) {
        switch ([action integerValue]) {
            case DISMISS:
                return DISMISS;
            case LANDING_PAGE:
                return LANDING_PAGE;
            case URL:
                return URL;
            case DEEP_LINK:
                return DEEP_LINK;
            case NO_ACTION:
                return NO_ACTION;
            default:
                break;
        }
    } else if ([action isKindOfClass:[NSString class]]) {
        if ([@"dismiss" isEqualToString:action]) {
            return DISMISS;
        } else if ([@"landing" isEqualToString:action]) {
            return LANDING_PAGE;
        } else if ([@"url" isEqualToString:action]) {
            return URL;
        } else if ([@"deep_link" isEqualToString:action]) {
            return DEEP_LINK;
        } else if ([NSString lg_isEmptyString:action]) {
            return NO_ACTION;
        }
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgAction: %@", action]];
    @throw error;
}

@end
