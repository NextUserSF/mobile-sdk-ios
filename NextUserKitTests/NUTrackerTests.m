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

#pragma mark - Action Parameters

- (void)testActionParametersStringGenerateFromEmpty
{
    NSArray *inputArray = @[];
    NSString *actionParametersString = [NUTracker trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@""]);
}

- (void)testActionParametersStringGenerateFromAllNulls
{
    NSArray *inputArray = @[[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]];
    NSString *actionParametersString = [NUTracker trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@""]);
}

- (void)testActionParametersStringGenerateFromOneNonNullAtFirstIndex
{
    NSArray *inputArray = @[@"1_value", [NSNull null], [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]];
    NSString *actionParametersString = [NUTracker trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@"1_value"]);
}

- (void)testActionParametersStringGenerateFromOneNonNullAtSecondIndex
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]];
    NSString *actionParametersString = [NUTracker trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",2_value"]);
}

- (void)testActionParametersStringGenerateFromOneNonNullAtThirdIndex
{
    NSArray *inputArray = @[[NSNull null], [NSNull null], @"3_value", [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]];
    NSString *actionParametersString = [NUTracker trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",,3_value"]);
}

- (void)testActionParametersStringGenerateFromNonNullOverloadArray
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null],
                            @"11_value"]; // 10 max
    NSString *actionParametersString = [NUTracker trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",2_value"]);
}

- (void)testActionParametersStringGenerateFromNullOverloadArray
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null]]; // 10 max
    NSString *actionParametersString = [NUTracker trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",2_value"]);
}

- (void)testActionParametersStringGenerateFromSmallerArray
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], @"9_value"];
    NSString *actionParametersString = [NUTracker trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",2_value,,,,,,,9_value"]);
}

#pragma mark - Action URL value

- (void)testActionURLValueFromNonNullOverloadArray
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], @"9_value"];
    NSString *actionParametersString = [NUTracker trackActionURLEntryWithName:@"actionName0" parameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@"actionName0,,2_value,,,,,,,9_value"]);
}

- (void)testActionURLValueFromNonNullOverloadArrayAndNilActionName
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], @"9_value"];
    NSString *actionParametersString = [NUTracker trackActionURLEntryWithName:nil parameters:inputArray];
    
    XCTAssert(actionParametersString == nil);
}

#pragma mark - Multiple Actions

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
            
            [tracker trackMultipleActions:actions completion:^(NSError *error) {
                
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
    NSString *actionURLEntry = [NUTracker trackActionURLEntryWithName:actionName parameters:actionParameters];
    
    XCTAssert([actionInfo isEqual:actionURLEntry]);
}

#pragma mark - Private

+ (id)randomActionInfo
{
    return [NUTracker trackActionURLEntryWithName:@"dummyActionName" parameters:@[@"parameter1", [NSNull null], @"parameter3", [NSNull null], [NSNull null], @"parameter6"]];
}

@end
