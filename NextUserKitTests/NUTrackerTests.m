//
//  NUTrackerTests.m
//  NextUserKit
//
//  Created by Dino on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NextUserKit/NextUserKit.h>

#import "NUTracker+Tests.h"
#import "NUTestDefinitions.h"
#import "NUTrackerSession.h"

@interface NUTrackerTests : XCTestCase

@property (nonatomic) NUTracker *tracker;

@end

@implementation NUTrackerTests

- (void)setUp
{
    [super setUp];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - session setup"];
    
    _tracker = [NUTracker sharedTracker];
    [_tracker startSessionWithTrackIdentifier:kTestTrackIdentifier completion:^(NSError *error) {
        
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

#pragma mark -

- (void)testTrackerSingleton
{
    NUTracker *tracker = [NUTracker sharedTracker];
    NUTracker *trackerAgain = [NUTracker sharedTracker];
    
    XCTAssertEqual(tracker, trackerAgain, @"Must be the same object instance");
}

#pragma mark - User Identify

- (void)testTrackIdentifierParameterWithUserIdentification
{
    NUTracker *tracker = [NUTracker sharedTracker];
    NUTrackerSession *session = [tracker session];
    
    NSString *userIdentifier = @"dummyUsername";
    [tracker identifyUserWithIdentifier:userIdentifier];
    
    NSString *generatedString = [NUTracker trackIdentifierParameterForSession:session appendUserIdentifier:YES];
    NSString *expectedString = [NSString stringWithFormat:@"%@+%@", session.trackIdentifier, session.userIdentifier];
    XCTAssert([generatedString isEqualToString:expectedString]);
    
    // cleanup
    [tracker identifyUserWithIdentifier:nil];
}

- (void)testTrackIdentifierParameterWithoutUserIdentification
{
    NUTracker *tracker = [NUTracker sharedTracker];
    NUTrackerSession *session = [tracker session];
    
    [tracker identifyUserWithIdentifier:nil];
    
    NSString *generatedString = [NUTracker trackIdentifierParameterForSession:session appendUserIdentifier:YES];
    NSString *expectedString = session.trackIdentifier;
    XCTAssert([generatedString isEqualToString:expectedString]);
}

- (void)testThatTrackIdentifierParameterGetsSentOnlyOnFirstRequest
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - user identifier test"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    NUTrackerSession *session = [tracker session];
    
    [tracker identifyUserWithIdentifier:@"dummyUsername"];
    
    __block NSDictionary *requestParameters = [tracker defaultTrackingParameters:!session.userIdentifierRegistered];
    __block NSString *generatedTid = requestParameters[@"tid"];
    __block NSString *expectedTid = [NSString stringWithFormat:@"%@+%@", session.trackIdentifier, session.userIdentifier];
    
    // on first request after setting user identifier, we want to send user identifier with 'tid' parameter
    XCTAssert([generatedTid isEqualToString:expectedTid]);
    
    [tracker trackScreenWithName:@"testScreenName" completion:^(NSError *error) {
        if (error == nil) {
            
            if (session.userIdentifierRegistered) {
                
                // all good for the first step
                // now, check how parameters will be generated for the next request (which must not send user identifier with 'tid' parameter)
                requestParameters = [tracker defaultTrackingParameters:!session.userIdentifierRegistered];
                generatedTid = requestParameters[@"tid"];
                expectedTid = session.trackIdentifier;
                
                XCTAssert([generatedTid isEqualToString:expectedTid]);
                
            } else {
                
                XCTFail(@"Track screen request did not register user identifier on first send");
            }
            
            // cleanup
            [tracker identifyUserWithIdentifier:nil];
            
            [expectation fulfill];
            
        } else {
            XCTFail(@"Track screen failed with error: %@", error);
            
            [expectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Expectation timeout - screen test. Error: %@", error);
        }
    }];
}

#pragma mark - Screen Track

- (void)testTrackScreen
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - screen test"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackScreenWithName:@"testScreenName" completion:^(NSError *error) {
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
    NUAction *action = [NUAction actionWithName:@"testActionName"];
    [tracker trackAction:action completion:^(NSError *error) {
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
    NSArray *actions = @[[NUTrackerTests randomAction],
                         [NUTrackerTests randomAction],
                         [NUTrackerTests randomAction],
                         [NUTrackerTests randomAction],
                         [NUTrackerTests randomAction]];
    
    [tracker trackActions:actions completion:^(NSError *error) {
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

#pragma mark - Purchase Track

- (void)testPurchase
{
    double amount = 45.65;
    
    NUPurchaseItem *item1 = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings"];
    item1.SKU = @"234523333344";
    item1.category = @"Science Fiction";
    item1.itemDescription = @"A long book about rings";
    item1.price = 99.23;
    item1.quantity = 7;
    
    NUPurchaseItem *item2 = [NUPurchaseItem itemWithProductName:@"Game Of Thrones"];
    item2.SKU = @"25678675874";
    item2.category = @"Science Fiction";
    item2.itemDescription = @"A long book about dragons";
    item2.price = 77.23;
    item2.quantity = 6;
    
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
    
    NUPurchase *purchase = [NUPurchase purchaseWithTotalAmount:amount items:@[item1, item2] details:details];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - purchase"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackPurchase:purchase completion:^(NSError *error) {
        
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

+ (NUAction *)randomAction
{
    NUAction *action = [NUAction actionWithName:@"dummyActionName"];
    action.firstParameter = @"parameter1";
    action.thirdParameter = @"parameter3";
    action.sixthParameter = @"parameter6";
    
    return action;
}

@end
