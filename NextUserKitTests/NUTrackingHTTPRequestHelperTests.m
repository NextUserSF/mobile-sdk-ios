//
//  NUTrackingHTTPRequestHelperTests.m
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NextUserKit/NextUserKit.h>
#import "NUTrackingHTTPRequestHelper.h"
#import "NUTrackingHTTPRequestHelper+Tests.h"
#import "NSString+LGUtils.h"

@interface NUTrackingHTTPRequestHelperTests : XCTestCase

@end

@implementation NUTrackingHTTPRequestHelperTests

#pragma mark -

- (void)testAPIPathGeneration
{
    NSString *APIName = @"testAPIName";
    NSString *generatedAPIPath = [NUTrackingHTTPRequestHelper pathWithAPIName:APIName];
    
    XCTAssert([generatedAPIPath containsString:APIName]);
}

- (void)testBaseURL
{
    NSString *basePath = [NUTrackingHTTPRequestHelper basePath];
    NSString *generatedAPIPath = [NUTrackingHTTPRequestHelper pathWithAPIName:@"randomAPIName"];
    
    NSRange range = [generatedAPIPath rangeOfString:basePath];
    
    // test that base path is at the beginning of the generated path
    XCTAssert(range.location == 0 && range.length == basePath.length);
}

#pragma mark - Action Serialization

- (void)testActionSerializationWithoutParameters
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name"]);
}

- (void)testActionSerializationFromAllNullParameters
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name"]);
}

- (void)testActionSerializationFromOneNonNullParameterAtFirstIndex
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.firstParameter = @"1_value";
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,1_value"]);
}

- (void)testActionSerializationFromOneNonNullParamterAtSecondIndex
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.secondParameter = @"2_value";
    
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,,2_value"]);
}

- (void)testActionSerializationFromOneNonNullParameterAtThirdIndex
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.thirdParameter = @"3_value";
    
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,,,3_value"]);
}

- (void)testActionSerializationWithNullAndNonNullParameters
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.secondParameter = @"2_value";
    action.ninthParameter = @"9_value";
    
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,,2_value,,,,,,,9_value"]);
}

- (void)testActionSerializationWithSpacesInParameters
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.secondParameter = @"2_value";
    action.ninthParameter = @"9 value";
    
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,,2_value,,,,,,,9%20value"]);
}

- (void)testActionSerializationWithSpacesInActionNameAndParameters
{
    NUAction *action = [NUAction actionWithName:@"this is action name"];
    action.secondParameter = @"2 value";
    action.ninthParameter = @"9 value";
    
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert([actionParametersString isEqualToString:@"this%20is%20action%20name,,2%20value,,,,,,,9%20value"]);
}

- (void)testActionSerializationWithNilActionName
{
    NUAction *action = [NUAction actionWithName:nil];
    action.secondParameter = @"2_value";
    action.ninthParameter = @"9_value";
    
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper serializedActionStringFromAction:action];
    
    XCTAssert(actionParametersString == nil);
}

#pragma mark - Purchase Serialization

#pragma mark - Product

//  "product_name=SKU:product_SKU;category:product_category_value;price:98.56;quantity:3;description:This is a product description";
- (void)testProductSerializationWithAllProperties
{
    NSString *name = @"Lord Of The Rings";
    NSString *SKU = @"2342342223";
    NSString *category = @"books";
    NSString *productDescription = @"This is a product description";
    double price = 98.56;
    double quantity = 3;
    
    NUProduct *product = [NUProduct productWithName:name];
    product.SKU = SKU;
    product.category = category;
    product.productDescription = productDescription;
    product.price = price;
    product.quantity = quantity;
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedProductStringWithProduct:product];
    
    NSString *prefix = [NSString stringWithFormat:@"%@=", [name URLEncodedString]];
    XCTAssert([generatedString hasPrefix:prefix]);
    
    NSString *SKUParameter = [NSString stringWithFormat:@"SKU:%@", [SKU URLEncodedString]];
    XCTAssert([generatedString rangeOfString:SKUParameter].location != NSNotFound);
    
    NSString *categoryParameter = [NSString stringWithFormat:@"category:%@", [category URLEncodedString]];
    XCTAssert([generatedString rangeOfString:categoryParameter].location != NSNotFound);
    
    NSString *productDescriptionParameter = [NSString stringWithFormat:@"description:%@", [productDescription URLEncodedString]];
    XCTAssert([generatedString rangeOfString:productDescriptionParameter].location != NSNotFound);
    
    NSString *priceParameter = [NSString stringWithFormat:@"price:%@", @(price)];
    XCTAssert([generatedString rangeOfString:priceParameter].location != NSNotFound);
    
    NSString *quantityParameter = [NSString stringWithFormat:@"quantity:%@", @(quantity)];
    XCTAssert([generatedString rangeOfString:quantityParameter].location != NSNotFound);
}

