#import <Foundation/Foundation.h>
#import "NUCart.h"
#import "NUCart+Serialization.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"
#define TRACK_EVENT_ADD_TO_CART @"add_to_cart"
#define TRACK_EVENT_REMOVE_FROM_CART @"remove_from_cart"

@implementation NUCart

- (instancetype)init
{
    self = [super init];
    if (self) {
        _total = 0.0;
        _items = [[NSMutableArray<NUCartItem *> alloc] init];
    }
    
    return self;
}

-(BOOL) addOrUpdateItem:(NUCartItem *) item
{
    if (_items == nil) {
        _items = [[NSMutableArray<NUCartItem *> alloc] init];
    }
    
    if (item.quantity <= 0) {
        
        return [self removeItemForID: item.ID];
    }
    
    if ([_items containsObject:item] == NO) {
        [_items addObject:item];
        [self trackCartActionWithEvent:TRACK_EVENT_ADD_TO_CART andProductID:item.ID];
    } else {
        for (NUCartItem *next in _items) {
            if ([next isEqual:item] == YES) {
                next.quantity = item.quantity;
            }
        }
    }
    
    return YES;
}

-(BOOL) removeItemForID:(NSString *) ID
{
    if (ID == nil) {
        
        return NO;
    }
    
    if (_items != nil && [_items count] > 0) {
        NUCartItem *remove = nil;
        for (NUCartItem *next in _items) {
            if ([next.ID isEqual:ID]) {
                remove = next;
            }
        }
        if (remove != nil) {
            [_items removeObject:remove];
            [self trackCartActionWithEvent:TRACK_EVENT_REMOVE_FROM_CART andProductID:ID];
            
            return YES;
        }
    }
    
    return NO;
}

- (void) trackCartActionWithEvent:(NSString *) eventName andProductID:(NSString *) productID
{
    NUEvent *event = [NUEvent eventWithName:eventName];
    [event setFirstParameter: productID];
    [[NextUser tracker] trackEvent:event];
}


#pragma mark - Trackable

- (NSString *)httpRequestParameterRepresentation
{
    return [self.class serializedPurchaseStringWithPurchase:self];
}

#pragma mark - Serialization

+ (NSString *)serializedPurchaseStringWithPurchase:(NUCart *)cart
{
    NSMutableString *parametersString = [NSMutableString stringWithString:@""];
    
    // serialize total amount
    [parametersString appendString:[self URLParameterValueFromDouble:cart.total encodeDot:NO]];
    
    // serialize items
    NSString *itemsString = [self serializedPurchaseItemsStringWithItems:cart.items];
    [parametersString appendFormat:@",%@", itemsString];
    
    // serialize details
    if (cart.details) {
        NSString *serializedDetails = [self serializedPurchaseDetailsStringWithDetails:cart.details];
        [parametersString appendFormat:@",%@", serializedDetails];
    }
    
    return [parametersString copy];
}

+ (NSString *)serializedPurchaseItemsStringWithItems:(NSArray<NUCartItem*> *)items
{
    NSMutableString *itemsString = [NSMutableString stringWithString:@""];
    
    for (int i=0; i<items.count; i++) {
        NUCartItem *item = items[i];
        if (i > 0) {
            [itemsString appendString:@","];
        }
        
        NSString *serializedItem = [self serializedPurchaseItemStringWithItem:item];
        [itemsString appendString:serializedItem];
    }
    
    return [itemsString copy];
}

+ (NSString *)serializedPurchaseItemStringWithItem:(NUCartItem *)item
{
    NSMutableString *itemString = [NSMutableString stringWithFormat:@"%@=",
                                   [self URLParameterValueFromString:item.name]];
    
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    if ([NUObjectPropertyStatusUtils isStringValueSet:item.ID]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"SKU"
                                                           stringValue:item.ID]];
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
    if ([NUObjectPropertyStatusUtils isStringValueSet:item.desc]) {
        [keyValuePairs addObject:[self URLParameterKeyValuePairWithKey:@"description"
                                                           stringValue:item.desc]];
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
