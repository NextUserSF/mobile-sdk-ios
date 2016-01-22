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
@property (nonatomic) NSDictionary *actionTestSampleData;
@property (nonatomic) NSDictionary *purchaseTestSampleData;

@end

@implementation NUTrackerTests

- (instancetype)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation]) {
        // http://www.objgen.com/json/models/ZpR8
        _actionTestSampleData = [self loadSampleDataForFileName:@"test_data_action"];
        
        // http://www.objgen.com/json/models/uDmiV
        _purchaseTestSampleData = [self loadSampleDataForFileName:@"test_data_purchase"];
    }
    
    return self;
}

- (NSDictionary *)loadSampleDataForFileName:(NSString *)fileName
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:fileName
                                          ofType:@"json"];
    NSError *deserializingError;
    NSURL *localFileURL = [NSURL fileURLWithPath:filePath];
    NSData *contentOfLocalFile = [NSData dataWithContentsOfURL:localFileURL];
    return [NSJSONSerialization JSONObjectWithData:contentOfLocalFile
                                           options:0
                                             error:&deserializingError];
}

- (void)setUp
{
    [super setUp];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - session setup"];
    
    _tracker = [NUTracker sharedTracker];
    _tracker.logLevel = NULogLevelVerbose;
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

- (void)testFrameworkVersion
{
    XCTAssert(NextUserKitVersionNumber == 1.0);
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
    [tracker trackScreenWithName:@"screen ' with lots, of/spaces]characters, get = it" completion:^(NSError *error) {
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

#pragma mark - Track Multiple Actions Tests

+ (NUAction *)randomActionWithParametersAndName:(NSString *)actionName
{
    NUAction *action = [NUAction actionWithName:actionName];
    action.firstParameter = @"param 1 '&?;:";
    action.thirdParameter = @"param 3 '&?;:";
    action.sixthParameter = @"param 6 '&?;:";
    
    return action;
}

#pragma mark -

- (void)testMultipleActionsWithoutParameters
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - multiple actions"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    NSArray *actions = @[[NUAction actionWithName:@"1 action 'with characters,'&?;"],
                         [NUAction actionWithName:@"2 action 'with characters,'&?;"],
                         [NUAction actionWithName:@"3 action 'with characters,'&?;"],
                         [NUAction actionWithName:@"4 action 'with characters,'&?;"],
                         [NUAction actionWithName:@"5 action 'with characters,'&?;"]];
    
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

- (void)testMultipleActionsWithParameters
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - multiple actions"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    NSArray *actions = @[[NUTrackerTests randomActionWithParametersAndName:@"1 action 'with characters,'&?;"],
                         [NUTrackerTests randomActionWithParametersAndName:@"2 action 'with characters,'&?;"]];
    
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

#pragma mark - Action Track Helper

- (NUAction *)actionWithSampleDataKey:(NSString *)sampleDataKey
{
    NSDictionary *actionInfo = _actionTestSampleData[sampleDataKey];
    
    NUAction *action = [NUAction actionWithName:actionInfo[@"name"]];

    [action setFirstParameter:actionInfo[@"param_1"]];
    [action setSecondParameter:actionInfo[@"param_2"]];
    [action setThirdParameter:actionInfo[@"param_3"]];
    [action setFourthParameter:actionInfo[@"param_4"]];
    [action setFifthParameter:actionInfo[@"param_5"]];
    [action setSixthParameter:actionInfo[@"param_6"]];
    [action setSeventhParameter:actionInfo[@"param_7"]];
    [action setEightParameter:actionInfo[@"param_8"]];
    [action setNinthParameter:actionInfo[@"param_9"]];
    [action setTenthParameter:actionInfo[@"param_10"]];
    
    return action;
}

- (void)testTrackActionWithDataKey:(NSString *)actionDataKey
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Action start expectation"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackAction:[self actionWithSampleDataKey:actionDataKey]
              completion:^(NSError *error) {
                  XCTAssert(error == nil);
                  [expectation fulfill];
              }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Expectation timeout - action test. Error: %@", error);
        }
    }];
}

#pragma mark - Track Action Tests

- (void)testTrackActionSimpleValues
{
    [self testTrackActionWithDataKey:@"simple_values"];
}

- (void)testTrackActionSpecialCharacterValues
{
    [self testTrackActionWithDataKey:@"special_character_values"];
}

- (void)testTrackActionNoParamsSimpleName
{
    [self testTrackActionWithDataKey:@"no_params_simple_name"];
}

- (void)testTrackActionNoParamsSpeciarCharacterName
{
    [self testTrackActionWithDataKey:@"no_params_special_character_name"];
}

#pragma mark - Track Purchase Helper

- (NUPurchase *)purchaseWithSampleDataKey:(NSString *)sampleDataKey
{
    NUPurchase *purchase = nil;
    
    NSDictionary *purchaseInfo = _purchaseTestSampleData[sampleDataKey];
    
    double totalAmount = [purchaseInfo[@"total_amount"] doubleValue];
    NSArray *itemsInfo = purchaseInfo[@"items"];
    if (itemsInfo) {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemsInfo.count];
        for (NSDictionary *itemInfo in itemsInfo) {
            NUPurchaseItem *item = [NUPurchaseItem itemWithProductName:itemInfo[@"product_name"]
                                                                   SKU:itemInfo[@"sku"]];
            item.category = itemInfo[@"category"];
            item.price = [itemInfo[@"price"] doubleValue];
            item.quantity = [itemInfo[@"quantity"] unsignedIntegerValue];
            item.productDescription = itemInfo[@"product_description"];
            
            [items addObject:item];
        }
        
        NSDictionary *detailsInfo = purchaseInfo[@"details"];
        if (detailsInfo) {
            NUPurchaseDetails *details = [NUPurchaseDetails details];
            details.discount = [detailsInfo[@"discount"] doubleValue];
            details.shipping = [detailsInfo[@"shipping"] doubleValue];
            details.tax = [detailsInfo[@"tax"] doubleValue];
            
            details.currency = detailsInfo[@"currency"];
            details.incomplete = [detailsInfo[@"incomplete"] boolValue];
            details.paymentMethod = detailsInfo[@"paymentMethod"];
            details.affiliation = detailsInfo[@"affiliation"];

            details.state = detailsInfo[@"state"];
            details.city = detailsInfo[@"city"];
            details.zip = detailsInfo[@"zip"];
            
            purchase = [NUPurchase purchaseWithTotalAmount:totalAmount items:items details:details];
        } else {
            purchase = [NUPurchase purchaseWithTotalAmount:totalAmount items:items];
        }
    }
    
    return purchase;
}

- (void)testTrackPurchaseWithDataKey:(NSString *)dataKey
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - purchase"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackPurchase:[self purchaseWithSampleDataKey:dataKey]
                completion:^(NSError *error) {
                    XCTAssert(error == nil);
                    [expectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Expectation timeout - purchase test. Error: %@", error);
        }
    }];
}

#pragma mark - Track Purchase Tests

- (void)testPurchaseWithDetails
{
    [self testTrackPurchaseWithDataKey:@"with_details"];
}

- (void)testPurchaseWithoutDetails
{
    [self testTrackPurchaseWithDataKey:@"without_details"];
}

@end
