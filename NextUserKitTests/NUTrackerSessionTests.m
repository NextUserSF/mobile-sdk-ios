//
//  NUTrackerSessionTests.m
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUTrackerSession.h"

@interface NUTrackerSessionTests : XCTestCase

@end

@implementation NUTrackerSessionTests

- (void)testSessionFirstStart
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Session first start expectation"];
    
    NUTrackerSession *session = [[NUTrackerSession alloc] init];
    [session clearSerializedDeviceCookie];
    
    [session startWithCompletion:^(NSError *error) {
        if (error == nil) {
            XCTAssert(session.deviceCookie != nil && session.sessionCookie != nil, @"deviceCookie & sessionCookie must be set");
        } else {
            XCTFail(@"Start session failed with error: %@", error);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

- (void)testSessionSubsequentStart
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Session start expectation"];
    
    NUTrackerSession *session = [[NUTrackerSession alloc] init];
    NSString *serializedDeviceCookie = [session serializedDeviceCookie];

    [session startWithCompletion:^(NSError *error) {
        if (error == nil) {
            XCTAssert([session.deviceCookie isEqualToString:serializedDeviceCookie], @"deviceCookie & _firstStartDeviceCookie must match");
        } else {
            XCTFail(@"Start session failed with error: %@", error);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Start session timeout error: %@", error);
        }
    }];
}

@end
