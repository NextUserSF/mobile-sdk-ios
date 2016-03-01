//
//  NUTrackerTests.m
//  NextUserKit
//
//  Created by NextUser on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NextUserKit/NextUserKit.h>

#import "NUTracker+Tests.h"
#import "NUTestDefinitions.h"
#import "NUTrackerSession.h"
#import "NUPrefetchTrackerClient.h"

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

#pragma mark - JSON Sample Data Load

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

#pragma mark - Test Data Factory

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

#pragma mark - Unit Test Setup

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

- (void)tearDown
{
    [NUTracker releaseSharedInstance];
}

#pragma mark - Framework Version

- (void)testFrameworkVersion
{
    XCTAssert(NextUserKitVersionNumber == 1.0);
}

#pragma mark - Tracker Singleton

- (void)testTrackerSingleton
{
    NUTracker *tracker = [NUTracker sharedTracker];
    NUTracker *trackerAgain = [NUTracker sharedTracker];
    
    XCTAssertEqual(tracker, trackerAgain, @"Must be the same object instance");
}

#pragma mark - Session Start

- (void)testEmptyTrackingIdentifierThrowsException
{
    XCTAssertThrows([_tracker startSessionWithTrackIdentifier:nil]);
}

#pragma mark - User Identify

- (void)testTrackIdentifierParameterWithUserIdentification
{
    NUTracker *tracker = [NUTracker sharedTracker];
    NUTrackerSession *session = [tracker session];
    
    NSString *userIdentifier = @"dummyUsername";
    [tracker identifyUserWithIdentifier:userIdentifier];
    
    NSString *generatedString = [NUPrefetchTrackerClient trackIdentifierParameterForSession:session appendUserIdentifier:YES];
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
    
    NSString *generatedString = [NUPrefetchTrackerClient trackIdentifierParameterForSession:session appendUserIdentifier:YES];
    NSString *expectedString = session.trackIdentifier;
    XCTAssert([generatedString isEqualToString:expectedString]);
}

- (void)testThatTrackIdentifierParameterGetsSentOnlyOnFirstRequest
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - user identifier test"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    NUTrackerSession *session = [tracker session];
    
    [tracker identifyUserWithIdentifier:@"dummyUsername"];
    
    __block NSDictionary *requestParameters = [NUPrefetchTrackerClient defaultTrackingParametersForSession:session
                                                                                     includeUserIdentifier:!session.userIdentifierRegistered];
    __block NSString *generatedTid = requestParameters[@"tid"];
    __block NSString *expectedTid = [NSString stringWithFormat:@"%@+%@", session.trackIdentifier, session.userIdentifier];
    
    // on first request after setting user identifier, we want to send user identifier with 'tid' parameter
    XCTAssert([generatedTid isEqualToString:expectedTid]);
    
    [tracker trackScreenWithName:@"testScreenName" completion:^(NSError *error) {
        if (error == nil) {
            
            if (session.userIdentifierRegistered) {
                
                // all good for the first step
                // now, check how parameters will be generated for the next request (which must not send user identifier with 'tid' parameter)
                requestParameters = [NUPrefetchTrackerClient defaultTrackingParametersForSession:session
                                                                           includeUserIdentifier:!session.userIdentifierRegistered];
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

- (void)testTrackScreenWithName:(NSString *)screenName
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - screen test"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackScreenWithName:screenName completion:^(NSError *error) {
        XCTAssert(error == nil);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Expectation timeout - screen test. Error: %@", error);
        }
    }];
}

#pragma mark -

- (void)testTrackScreenWithComplicatedName
{
    [self testTrackScreenWithName:@"screen ' with lots, of/spaces]characters, get = it"];
}

- (void)testTrackScreenWithSimpleName
{
    [self testTrackScreenWithName:@"simple_screen_name"];
}

#pragma mark - Track Action Tests

- (void)testTrackAction:(NUAction *)action
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Action start expectation"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackAction:action
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

- (void)testTrackActions:(NSArray *)actions
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Action start expectation"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackActions:actions
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

#pragma mark -

- (void)testTrackActionSimpleValues
{
    [self testTrackAction:[self actionWithSampleDataKey:@"simple_values"]];
}

- (void)testTrackActionSpecialCharacterValues
{
    [self testTrackAction:[self actionWithSampleDataKey:@"special_character_values"]];
}

- (void)testTrackActionNoParamsSimpleName
{
    [self testTrackAction:[self actionWithSampleDataKey:@"no_params_simple_name"]];
}

- (void)testTrackActionNoParamsSpecialCharacterName
{
    [self testTrackAction:[self actionWithSampleDataKey:@"no_params_special_character_name"]];
}

- (void)testMultipleActionsWithoutParameters
{
    NSArray *actions = @[[self actionWithSampleDataKey:@"no_params_simple_name"],
                         [self actionWithSampleDataKey:@"special_character_values"],
                         [self actionWithSampleDataKey:@"no_params_simple_name"],
                         [self actionWithSampleDataKey:@"no_params_special_character_name"],
                         [self actionWithSampleDataKey:@"no_params_simple_name"]];
    [self testTrackActions:actions];
}

- (void)testMultipleActionsWithParameters
{
    NSArray *actions = @[[self actionWithSampleDataKey:@"no_params_simple_name"],
                         [self actionWithSampleDataKey:@"no_params_special_character_name"]];
    [self testTrackActions:actions];
}

#pragma mark - Track Purchase Tests

- (void)testTrackPurchase:(NUPurchase *)purchase
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - purchase"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackPurchase:purchase
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

- (void)testTrackPurchases:(NSArray *)purchases
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - purchase"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    [tracker trackPurchases:purchases
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

#pragma mark -

- (void)testPurchaseWithDetails
{
    [self testTrackPurchase:[self purchaseWithSampleDataKey:@"with_details"]];
}

- (void)testPurchaseWithoutDetails
{
    [self testTrackPurchase:[self purchaseWithSampleDataKey:@"without_details"]];
}

- (void)testPurchasesTracking
{
    [self testTrackPurchases:@[[self purchaseWithSampleDataKey:@"with_details"],
                               [self purchaseWithSampleDataKey:@"without_details"]]];
}

@end
