//
//  NUTrackerUtilsTests.m
//  NextUserKit
//
//  Created by Dino on 11/23/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUTracker.h"
#import "NUTracker+Tests.h"
#import "NUTrackerUtils.h"

@interface NUTrackerUtilsTests : XCTestCase

@end

@implementation NUTrackerUtilsTests

- (void)setUp
{
    [super setUp];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - session setup"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker startWithCompletion:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"Start session error:  %@", error);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

#pragma mark - Screen Track

- (void)testTrackScreen
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - screen test"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [NUTrackerUtils trackScreenWithName:@"testScreenName" inSession:[tracker session] completion:^(NSError *error) {
        if (error == nil) {
            XCTAssert(YES);
        } else {
            XCTFail(@"Track screen failed with error: %@", error);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Expectation timeout - screen test. Error: %@", error);
        }
    }];
}

#pragma mark - Action Track

- (void)testTrackAction
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Action start expectation"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [NUTrackerUtils trackActionWithName:@"testActionName" parameters:nil inSession:[tracker session] completion:^(NSError *error) {
        if (error == nil) {
            XCTAssert(YES);
        } else {
            XCTFail(@"Track action failed with error: %@", error);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Expectation timeout - action test. Error: %@", error);
        }
    }];
}

#pragma mark - Multiple Actions Track

- (void)testMultipleActions
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - multiple actions"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    NSArray *actions = @[[NUTrackerUtilsTests randomActionInfo],
                         [NUTrackerUtilsTests randomActionInfo],
                         [NUTrackerUtilsTests randomActionInfo],
                         [NUTrackerUtilsTests randomActionInfo],
                         [NUTrackerUtilsTests randomActionInfo]];
    [NUTrackerUtils trackActions:actions inSession:[tracker session] completion:^(NSError *error) {
        
        if (error == nil) {
            XCTAssert(YES);
        } else {
            XCTFail(@"Track screen failed with error: %@", error);
        }
        
        [expectation fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Expectation timeout - actions test. Error: %@", error);
        }
    }];
}

- (void)testActionInfoGeneration
{
    NSArray *actionParameters = @[@"param1", [NSNull null], @"param3"];
    NSString *actionName = @"action_name";
    
    id actionInfo = [NUTracker actionInfoWithName:actionName parameters:actionParameters];
    NSString *actionURLEntry = [NUTrackerUtils trackActionURLEntryWithName:actionName parameters:actionParameters];
    
    XCTAssert([actionInfo isEqual:actionURLEntry]);
}

#pragma mark - Purchase Track

- (void)testPurchase
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
    NSString *affilation = @"Don't know about this";
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
    details.affilation = affilation;
    details.state = state;
    details.city = city;
    details.zip = zip;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - purchase"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [NUTrackerUtils trackPurchaseWithTotalAmount:amount products:@[product1, product2] purchaseDetails:details inSession:[tracker session] completion:^(NSError *error) {
        
        if (error == nil) {
            XCTAssert(YES);
        } else {
            XCTFail(@"Track purchase failed with error: %@", error);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Expectation timeout - purchase test. Error: %@", error);
        }
    }];
}

#pragma mark - Private

+ (id)randomActionInfo
{
    return [NUTrackerUtils trackActionURLEntryWithName:@"dummyActionName" parameters:@[@"parameter1", [NSNull null], @"parameter3", [NSNull null], [NSNull null], @"parameter6"]];
}

@end
