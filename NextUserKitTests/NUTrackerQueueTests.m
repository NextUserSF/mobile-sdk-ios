//
//  NUTrackerQueueTests.m
//  NextUserKit
//
//  Created by NextUser on 12/8/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NextUserKit/NextUserKit.h>
#import "NUPrefetchTrackerClient.h"
#import "NUTestDefinitions.h"
#import "NUTracker+Tests.h"

@interface NUTrackerQueueTests : XCTestCase

@end

@implementation NUTrackerQueueTests

#pragma mark - Setup

- (void)tearDown
{
    [NUTracker releaseSharedInstance];
}

#pragma mark - Tests

- (void)testTrackRequestAfterSessionStart
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - session setup"];

    NUTracker *tracker = [NUTracker sharedTracker];
    
    NSLog(@"Start session");
    [tracker startSessionWithTrackIdentifier:kTestTrackIdentifier completion:^(NSError *error) {
        NSLog(@"Start session finish");
    }];
    
    NUAction *action = [NUAction actionWithName:@"action name"];
    NUPrefetchTrackerClient *prefetchClient = [tracker prefetchClient];

    [prefetchClient trackActions:@[action] completion:^(NSError *error) {
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
    NUPrefetchTrackerClient *prefetchClient = [tracker prefetchClient];
    
    [tracker startSessionWithTrackIdentifier:kTestTrackIdentifier completion:^(NSError *error) {
    }];
    
    __block NSUInteger requestsCount = 2;
    NUAction *action = [NUAction actionWithName:@"action name"];

    [prefetchClient trackActions:@[action] completion:^(NSError *error) {
        requestsCount--;
        if (requestsCount == 0) {
            XCTAssert(error == nil);
            
            [expectation fulfill];
        }
    }];
    
    NUAction *action2 = [NUAction actionWithName:@"action name 2"];
    [prefetchClient trackActions:@[action2] completion:^(NSError *error) {
        requestsCount--;
        if (requestsCount == 0) {
            XCTAssert(error == nil);
            
            [expectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

- (void)testTrackRequestAfterSessionStartWithoutCompletionHandler
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - session setup"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    NUPrefetchTrackerClient *prefetchClient = [tracker prefetchClient];
    
    NSLog(@"Start session");
    [tracker startSessionWithTrackIdentifier:kTestTrackIdentifier];
    
    NUAction *action = [NUAction actionWithName:@"action name"];
    [prefetchClient trackActions:@[action] completion:^(NSError *error) {
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

- (void)testTrackRequestBeforeSessionStart
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Start expectation - session setup"];
    
    NUTracker *tracker = [NUTracker sharedTracker];
    NUPrefetchTrackerClient *prefetchClient = [tracker prefetchClient];
    
    NUAction *action = [NUAction actionWithName:@"action name"];
    [prefetchClient trackActions:@[action] completion:^(NSError *error) {
        NSLog(@"Send track request finish. Error: %@", error);
        
        XCTAssert(error != nil);
        
        [expectation fulfill];
    }];
    
    NSLog(@"Start session");
    [tracker startSessionWithTrackIdentifier:kTestTrackIdentifier completion:^(NSError *error) {
        NSLog(@"Start session finish");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

@end
