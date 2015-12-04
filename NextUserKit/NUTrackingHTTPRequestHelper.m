//
//  NUTrackingHTTPRequestHelper.m
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackingHTTPRequestHelper.h"
#import "NUProduct.h"
#import "NUPurchaseDetails.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"

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

#pragma mark - Track Action

+ (NSString *)trackActionURLEntryWithName:(NSString *)actionName parameters:(NSArray *)actionParameters
{
    NSString *actionValue = [actionName URLEncodedString];
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
                    [parametersString appendString:[actionParameter URLEncodedString]];
                }
            }
        }
    }
    
    return [parametersString copy];
}

#pragma mark - Track Purchase

+ (NSString *)trackPurchaseParametersStringWithTotalAmount:(double)totalAmount products:(NSArray *)products purchaseDetails:(NUPurchaseDetails *)purchaseDetails
{
    NSMutableString *parametersString = [NSMutableString stringWithString:@""];
    
    [parametersString appendFormat:@"%g", totalAmount];
    NSString *productsString = [self serializedProducts:products];
    [parametersString appendFormat:@",%@", productsString];
    
    if (purchaseDetails) {
        NSString *serializedDetails = [self serializedPurchaseDetails:purchaseDetails];
        [parametersString appendFormat:@",%@", serializedDetails];
    }
    
    return [parametersString copy];
}

+ (NSString *)serializedProducts:(NSArray *)products
{
    NSMutableString *productsString = [NSMutableString stringWithString:@""];
    
    for (int i=0; i<products.count; i++) {
        NUProduct *product = products[i];
        if (i > 0) {
            [productsString appendString:@","];
        }
        
        NSString *serializedProduct = [self serializedProduct:product];
        [productsString appendString:serializedProduct];
    }
    
    return [productsString copy];
}

+ (NSString *)serializedProduct:(NUProduct *)product
{
    NSMutableString *productString = [NSMutableString stringWithString:@""];
    [productString appendFormat:@"%@=", [product.name URLEncodedString]];
    
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    if ([NUObjectPropertyStatusUtils isStringValueSet:product.SKU]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"SKU:%@", [product.SKU URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:product.category]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"category:%@", [product.category URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:product.productDescription]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"description:%@", [product.productDescription URLEncodedString]]];
    }
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:product.price]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"price:%g", product.price]];
    }
    if ([NUObjectPropertyStatusUtils isUnsignedIntegerValueSet:product.quantity]) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"quantity:%ld", (unsigned long)product.quantity]];
    }
    
    [productString appendString:[keyValuePairs componentsJoinedByString:@";"]];
    
    return [productString copy];
}

+ (NSString *)serializedPurchaseDetails:(NUPurchaseDetails *)purchaseDetails
{
    NSMutableString *productString = [NSMutableString stringWithString:@"_="];
    
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
    
    [productString appendString:[keyValuePairs componentsJoinedByString:@";"]];
    
    return [productString copy];
}

@end
