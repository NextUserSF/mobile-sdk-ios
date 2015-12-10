//
//  NUTrackingHTTPRequestHelper.m
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackingHTTPRequestHelper.h"
#import "NUPurchase.h"
#import "NUPurchaseItem.h"
#import "NUPurchaseDetails.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"
#import "NUAction.h"

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

#pragma mark - Track Request URL Parameters

+ (NSDictionary *)trackScreenParametersWithScreenName:(NSString *)screenName
{
    NSDictionary *parameters = @{@"pv0" : screenName};
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
        NSString *actionValue = [self serializedActionStringFromAction:actions[i]];
        
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
        NSString *purchaseValue = [self serializedPurchaseStringWithPurchase:purchases[i]];
        
        parameters[purchaseKey] = purchaseValue;
    }
    
    return parameters;
}

#pragma mark - Private API

#pragma mark - Serialization

+ (NSString *)serializedActionStringFromAction:(NUAction *)action
{
    NSString *actionValue = [action.actionName URLEncodedString];
    if (action.parameters.count > 0) {
        NSString *actionParametersString = [self serializedActionParametersStringWithActionParameters:action.parameters];
        if (actionParametersString.length > 0) {
            actionValue = [actionValue stringByAppendingFormat:@",%@", actionParametersString];
        }
    }
    
    return actionValue;
}

+ (NSString *)serializedActionParametersStringWithActionParameters:(NSArray *)actionParameters
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
                    [parametersString appendString:[actionParameter URLEncodedString]];
                }
            }
        }
    }
    
    return [parametersString copy];
}

#pragma mark -

+ (NSString *)serializedPurchaseStringWithPurchase:(NUPurchase *)purchase
{
    NSMutableString *parametersString = [NSMutableString stringWithString:@""];
    
    [parametersString appendFormat:@"%g", purchase.totalAmount];
    NSString *itemsString = [self serializedPurchaseItemsStringWithItems:purchase.items];
    [parametersString appendFormat:@",%@", itemsString];
    
    if (purchase.details) {
        NSString *serializedDetails = [self serializedPurchaseDetailsStringWithDetails:purchase.details];
        [parametersString appendFormat:@",%@", serializedDetails];
    }
    
    return [parametersString copy];
}

+ (NSString *)serializedPurchaseItemsStringWithItems:(NSArray *)items
{
    NSMutableString *itemsString = [NSMutableString stringWithString:@""];
    
    for (int i=0; i<items.count; i++) {
        NUPurchaseItem *item = items[i];
        if (i > 0) {
            [itemsString appendString:@","];
        }
        
        NSString *serializedItem = [self serializedPurchaseItemStringWithItem:item];
        [itemsString appendString:serializedItem];
    }
    
    return [itemsString copy];
}

+ (NSString *)serializedPurchaseItemStringWithItem:(NUPurchaseItem *)item
{
    NSMutableString *itemString = [NSMutableString stringWithString:@""];
    [itemString appendFormat:@"%@=", [item.name URLEncodedString]];
    
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    if ([NUObjectPropertyStatusUtils isStringValueSet:item.SKU]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"SKU:%@", [item.SKU URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:item.category]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"category:%@", [item.category URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:item.itemDescription]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"description:%@", [item.itemDescription URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:item.price]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"price:%g", item.price]];
    }
    if ([NUObjectPropertyStatusUtils isUnsignedIntegerValueSet:item.quantity]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"quantity:%ld", (unsigned long)item.quantity]];
    }
    
    [itemString appendString:[keyValuePairs componentsJoinedByString:@";"]];
    
    return [itemString copy];
}

+ (NSString *)serializedPurchaseDetailsStringWithDetails:(NUPurchaseDetails *)purchaseDetails
{
    NSMutableString *itemString = [NSMutableString stringWithString:@"_="];
    
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:purchaseDetails.discount]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"discount:%g", purchaseDetails.discount]];
    }
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:purchaseDetails.shipping]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"shipping:%g", purchaseDetails.shipping]];
    }
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:purchaseDetails.tax]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"tax:%g", purchaseDetails.tax]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.currency]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"currency:%@", [purchaseDetails.currency URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.paymentMethod]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"method:%@", [purchaseDetails.paymentMethod URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.affiliation]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"affiliation:%@", [purchaseDetails.affiliation URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.state]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"state:%@", [purchaseDetails.state URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.city]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"city:%@", [purchaseDetails.city URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.zip]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"zip:%@", [purchaseDetails.zip URLEncodedString]]];
    }
    [keyValuePairs addObject:[NSString stringWithFormat:@"incomplete:%@", purchaseDetails.incomplete ? @"1" : @"0"]];
    
    [itemString appendString:[keyValuePairs componentsJoinedByString:@";"]];
    
    return [itemString copy];
}

@end
