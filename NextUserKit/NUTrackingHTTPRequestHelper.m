//
//  NUTrackingHTTPRequestHelper.m
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackingHTTPRequestHelper.h"

#define END_POINT_DEV @"https://track-dev.nextuser.com"
#define END_POINT_PROD @"https://track.nextuser.com"

@implementation NUTrackingHTTPRequestHelper

#pragma mark - Public API

#pragma mark - Path

+ (NSString *)basePath
{
    return END_POINT_DEV;
}

+ (NSString *)pathWithAPIName:(NSString *)APIName
{
    return [[self basePath] stringByAppendingFormat:@"/%@", APIName];
}

#pragma mark - Parameters

+ (NSString *)trackActionURLEntryWithName:(NSString *)actionName parameters:(NSArray *)actionParameters
{
    NSString *actionValue = actionName;
    if (actionParameters.count > 0) {
        NSString *actionParametersString = [self trackActionParametersStringWithActionParameters:actionParameters];
        if (actionParametersString.length > 0) {
            actionValue = [actionValue stringByAppendingFormat:@",%@", actionParametersString];
        }
    }
    
    return actionValue;
}

+ (NSString *)trackActionParametersStringWithActionParameters:(NSArray *)actionParameters
{
    NSMutableString *parametersString = [NSMutableString stringWithString:@""];
    
    // max 10 parameters are allowed
    if (actionParameters.count > 10) {
        actionParameters = [actionParameters subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    // first, truncate trailing NSNull(s) of the input array
    // e.g.
    // [A, B, NSNull, NSNull, C, D, NSNull, NSNull, NSNull, NSNull]
    // -->
    // [A, B, NSNull, NSNull, C, D]
    BOOL hasAtLeastOneNonNullValue = NO;
    NSUInteger lastNonNullIndex = actionParameters.count-1;
    for (int i=(int)(actionParameters.count-1); i>=0; i--) {
        id valueAtIndex = actionParameters[i];
        if (![valueAtIndex isEqual:[NSNull null]]) {
            lastNonNullIndex = i;
            hasAtLeastOneNonNullValue = YES;
            break;
        }
    }
    
    if (hasAtLeastOneNonNullValue) {
        NSArray *truncatedParameters = [actionParameters subarrayWithRange:NSMakeRange(0, lastNonNullIndex+1)];
        if (truncatedParameters.count > 0) {
            for (int i=0; i<truncatedParameters.count; i++) {
                if (i > 0) { // add comma before adding each parameter except for the first one
                    [parametersString appendString:@","];
                }
                
                id actionParameter = truncatedParameters[i];
                if (![actionParameter isEqual:[NSNull null]]) {
                    [parametersString appendString:actionParameter];
                }
            }
        }
    }
    
    return [parametersString copy];
}

@end