- (void)testProductSerializationWithMissingStringProperty
{
    NSString *name = @"Lord Of The Rings";
    NSString *SKU = @"2342342223";
    NSString *category = @"books";
    NSString *productDescription = @"This is a product description";
    double price = 98.56;
    double quantity = 3;
    
    NUProduct *product = [NUProduct productWithName:name];
    product.SKU = SKU;
    product.category = category;
    //    product.productDescription = productDescription;
    product.price = price;
    product.quantity = quantity;
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedProductStringWithProduct:product];
    
    NSString *prefix = [NSString stringWithFormat:@"%@=", [name URLEncodedString]];
    XCTAssert([generatedString hasPrefix:prefix]);
    
    NSString *SKUParameter = [NSString stringWithFormat:@"SKU:%@", [SKU URLEncodedString]];
    XCTAssert([generatedString rangeOfString:SKUParameter].location != NSNotFound);
    
    NSString *categoryParameter = [NSString stringWithFormat:@"category:%@", [category URLEncodedString]];
    XCTAssert([generatedString rangeOfString:categoryParameter].location != NSNotFound);
    
    NSString *productDescriptionParameter = [NSString stringWithFormat:@"description:%@", [productDescription URLEncodedString]];
    XCTAssert([generatedString rangeOfString:productDescriptionParameter].location == NSNotFound);
    
    NSString *priceParameter = [NSString stringWithFormat:@"price:%@", @(price)];
    XCTAssert([generatedString rangeOfString:priceParameter].location != NSNotFound);
    
    NSString *quantityParameter = [NSString stringWithFormat:@"quantity:%@", @(quantity)];
    XCTAssert([generatedString rangeOfString:quantityParameter].location != NSNotFound);
}

- (void)testProductSerializationWithMissingDoubleProperty
{
    NSString *name = @"Lord Of The Rings";
    NSString *SKU = @"2342342223";
    NSString *category = @"books";
    NSString *productDescription = @"This is a product description";
    double price = 98.56;
    double quantity = 3;
    
    NUProduct *product = [NUProduct productWithName:name];
    product.SKU = SKU;
    product.category = category;
    product.productDescription = productDescription;
    //    product.price = price;
    product.quantity = quantity;
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedProductStringWithProduct:product];
    
    NSString *prefix = [NSString stringWithFormat:@"%@=", [name URLEncodedString]];
    XCTAssert([generatedString hasPrefix:prefix]);
    
    NSString *SKUParameter = [NSString stringWithFormat:@"SKU:%@", [SKU URLEncodedString]];
    XCTAssert([generatedString rangeOfString:SKUParameter].location != NSNotFound);
    
    NSString *categoryParameter = [NSString stringWithFormat:@"category:%@", [category URLEncodedString]];
    XCTAssert([generatedString rangeOfString:categoryParameter].location != NSNotFound);
    
    NSString *productDescriptionParameter = [NSString stringWithFormat:@"description:%@", [productDescription URLEncodedString]];
    XCTAssert([generatedString rangeOfString:productDescriptionParameter].location != NSNotFound);
    
    NSString *priceParameter = [NSString stringWithFormat:@"price:%@", @(price)];
    XCTAssert([generatedString rangeOfString:priceParameter].location == NSNotFound);
    
    NSString *quantityParameter = [NSString stringWithFormat:@"quantity:%@", @(quantity)];
    XCTAssert([generatedString rangeOfString:quantityParameter].location != NSNotFound);
}

