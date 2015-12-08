//
//  NUTrackerQueueTests.m
//  NextUserKit
//
//  Created by Dino on 12/8/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NextUserKit/NextUserKit.h>
#import "NUTestDefinitions.h"
#import "NUTracker+Tests.h"

@interface NUTrackerQueueTests : XCTestCase

@end

@implementation NUTrackerQueueTests

- (void)testTrackRequestAfterSessionStart
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - session setup"];

    NUTracker *tracker = [NUTracker sharedTracker];
    
    NSLog(@"Start session");
    [tracker startSessionWithTrackIdentifier:kTestTrackIdentifier completion:^(NSError *error) {
        NSLog(@"Start session finish");
    }];
    
    NUAction *action = [NUAction actionWithName:@"action name"];
    [tracker trackAction:action completion:^(NSError *error) {
        NSLog(@"Send track request finish");
        
        XCTAssert(error == nil);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

- (void)testMultipleTrackRequestAfterSessionStart
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - session setup"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    
    [tracker startSessionWithTrackIdentifier:kTestTrackIdentifier completion:^(NSError *error) {
    }];
    
    __block NSUInteger requestsCount = 2;
    NUAction *action = [NUAction actionWithName:@"action name"];
    [tracker trackAction:action completion:^(NSError *error) {
        requestsCount--;
        if (requestsCount == 0) {
            XCTAssert(error == nil);
            
            [expectation fulfill];
        }
    }];
    
    NUAction *action2 = [NUAction actionWithName:@"action name 2"];
    [tracker trackAction:action2 completion:^(NSError *error) {
        requestsCount--;
        if (requestsCount == 0) {
            XCTAssert(error == nil);
            
            [expectation fulfill];
        }
    }];
    
    [self waitForExpectat1ionsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

@end
