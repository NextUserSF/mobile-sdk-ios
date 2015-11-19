//
//  NUTrackerTests.m
//  NextUserKit
//
//  Created by Dino on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NextUserKit/NextUserKit.h>
#import "NUTrackingHTTPRequestHelper.h"
#import "NUTracker+Tests.h"

@interface NUTrackerTests : XCTestCase

@end

@implementation NUTrackerTests

- (void)testTrackerSingleton
{
    NUTracker *tracker = [NUTracker sharedTracker];
    NUTracker *trackerAgain = [NUTracker sharedTracker];
    
    XCTAssertEqual(tracker, trackerAgain, @"Must be the same object instance");
}

#pragma mark - Screen Track

- (void)testTrackScreen
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - screen test"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker startWithCompletion:^(NSError *error) {
        if (error == nil) {
            [tracker trackScreenWithName:@"testScreenName" completion:^(NSError *error) {
                if (error == nil) {
                    XCTAssert(YES);
                } else {
                    XCTFail(@"Track screen failed with error: %@", error);
                }
                
                [expectation fulfill];
            }];
        } else {
            NSLog(@"Session start error: %@", error);
            XCTAssert(NO, @"Error starting session");
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

#pragma mark - Action Track

- (void)testTrackAction
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Action start expectation"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker startWithCompletion:^(NSError *error) {
        if (error == nil) {
            [tracker trackActionWithName:@"testActionName" parameters:nil completion:^(NSError *error) {
                if (error == nil) {
                    XCTAssert(YES);
                } else {
                    XCTFail(@"Track action failed with error: %@", error);
                }
                
                [expectation fulfill];
            }];
        } else {
            NSLog(@"Session start error: %@", error);
            XCTAssert(NO, @"Error starting session");
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

#pragma mark - Multiple Actions Track

- (void)testMultipleActions
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - multiple actions"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker startWithCompletion:^(NSError *error) {
        if (error == nil) {
            
            NSArray *actions = @[[NUTrackerTests randomActionInfo],
                                 [NUTrackerTests randomActionInfo],
                                 [NUTrackerTests randomActionInfo],
                                 [NUTrackerTests randomActionInfo],
                                 [NUTrackerTests randomActionInfo]];
            
            [tracker trackActions:actions completion:^(NSError *error) {
                
                if (error == nil) {
                    XCTAssert(YES);
                } else {
                    XCTFail(@"Track screen failed with error: %@", error);
                }
                
                [expectation fulfill];
            }];
        } else {
            NSLog(@"Session start error: %@", error);
            XCTAssert(NO, @"Error starting session");
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

- (void)testActionInfoGeneration
{
    NSArray *actionParameters = @[@"param1", [NSNull null], @"param3"];
    NSString *actionName = @"action_name";
    
    id actionInfo = [NUTracker actionInfoWithName:actionName parameters:actionParameters];
    NSString *actionURLEntry = [NUTrackingHTTPRequestHelper trackActionURLEntryWithName:actionName parameters:actionParameters];
    
    XCTAssert([actionInfo isEqual:actionURLEntry]);
}

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
    [tracker startWithCompletion:^(NSError *error) {
        if (error == nil) {
            
            [tracker trackPurchaseWithTotalAmount:amount products:@[product1, product2] purchaseDetails:details completion:^(NSError *error) {
                
                if (error == nil) {
                    XCTAssert(YES);
                } else {
                    XCTFail(@"Track purchase failed with error: %@", error);
                }
                
                [expectation fulfill];
            }];
        } else {
            NSLog(@"Session start error: %@", error);
            XCTAssert(NO, @"Error starting session");
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

#pragma mark - Private

+ (id)randomActionInfo
{
    return [NUTrackingHTTPRequestHelper trackActionURLEntryWithName:@"dummyActionName" parameters:@[@"parameter1", [NSNull null], @"parameter3", [NSNull null], [NSNull null], @"parameter6"]];
}

@end
