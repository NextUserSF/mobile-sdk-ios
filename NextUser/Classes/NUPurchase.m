//
//  NUPurchase.m
//  NextUserKit
//
//  Created by NextUser on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUPurchase+Serialization.h"
#import "NUPurchaseItem.h"
#import "NUPurchaseDetails.h"
#import "NSString+LGUtils.h"
#import "NUObjectPropertyStatusUtils.h"

@interface NUPurchase ()

// redefinition to be r&w
@property (nonatomic) double totalAmount;
@property (nonatomic) NSArray *items; // array of NUPurchaseItem objects
@property (nonatomic) NUPurchaseDetails *details; // optional

@end

@implementation NUPurchase

+ (instancetype)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items
{
    return [self purchaseWithTotalAmount:totalAmount items:items details:nil];
}

+ (instancetype)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items details:(NUPurchaseDetails *)details
{
    NUPurchase *purchase = [[NUPurchase alloc] init];
    
    purchase.totalAmount = totalAmount;
    purchase.items = items;
    purchase.details = details;
    
    return purchase;
}

#pragma mark - Trackable

- (NSString *)httpRequestParameterRepresentation
{
    return [self.class serializedPurchaseStringWithPurchase:self];
}

#pragma mark - Serialization

+ (NSString *)serializedPurchaseStringWithPurchase:(NUPurchase *)purchase
{
    NSMutableString *parametersString = [NSMutableString stringWithString:@""];
    
    // serialize total amount
    [parametersString appendString:[self URLParameterValueFromDouble:purchase.totalAmount encodeDot:NO]];
    
    // serialize items
    NSString *itemsString = [self serializedPurchaseItemsStringWithItems:purchase.items];
    [parametersString appendFormat:@",%@", itemsString];
    
    // serialize details
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
    NSMutableString *itemString = [NSMutableString stringWithFormat:@"%@=",
                                   [self URLParameterValueFromString:item.productName]];
    
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    if ([NUObjectPropertyStatusUtils isStringValueSet:item.SKU]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"SKU"
                                                           stringValue:item.SKU]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:item.category]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"category"
                                                           stringValue:item.category]];
    }
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:item.price]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"price"
                                                           doubleValue:item.price]];
    }
    if ([NUObjectPropertyStatusUtils isUnsignedIntegerValueSet:item.quantity]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"quantity"
                                                  unsignedIntegerValue:item.quantity]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:item.productDescription]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"description"
                                                           stringValue:item.productDescription]];
    }
    
    [itemString appendString:[keyValuePairs componentsJoinedByString:@";"]];
    
    return [itemString copy];
}

+ (NSString *)serializedPurchaseDetailsStringWithDetails:(NUPurchaseDetails *)purchaseDetails
{
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:purchaseDetails.discount]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"discount"
                                                           doubleValue:purchaseDetails.discount]];
    }
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:purchaseDetails.shipping]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"shipping"
                                                           doubleValue:purchaseDetails.shipping]];
    }
    if ([NUObjectPropertyStatusUtils isDoubleValueSet:purchaseDetails.tax]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"tax"
                                                           doubleValue:purchaseDetails.tax]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.currency]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"currency"
                                                           stringValue:purchaseDetails.currency]];
    }
    
    [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"incomplete"
                                                         boolValue:purchaseDetails.incomplete]];
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.paymentMethod]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"method"
                                                           stringValue:purchaseDetails.paymentMethod]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.affiliation]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"affiliation"
                                                           stringValue:purchaseDetails.affiliation]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.state]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"state"
                                                           stringValue:purchaseDetails.state]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.city]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"city"
                                                           stringValue:purchaseDetails.city]];
    }
    if ([NUObjectPropertyStatusUtils isStringValueSet:purchaseDetails.zip]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"zip"
                                                           stringValue:purchaseDetails.zip]];
    }
    
    NSMutableString *itemString = [NSMutableString stringWithString:@"_="];
    [itemString appendString:[keyValuePairs componentsJoinedByString:@";"]];
    
    return [itemString copy];
}

#pragma mark - URL key-value pair Serialization

+ (NSString *)URLParameterKeyValuePairWithKey:(NSString *)key stringValue:(NSString *)value
{
    return [NSString stringWithFormat:@"%@:%@", key, [self URLParameterValueFromString:value]];
}

+ (NSString *)URLParameterKeyValuePairWithKey:(NSString *)key doubleValue:(double)value
{
    return [NSString stringWithFormat:@"%@:%@", key, [self URLParameterValueFromDouble:value encodeDot:YES]];
}

+ (NSString *)URLParameterKeyValuePairWithKey:(NSString *)key unsignedIntegerValue:(NSUInteger)value
{
    return [NSString stringWithFormat:@"%@:%@", key, [self URLParameterValueFromUnsignedInteger:value]];
}

+ (NSString *)URLParameterKeyValuePairWithKey:(NSString *)key boolValue:(BOOL)value
{
    return [NSString stringWithFormat:@"%@:%@", key, [self URLParameterValueFromBool:value]];
}

#pragma mark - Primitive Values Serialization

+ (NSString *)URLParameterValueFromString:(NSString *)parameterValue
{
    return [parameterValue URLEncodedString];
}

+ (NSString *)URLParameterValueFromDouble:(double)value encodeDot:(BOOL)encodeDot
{
    NSString *stringValue = [NSString stringWithFormat:@"%g", value];
    if (encodeDot) {
        stringValue = [stringValue stringByReplacingOccurrencesOfString:@"." withString:@"_dot_"];
    }
    
    return stringValue;
}

+ (NSString *)URLParameterValueFromUnsignedInteger:(NSUInteger)value
{
    return [NSString stringWithFormat:@"%ld", (unsigned long)value];
}

+ (NSString *)URLParameterValueFromBool:(BOOL)value
{
    return [NSString stringWithFormat:@"%@", value ? @"1" : @"0"];
}

@end
