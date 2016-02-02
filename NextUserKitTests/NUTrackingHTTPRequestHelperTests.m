//
//  NUTrackingHTTPRequestHelperTests.m
//  NextUserKit
//
//  Created by NextUser on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NextUserKit/NextUserKit.h>
#import "NUTrackingHTTPRequestHelper.h"
#import "NUAction+Serialization.h"
#import "NUPurchase+Serialization.h"
#import "NSString+LGUtils.h"
#import "NUPurchase+Tests.h"

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
    NSString *actionParametersString = [action httpRequestParameterRepresentation];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name"]);
}

- (void)testActionSerializationFromOneNonNullParameterAtFirstIndex
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.firstParameter = @"1_value";
    NSString *actionParametersString = [action httpRequestParameterRepresentation];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,1_value"]);
}

- (void)testActionSerializationFromOneNonNullParamterAtSecondIndex
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.secondParameter = @"2_value";
    
    NSString *actionParametersString = [action httpRequestParameterRepresentation];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,,2_value"]);
}

- (void)testActionSerializationFromOneNonNullParameterAtThirdIndex
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.thirdParameter = @"3_value";
    
    NSString *actionParametersString = [action httpRequestParameterRepresentation];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,,,3_value"]);
}

- (void)testActionSerializationWithNullAndNonNullParameters
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.secondParameter = @"2_value";
    action.thirdParameter = nil; // defaults to nil anyway
    action.ninthParameter = @"9_value";
    
    NSString *actionParametersString = [action httpRequestParameterRepresentation];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,,2_value,,,,,,,9_value"]);
}

- (void)testActionSerializationWithSpacesInParameters
{
    NUAction *action = [NUAction actionWithName:@"action_name"];
    action.secondParameter = @"2_value";
    action.ninthParameter = @"9 value";
    
    NSString *actionParametersString = [action httpRequestParameterRepresentation];
    
    XCTAssert([actionParametersString isEqualToString:@"action_name,,2_value,,,,,,,9%20value"]);
}

- (void)testActionSerializationWithSpacesInActionNameAndParameters
{
    NUAction *action = [NUAction actionWithName:@"this is action name"];
    action.secondParameter = @"2 value";
    action.ninthParameter = @"9 value";
    
    NSString *actionParametersString = [action httpRequestParameterRepresentation];
    
    XCTAssert([actionParametersString isEqualToString:@"this%20is%20action%20name,,2%20value,,,,,,,9%20value"]);
}

- (void)testActionSerializationWithNilActionName
{
    XCTAssertThrows([NUAction actionWithName:nil]);
}

#pragma mark - Purchase Serialization

#pragma mark - Purchase Item

- (void)testPurchaseItemSerializationWithAllProperties
{
    NUPurchaseItem *item = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings" SKU:@"2342342223"];
    item.category = @"books";
    item.price = 98.56;
    item.quantity = 2;
    item.productDescription = @"This is a product description";
    
    NSString *generatedString = [NUPurchase serializedPurchaseItemStringWithItem:item];
    NSString *expectedString = @"Lord Of The Rings=SKU:2342342223;category:books;price:98_dot_56;quantity:2;description:This is a product description";
    
    XCTAssert([generatedString isEqualToString:expectedString]);
}

- (void)testPurchaseItemSerializationWithMissingStringProperty
{
    NUPurchaseItem *item = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings" SKU:@"2342342223"];
    item.category = @"books";
    item.price = 98.56;
    
    NSString *generatedString = [NUPurchase serializedPurchaseItemStringWithItem:item];
    NSString *expectedString = @"Lord Of The Rings=SKU:2342342223;category:books;price:98_dot_56;quantity:1";
    
    XCTAssert([generatedString isEqualToString:expectedString]);
}

