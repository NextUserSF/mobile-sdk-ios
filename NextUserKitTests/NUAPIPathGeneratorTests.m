//
//  NUTrackingHTTPRequestHelperTests.m
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUTrackingHTTPRequestHelper.h"

@interface NUTrackingHTTPRequestHelperTests : XCTestCase

@end

@implementation NUTrackingHTTPRequestHelperTests

- (void)testAPIPathGeneration
{
    NSString *APIName = @"testAPIName";
    NSString *generatedAPIPath = [NUTrackingHTTPRequestHelper pathWithAPIName:APIName];
    
    XCTAssert([generatedAPIPath containsString:APIName]);
}

- (void)testBaseURL
{
    NSString *basePath = [NUTrackingHTTPRequestHelper basePath];
    NSString *generatedAPIPath = [NUTrackingHTTPRequestHelper pathWithAPIName:@"randomAPIName"];
    
    NSRange range = [generatedAPIPath rangeOfString:basePath];
    
    // test that base path is at the begining of the generated path
    XCTAssert(range.location == 0 && range.length == basePath.length);
}

#pragma mark - Action Parameters

- (void)testActionParametersStringGenerateFromEmpty
{
    NSArray *inputArray = @[];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@""]);
}

- (void)testActionParametersStringGenerateFromAllNulls
{
    NSArray *inputArray = @[[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@""]);
}

- (void)testActionParametersStringGenerateFromOneNonNullAtFirstIndex
{
    NSArray *inputArray = @[@"1_value", [NSNull null], [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@"1_value"]);
}

- (void)testActionParametersStringGenerateFromOneNonNullAtSecondIndex
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",2_value"]);
}

- (void)testActionParametersStringGenerateFromOneNonNullAtThirdIndex
{
    NSArray *inputArray = @[[NSNull null], [NSNull null], @"3_value", [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",,3_value"]);
}

- (void)testActionParametersStringGenerateFromNonNullOverloadArray
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null],
                            @"11_value"]; // 10 max
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",2_value"]);
}

- (void)testActionParametersStringGenerateFromNullOverloadArray
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null]]; // 10 max
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",2_value"]);
}

- (void)testActionParametersStringGenerateFromSmallerArray
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], @"9_value"];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionParametersStringWithActionParameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@",2_value,,,,,,,9_value"]);
}

#pragma mark - Action URL value

- (void)testActionURLValueFromNonNullOverloadArray
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], @"9_value"];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionURLEntryWithName:@"actionName0" parameters:inputArray];
    
    XCTAssert([actionParametersString isEqualToString:@"actionName0,,2_value,,,,,,,9_value"]);
}

- (void)testActionURLValueFromNonNullOverloadArrayAndNilActionName
{
    NSArray *inputArray = @[[NSNull null], @"2_value", [NSNull null], [NSNull null], [NSNull null],
                            [NSNull null], [NSNull null], [NSNull null], @"9_value"];
    NSString *actionParametersString = [NUTrackingHTTPRequestHelper trackActionURLEntryWithName:nil parameters:inputArray];
    
    XCTAssert(actionParametersString == nil);
}


@end
