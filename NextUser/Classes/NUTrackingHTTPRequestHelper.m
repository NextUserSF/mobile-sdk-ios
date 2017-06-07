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
#import "NUUser+Serialization.h"
#import "NUTrackerSession.h"
#import "Base64.h"

@implementation NUTrackingHTTPRequestHelper

+(NSMutableDictionary *)trackScreenParametersWithScreenName:(NSString *)screenName
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    parameters[TRACK_PARAM_PV] = [screenName URLEncodedString];
    
    return parameters;
}


+(NSMutableDictionary *)trackActionsParametersWithActions:(NSArray<NUAction*> *)actions
{
    // max 10 actions are allowed
    if (actions.count > 10) {
        actions = [actions subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:actions.count];
    for (int i=0; i<actions.count; i++) {
        NSString *actionKey = [NSString stringWithFormat:TRACK_PARAM_A"%d", i];
        NSString *actionValue = [actions[i] httpRequestParameterRepresentation];
        
        parameters[actionKey] = actionValue;
    }
    
    return parameters;
}


+(NSMutableDictionary *)trackPurchasesParametersWithPurchases:(NSArray<NUPurchase*> *)purchases
{
    // max 10 purchases are allowed
    if (purchases.count > 10) {
        purchases = [purchases subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:purchases.count];
    for (int i=0; i<purchases.count; i++) {
        NSString *purchaseKey = [NSString stringWithFormat:TRACK_PARAM_PU"%d", i];
        NSString *purchaseValue = [purchases[i] httpRequestParameterRepresentation];
        
        parameters[purchaseKey] = purchaseValue;
    }
    
    return parameters;
}

+(NSMutableDictionary *)trackUserParametersWithVariables:(NUUser *)user {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[TRACK_SUBSCRIBER_PARAM] = [user httpRequestParameterRepresentation];
    
    if (user.userVariables != nil) {
        int index = 0;
        for (id key in user.userVariables.allKeys) {
            NSString *userVariableTrackKey = [NSString stringWithFormat:TRACK_SUBSCRIBER_VARIABLE_PARAM"%d", index];
            NSString *userVariableTrackValue = [NSString stringWithFormat:@"%@=%@", key,
                                                [user.userVariables[key] URLEncodedString]];
            parameters[userVariableTrackKey] = userVariableTrackValue;
            index++;
        }
    }
    
    return parameters;
}

+(NSDictionary *)sessionInitializationParameters:(NUTrackerSession*) session
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[TRACK_PARAM_TID] = [session apiKey];
    if ([session deviceCookie]) {
        parameters[TRACK_PARAM_DC] = [session deviceCookie];
    }
    
    return parameters;
}

+(NSDictionary *)appendSessionDefaultParameters:(NUTrackerSession*) session withTrackParameters:(NSMutableDictionary*) parameters
{
    NSString *tid = [session apiKey];
    if (session.user != nil && ![NSString lg_isEmptyString: session.user.userIdentifier]) {
        NSData *inputData = [session.user.userIdentifier dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Id = [inputData base64EncodedStringWithWrapWidth:0];
        tid = [tid stringByAppendingFormat:@"+%@", base64Id];
    }
    
    parameters[TRACK_PARAM_NUTMS] = [NSString stringWithFormat:@"...%@", [session deviceCookie]];
    parameters[TRACK_PARAM_NUTMSC] = [session sessionCookie];
    parameters[TRACK_PARAM_TID] = tid;
    parameters[TRACK_PARAM_VERSION] = TRACKER_VERSION;
    parameters[TRACK_PARAM_BUILD_VERSION] = @"1.0";
    parameters[TRACK_PARAM_DEVICE_TYPE] = TRACK_PARAM_DEVICE_TYPE_IOS;
    
    return parameters;
}

@end