- (void)testProductSerializationWithQuantityNotSet
{
    NSString *name = @"Lord Of The Rings";
    NSString *SKU = @"2342342223";
    NSString *category = @"books";
    NSString *productDescription = @"This is a product description";
    double price = 98.56;
    //    double quantity = 3;
    
    NUProduct *product = [NUProduct productWithName:name];
    product.SKU = SKU;
    product.category = category;
    product.productDescription = productDescription;
    product.price = price;
    //    product.quantity = quantity; <-- defaults to 1 if not set
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedProductStringWithProduct:product];
    
    NSString *prefix = [NSString stringWithFormat:@"%@=", [name URLEncodedString]];
    XCTAssert([generatedString hasPrefix:prefix]);
    
    NSString *SKUParameter = [NSString stringWithFormat:@"SKU:%@", [SKU URLEncodedString]];
    XCTAssert([generatedString rangeOfString:SKUParameter].location != NSNotFound);
    
    NSString *categoryParameter = [NSString stringWithFormat:@"category:%@", [category URLEncodedString]];
    XCTAssert([generatedString rangeOfString:categoryParameter].location != NSNotFound);
    
    NSString *productDescriptionParameter = [NSString stringWithFormat:@"description:%@", [productDescription URLEncodedString]];
    XCTAssert([generatedString rangeOfString:productDescriptionParameter].location != NSNotFound);
    
    NSString *priceParameter = [NSString stringWithFormat:@"price:%@", @(price)];
    XCTAssert([generatedString rangeOfString:priceParameter].location != NSNotFound);
    
    NSString *quantityParameter = [NSString stringWithFormat:@"quantity:%@", @(1)];
    XCTAssert([generatedString rangeOfString:quantityParameter].location != NSNotFound);
}

#pragma mark -

- (void)testProductsSerialization
{
    NUProduct *product1 = [NUProduct productWithName:@"Lord Of The Rings"];
    product1.SKU = @"234523333344";
    product1.category = @"Science Fiction";
    product1.productDescription = @"A long book about rings";
    product1.price = 99.23;
    product1.quantity = 7;
    
    NUProduct *product2 = [NUProduct productWithName:@"Game Of Thrones"];
    product2.SKU = @"25678675874";
    product2.category = @"Science Fiction";
    product2.productDescription = @"A long book about dragons";
    product2.price = 77.23;
    product2.quantity = 6;
    
    NSString *serializedProducts = [NUTrackingHTTPRequestHelper serializedProductsStringWithProducts:@[product1, product2]];
    
    NSString *serializedProduct1 = [NUTrackingHTTPRequestHelper serializedProductStringWithProduct:product1];
    NSString *serializedProduct2 = [NUTrackingHTTPRequestHelper serializedProductStringWithProduct:product2];
    
    NSString *expectedString = [NSString stringWithFormat:@"%@,%@", serializedProduct1, serializedProduct2];
    XCTAssert([serializedProducts isEqualToString:expectedString]);
}

#pragma mark - Purchase Details