- (void)testPurchaseItemSerializationWithMissingDoubleProperty
{
    NUPurchaseItem *item = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings" SKU:@"2342342223"];
    item.category = @"books";
    item.quantity = 3;
    item.productDescription = @"This is a product description";
    
    NSString *generatedString = [NUPurchase serializedPurchaseItemStringWithItem:item];
    NSString *expectedString = @"Lord Of The Rings=SKU:2342342223;category:books;quantity:3;description:This is a product description";
    
    XCTAssert([generatedString isEqualToString:expectedString]);
}

- (void)testPurchaseItemSerializationWithQuantityNotSet
{
    NUPurchaseItem *item = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings" SKU:@"2342342223"];
    item.category = @"books";
    item.productDescription = @"This is a product description";
    item.price = 98.56;
    
    NSString *generatedString = [NUPurchase serializedPurchaseItemStringWithItem:item];
    NSString *expectedString = @"Lord Of The Rings=SKU:2342342223;category:books;price:98_dot_56;quantity:1;description:This is a product description";
    
    XCTAssert([generatedString isEqualToString:expectedString]);
}

#pragma mark -

- (void)testPurchaseItemsSerialization
{
    NUPurchaseItem *item1 = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings" SKU:@"234523333344"];
    item1.category = @"Science Fiction";
    item1.productDescription = @"A long book about rings";
    item1.price = 99.23;
    item1.quantity = 7;
    
    NUPurchaseItem *item2 = [NUPurchaseItem itemWithProductName:@"Game Of Thrones" SKU:@"25678675874"];
    item2.category = @"Science Fiction";
    item2.productDescription = @"A long book about dragons";
    item2.price = 77.23;
    item2.quantity = 6;
    
    NSString *serializedItems = [NUPurchase serializedPurchaseItemsStringWithItems:@[item1, item2]];
    
    NSString *serializedItem1 = [NUPurchase serializedPurchaseItemStringWithItem:item1];
    NSString *serializedItem2 = [NUPurchase serializedPurchaseItemStringWithItem:item2];
    
    NSString *expectedString = [NSString stringWithFormat:@"%@,%@", serializedItem1, serializedItem2];
    XCTAssert([serializedItems isEqualToString:expectedString]);
}

#pragma mark - Purchase Details

- (void)testPurchaseDetailsSerializationWithAllProperties
{
    NUPurchaseDetails *details = [NUPurchaseDetails details];
    details.discount = 38.36;
    details.shipping = 15.56;
    details.tax = 3.87;
    details.currency = @"$";
    details.incomplete = YES;
    details.paymentMethod = @"MasterCard";
    details.affiliation = @"Don't know about this";
    details.state = @"Croatia";
    details.city = @"Pozega";
    details.zip = @"34000";
    
    NSString *generatedString = [NUPurchase serializedPurchaseDetailsStringWithDetails:details];
    NSString *expectedString = @"_=discount:38_dot_36;shipping:15_dot_56;tax:3_dot_87;currency:$;incomplete:1;method:MasterCard;affiliation:Don't know about this;state:Croatia;city:Pozega;zip:34000";
    
    XCTAssert([generatedString isEqualToString:expectedString]);
}

- (void)testPurchaseDetailsSerializationWithMissingStringProperty
{
    // state missing
    NUPurchaseDetails *details = [NUPurchaseDetails details];
    details.discount = 38.36;
    details.shipping = 15.56;
    details.tax = 3.87;
    details.currency = @"$";
    details.incomplete = YES;
    details.paymentMethod = @"MasterCard";
    details.affiliation = @"Don't know about this";
    details.city = @"Pozega";
    details.zip = @"34000";
    
    NSString *generatedString = [NUPurchase serializedPurchaseDetailsStringWithDetails:details];
    NSString *expectedString = @"_=discount:38_dot_36;shipping:15_dot_56;tax:3_dot_87;currency:$;incomplete:1;method:MasterCard;affiliation:Don't know about this;city:Pozega;zip:34000";
    
    XCTAssert([generatedString isEqualToString:expectedString]);
}

