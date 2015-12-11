//
//  NUPurchase.m
//  NextUserKit
//
//  Created by Dino on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUPurchase+Serialization.h"
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
    [itemString appendFormat:@"%@=", [item.productName URLEncodedString]];
    
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