- (void)testPurchaseDetailsSerializationWithAllProperties
{
    double discount = 38.36;
    double shipping = 15.56;
    double tax = 3.87;
    BOOL incomplete = YES;
    NSString *currency = @"$";
    NSString *paymentMethod = @"MasterCard";
    NSString *affiliation = @"Don't know about this";
    NSString *state = @"Croatia";
    NSString *city = @"Pozega";
    NSString *zip = @"34000";
    
    NUPurchaseDetails *details = [NUPurchaseDetails details];
    details.discount = discount;
    details.shipping = shipping;
    details.tax = tax;
    details.currency = currency;
    details.incomplete = incomplete;
    details.paymentMethod = paymentMethod;
    details.affiliation = affiliation;
    details.state = state;
    details.city = city;
    details.zip = zip;
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedPurchaseDetailsStringWithDetails:details];
    
    NSString *prefix = @"_=";
    XCTAssert([generatedString hasPrefix:prefix]);
    
    NSString *currencyParameter = [NSString stringWithFormat:@"currency:%@", [currency URLEncodedString]];
    XCTAssert([generatedString rangeOfString:currencyParameter].location != NSNotFound);
    
    NSString *paymentMethodParameter = [NSString stringWithFormat:@"method:%@", [paymentMethod URLEncodedString]];
    XCTAssert([generatedString rangeOfString:paymentMethodParameter].location != NSNotFound);
    
    NSString *affiliationParameter = [NSString stringWithFormat:@"affiliation:%@", [affiliation URLEncodedString]];
    XCTAssert([generatedString rangeOfString:affiliationParameter].location != NSNotFound);
    
    NSString *stateParameter = [NSString stringWithFormat:@"state:%@", [state URLEncodedString]];
    XCTAssert([generatedString rangeOfString:stateParameter].location != NSNotFound);
    
    NSString *cityParameter = [NSString stringWithFormat:@"city:%@", [city URLEncodedString]];
    XCTAssert([generatedString rangeOfString:cityParameter].location != NSNotFound);
    
    NSString *zipParameter = [NSString stringWithFormat:@"zip:%@", [zip URLEncodedString]];
    XCTAssert([generatedString rangeOfString:zipParameter].location != NSNotFound);
    
    NSString *discountParameter = [NSString stringWithFormat:@"discount:%@", @(discount)];
    XCTAssert([generatedString rangeOfString:discountParameter].location != NSNotFound);
    
    NSString *shippingParameter = [NSString stringWithFormat:@"shipping:%@", @(shipping)];
    XCTAssert([generatedString rangeOfString:shippingParameter].location != NSNotFound);
    
    NSString *taxgParameter = [NSString stringWithFormat:@"tax:%@", @(tax)];
    XCTAssert([generatedString rangeOfString:taxgParameter].location != NSNotFound);
    
    NSString *incompleteParameter = @"incomplete:1";
    XCTAssert([generatedString rangeOfString:incompleteParameter].location != NSNotFound);
}

- (void)testPurchaseDetailsSerializationWithMissingStringProperty
{
    double discount = 38.36;
    double shipping = 15.56;
    double tax = 3.87;
    BOOL incomplete = YES;
    NSString *currency = @"$";
    NSString *paymentMethod = @"MasterCard";
    NSString *affiliation = @"Don't know about this";
    NSString *state = @"Croatia";
    NSString *city = @"Pozega";
    NSString *zip = @"34000";
    
    NUPurchaseDetails *details = [NUPurchaseDetails details];
    details.discount = discount;
    details.shipping = shipping;
    details.tax = tax;
    details.currency = currency;
    details.incomplete = incomplete;
    details.paymentMethod = paymentMethod;
    details.affiliation = affiliation;
//    details.state = state;
    details.city = city;
    details.zip = zip;
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedPurchaseDetailsStringWithDetails:details];
    
    NSString *prefix = @"_=";
    XCTAssert([generatedString hasPrefix:prefix]);
    
    NSString *currencyParameter = [NSString stringWithFormat:@"currency:%@", [currency URLEncodedString]];
    XCTAssert([generatedString rangeOfString:currencyParameter].location != NSNotFound);
    
    NSString *paymentMethodParameter = [NSString stringWithFormat:@"method:%@", [paymentMethod URLEncodedString]];
    XCTAssert([generatedString rangeOfString:paymentMethodParameter].location != NSNotFound);
    
    NSString *affiliationParameter = [NSString stringWithFormat:@"affiliation:%@", [affiliation URLEncodedString]];
    XCTAssert([generatedString rangeOfString:affiliationParameter].location != NSNotFound);
    
    NSString *stateParameter = [NSString stringWithFormat:@"state:%@", [state URLEncodedString]];
    XCTAssert([generatedString rangeOfString:stateParameter].location == NSNotFound);
    
    NSString *cityParameter = [NSString stringWithFormat:@"city:%@", [city URLEncodedString]];
    XCTAssert([generatedString rangeOfString:cityParameter].location != NSNotFound);
    
    NSString *zipParameter = [NSString stringWithFormat:@"zip:%@", [zip URLEncodedString]];
    XCTAssert([generatedString rangeOfString:zipParameter].location != NSNotFound);
    
    NSString *discountParameter = [NSString stringWithFormat:@"discount:%@", @(discount)];
    XCTAssert([generatedString rangeOfString:discountParameter].location != NSNotFound);
    
    NSString *shippingParameter = [NSString stringWithFormat:@"shipping:%@", @(shipping)];
    XCTAssert([generatedString rangeOfString:shippingParameter].location != NSNotFound);
    
    NSString *taxgParameter = [NSString stringWithFormat:@"tax:%@", @(tax)];
    XCTAssert([generatedString rangeOfString:taxgParameter].location != NSNotFound);
    
    NSString *incompleteParameter = @"incomplete:1";
    XCTAssert([generatedString rangeOfString:incompleteParameter].location != NSNotFound);
}