- (void)testPurchaseDetailsSerializationWithMissingDoubleProperty
{
    // shipping missing
    NUPurchaseDetails *details = [NUPurchaseDetails details];
    details.discount = 38.36;
    details.tax = 3.87;
    details.currency = @"$";
    details.incomplete = YES;
    details.paymentMethod = @"MasterCard";
    details.affiliation = @"Don't know about this";
    details.state = @"Croatia";
    details.city = @"Pozega";
    details.zip = @"34000";
    
    NSString *generatedString = [NUPurchase serializedPurchaseDetailsStringWithDetails:details];
    NSString *expectedString = @"_=discount:38_dot_36;tax:3_dot_87;currency:$;incomplete:1;method:MasterCard;affiliation:Don't know about this;state:Croatia;city:Pozega;zip:34000";
    
    XCTAssert([generatedString isEqualToString:expectedString]);
}

#pragma mark - Purchase

- (void)testPurchaseParametersSerializationWithDetails
{
    double amount = 45.65;
    
    NUPurchaseItem *item1 = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings" SKU:@"234523333344"];
    item1.category = @"Science Fiction";
    item1.productDescription = @"A long book about rings";
    item1.price = 99.23;
    item1.quantity = 7;
    
    NUPurchaseItem *item2 = [NUPurchaseItem itemWithProductName:@"Game Of Thrones" SKU:@"25678675874"];
    item2.category = @"Science Fiction";
    item2.productDescription = @"A long book about dragons";
    item2.price = 77.23;
    item2.quantity = 6;
    
    NUPurchaseDetails *details = [NUPurchaseDetails details];
    details.discount = 38.36;
    details.shipping = 15.56;
    details.tax = 3.87;
    details.currency = @"$";
    details.incomplete = YES;
    details.paymentMethod = @"MasterCard";
    details.affiliation = @"Don't know about this";
    details.state = @"Croatia";
    details.city = @"Pozega";
    details.zip = @"34000";
    
    NUPurchase *purchase = [NUPurchase purchaseWithTotalAmount:amount items:@[item1, item2] details:details];
    
    NSString *generatedString = [purchase httpRequestParameterRepresentation];
    NSString *expectedString = @"45.65,Lord Of The Rings=SKU:234523333344;category:Science Fiction;price:99_dot_23;quantity:7;description:A long book about rings,Game Of Thrones=SKU:25678675874;category:Science Fiction;price:77_dot_23;quantity:6;description:A long book about dragons,_=discount:38_dot_36;shipping:15_dot_56;tax:3_dot_87;currency:$;incomplete:1;method:MasterCard;affiliation:Don't know about this;state:Croatia;city:Pozega;zip:34000";

    XCTAssert([generatedString isEqualToString:expectedString]);
}

- (void)testPurchaseParametersSerializationWithoutDetails
{
    double amount = 45.65;
    
    NUPurchaseItem *item1 = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings" SKU:@"234523333344"];
    item1.category = @"Science Fiction";
    item1.productDescription = @"A long book about rings";
    item1.price = 99.23;
    item1.quantity = 7;
    
    NUPurchaseItem *item2 = [NUPurchaseItem itemWithProductName:@"Game Of Thrones" SKU:@"25678675874"];
    item2.category = @"Science Fiction";
    item2.productDescription = @"A long book about dragons";
    item2.price = 77.23;
    item2.quantity = 6;
    
    NUPurchase *purchase = [NUPurchase purchaseWithTotalAmount:amount items:@[item1, item2]];
    
    NSString *generatedString = [purchase httpRequestParameterRepresentation];
    NSString *expectedString = @"45.65,Lord Of The Rings=SKU:234523333344;category:Science Fiction;price:99_dot_23;quantity:7;description:A long book about rings,Game Of Thrones=SKU:25678675874;category:Science Fiction;price:77_dot_23;quantity:6;description:A long book about dragons";
    
    XCTAssert([generatedString isEqualToString:expectedString]);
}

@end
