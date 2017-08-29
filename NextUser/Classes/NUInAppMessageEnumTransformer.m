//
//  InAppMessageEnumTransformer.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import "NUInAppMessageEnumTransformer.h"

@implementation InAppMessageEnumTransformer

+(InAppMsgLayoutType) toInAppMsgType:(NSString*) type
{
    if ([@"SKINNY" isEqualToString:type]) {
        return SKINNY;
    } else if ([@"MODAL" isEqualToString:type]) {
        return MODAL;
    } else if ([@"FULL" isEqualToString:type]) {
        return FULL;
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgLayoutType: %@", type]];
    @throw error;
}

+(InAppMsgAlign) toInAppMsgAlign:(NSString*) align
{
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
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgAlign: %@", align]];
    @throw error;
}

+(InAppMsgAction) toInAppMsgAction:(NSString*) action
{
    if ([@"dismiss" isEqualToString:action]) {
        return DISMISS;
    } else if ([@"landing" isEqualToString:action]) {
        return LANDING_PAGE;
    } else if ([@"url" isEqualToString:action]) {
        return URL;
    } else if ([@"deep_link" isEqualToString:action]) {
        return DEEP_LINK;
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgAction: %@", action]];
    @throw error;
}

@end