- (void)testPurchaseDetailsSerializationWithMissingDoubleProperty
{
    double discount = 38.36;
    double shipping = 15.56;
    double tax = 3.87;
    BOOL incomplete = YES;
    NSString *currency = @"$";
    NSString *paymentMethod = @"MasterCard";
    NSString *affiliation = @"Don't know about this";
    NSString *state = @"Croatia";
    NSString *city = @"Pozega";
    NSString *zip = @"34000";
    
    NUPurchaseDetails *details = [NUPurchaseDetails details];
    details.discount = discount;
//    details.shipping = shipping;
    details.tax = tax;
    details.currency = currency;
    details.incomplete = incomplete;
    details.paymentMethod = paymentMethod;
    details.affiliation = affiliation;
    details.state = state;
    details.city = city;
    details.zip = zip;
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedPurchaseDetailsStringWithDetails:details];
    
    NSString *prefix = @"_=";
    XCTAssert([generatedString hasPrefix:prefix]);
    
    NSString *currencyParameter = [NSString stringWithFormat:@"currency:%@", [currency URLEncodedString]];
    XCTAssert([generatedString rangeOfString:currencyParameter].location != NSNotFound);
    
    NSString *paymentMethodParameter = [NSString stringWithFormat:@"method:%@", [paymentMethod URLEncodedString]];
    XCTAssert([generatedString rangeOfString:paymentMethodParameter].location != NSNotFound);
    
    NSString *affiliationParameter = [NSString stringWithFormat:@"affiliation:%@", [affiliation URLEncodedString]];
    XCTAssert([generatedString rangeOfString:affiliationParameter].location != NSNotFound);
    
    NSString *stateParameter = [NSString stringWithFormat:@"state:%@", [state URLEncodedString]];
    XCTAssert([generatedString rangeOfString:stateParameter].location != NSNotFound);
    
    NSString *cityParameter = [NSString stringWithFormat:@"city:%@", [city URLEncodedString]];
    XCTAssert([generatedString rangeOfString:cityParameter].location != NSNotFound);
    
    NSString *zipParameter = [NSString stringWithFormat:@"zip:%@", [zip URLEncodedString]];
    XCTAssert([generatedString rangeOfString:zipParameter].location != NSNotFound);
    
    NSString *discountParameter = [NSString stringWithFormat:@"discount:%@", @(discount)];
    XCTAssert([generatedString rangeOfString:discountParameter].location != NSNotFound);
    
    NSString *shippingParameter = [NSString stringWithFormat:@"shipping:%@", @(shipping)];
    XCTAssert([generatedString rangeOfString:shippingParameter].location == NSNotFound);
    
    NSString *taxParameter = [NSString stringWithFormat:@"tax:%@", @(tax)];
    XCTAssert([generatedString rangeOfString:taxParameter].location != NSNotFound);
    
    NSString *incompleteParameter = @"incomplete:1";
    XCTAssert([generatedString rangeOfString:incompleteParameter].location != NSNotFound);
}

#pragma mark -

