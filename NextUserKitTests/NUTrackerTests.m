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

#pragma mark - Private

+ (id)randomActionInfo
{
    return [NUTrackingHTTPRequestHelper trackActionURLEntryWithName:@"dummyActionName" parameters:@[@"parameter1", [NSNull null], @"parameter3", [NSNull null], [NSNull null], @"parameter6"]];
}

@end
