//
//  NUAPIPathGeneratorTests.m
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUAPIPathGenerator.h"

@interface NUAPIPathGeneratorTests : XCTestCase

@end

@implementation NUAPIPathGeneratorTests

- (void)testAPIPathGeneration
{
    NSString *APIName = @"testAPIName";
    NSString *generatedAPIPath = [NUAPIPathGenerator pathWithAPIName:APIName];
    
    XCTAssert([generatedAPIPath containsString:APIName]);
}

- (void)testBaseURL
{
    NSString *basePath = [NUAPIPathGenerator basePath];
    NSString *generatedAPIPath = [NUAPIPathGenerator pathWithAPIName:@"randomAPIName"];
    
    NSRange range = [generatedAPIPath rangeOfString:basePath];
    
    // test that base path is at the begining of the generated path
    XCTAssert(range.location == 0 && range.length == basePath.length);
}

@end