- (void)testPurchaseParametersSerializationWithDetails
{
    double amount = 45.65;
    
    NUProduct *product1 = [NUProduct productWithName:@"Lord Of The Rings"];
    product1.SKU = @"234523333344";
    product1.category = @"Science Fiction";
    product1.productDescription = @"A long book about rings";
    product1.price = 99.23;
    product1.quantity = 7;
    
    NUProduct *product2 = [NUProduct productWithName:@"Game Of Thrones"];
    product2.SKU = @"25678675874";
    product2.category = @"Science Fiction";
    product2.productDescription = @"A long book about dragons";
    product2.price = 77.23;
    product2.quantity = 6;
    
    double discount = 38.36;
    double shipping = 15.56;
    double tax = 3.87;
    BOOL incomplete = YES;
    NSString *currency = @"$";
    NSString *paymentMethod = @"MasterCard";
    NSString *affiliation = @"Don't know about this";
    NSString *state = @"Croatia";
    NSString *city = @"Pozega";
    NSString *zip = @"34000";
    
    NUPurchaseDetails *details = [NUPurchaseDetails details];
    details.discount = discount;
    details.shipping = shipping;
    details.tax = tax;
    details.currency = currency;
    details.incomplete = incomplete;
    details.paymentMethod = paymentMethod;
    details.affiliation = affiliation;
    details.state = state;
    details.city = city;
    details.zip = zip;
    
    NUPurchase *purchase = [NUPurchase purchase];
    purchase.totalAmount = amount;
    purchase.products = @[product1, product2];
    purchase.details = details;
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedPurchaseStringWithPurchase:purchase];
    
    NSString *prefix = [NSString stringWithFormat:@"%@,", @(amount)];
    XCTAssert([generatedString hasPrefix:prefix]);
    
    XCTAssert([generatedString rangeOfString:@"_="].location != NSNotFound);
    
    NSString *serializedProducts = [NUTrackingHTTPRequestHelper serializedProductsStringWithProducts:@[product1, product2]];
    serializedProducts = [@"," stringByAppendingString:serializedProducts];
    XCTAssert([generatedString rangeOfString:serializedProducts].location != NSNotFound);
    
    NSString *serializedDetails = [NUTrackingHTTPRequestHelper serializedPurchaseDetailsStringWithDetails:details];
    XCTAssert([generatedString rangeOfString:serializedDetails].location != NSNotFound);
    
    NSString *serializedDetailsAsParameter = [@"," stringByAppendingString:serializedDetails];
    XCTAssert([generatedString rangeOfString:serializedDetailsAsParameter].location != NSNotFound);
}

- (void)testPurchaseParametersSerializationWithoutDetails
{
    double amount = 45.65;
    
    NUProduct *product1 = [NUProduct productWithName:@"Lord Of The Rings"];
    product1.SKU = @"234523333344";
    product1.category = @"Science Fiction";
    product1.productDescription = @"A long book about rings";
    product1.price = 99.23;
    product1.quantity = 7;
    
    NUProduct *product2 = [NUProduct productWithName:@"Game Of Thrones"];
    product2.SKU = @"25678675874";
    product2.category = @"Science Fiction";
    product2.productDescription = @"A long book about dragons";
    product2.price = 77.23;
    product2.quantity = 6;
    
    NUPurchase *purchase = [NUPurchase purchase];
    purchase.totalAmount = amount;
    purchase.products = @[product1, product2];
//    purchase.details = nil;
    
    NSString *generatedString = [NUTrackingHTTPRequestHelper serializedPurchaseStringWithPurchase:purchase];
    
    NSString *prefix = [NSString stringWithFormat:@"%@,", @(amount)];
    XCTAssert([generatedString hasPrefix:prefix]);
    
    XCTAssert([generatedString rangeOfString:@"_="].location == NSNotFound);
    XCTAssert([generatedString rangeOfString:@",_="].location == NSNotFound);
    
    NSString *serializedProducts = [NUTrackingHTTPRequestHelper serializedProductsStringWithProducts:@[product1, product2]];
    serializedProducts = [@"," stringByAppendingString:serializedProducts];
    XCTAssert([generatedString rangeOfString:serializedProducts].location != NSNotFound);
}

@end
