//
//  NUTrackingHTTPRequestHelper.m
//  NextUserKit
//
//  Created by NextUser on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackingHTTPRequestHelper.h"
#import "NUAction+Serialization.h"
#import "NUPurchase+Serialization.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"

// Uncomment this when building release version of the SDK
//#define IS_PRODUCTION_BUILD

#define END_POINT_PROD @"https://track.nextuser.com"
#define END_POINT_DEV @"https://track-dev.nextuser.com"

@implementation NUTrackingHTTPRequestHelper

#pragma mark - Public API

#pragma mark - Path

+ (NSString *)basePath
{
#ifdef IS_PRODUCTION_BUILD
    return END_POINT_PROD;
#else
    return END_POINT_DEV;
#endif
}

+ (NSString *)pathWithAPIName:(NSString *)APIName
{
    return [[self basePath] stringByAppendingFormat:@"/%@", APIName];
}

#pragma mark - Track Request URL Parameters

+ (NSDictionary *)trackScreenParametersWithScreenName:(NSString *)screenName
{
    NSDictionary *parameters = @{@"pv0" : [screenName URLEncodedString]};
    return parameters;
}

+ (NSDictionary *)trackActionsParametersWithActions:(NSArray *)actions
{
    // max 10 actions are allowed
    if (actions.count > 10) {
        actions = [actions subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:actions.count];
    for (int i=0; i<actions.count; i++) {
        NSString *actionKey = [NSString stringWithFormat:@"a%d", i];
        NSString *actionValue = [actions[i] httpRequestParameterRepresentation];
        
        parameters[actionKey] = actionValue;
    }
    
    return parameters;
}

+ (NSDictionary *)trackPurchasesParametersWithPurchases:(NSArray *)purchases
{
    // max 10 purchases are allowed
    if (purchases.count > 10) {
        purchases = [purchases subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:purchases.count];
    for (int i=0; i<purchases.count; i++) {
        NSString *purchaseKey = [NSString stringWithFormat:@"pu%d", i];
        NSString *purchaseValue = [purchases[i] httpRequestParameterRepresentation];
        
        parameters[purchaseKey] = purchaseValue;
    }
    
    return parameters;
}

@end
