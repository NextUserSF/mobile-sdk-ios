//
//  NUObjectPropertyStatusUtilsTests.m
//  NextUserKit
//
//  Created by Dino on 11/19/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NUObjectPropertyStatusUtils.h"

@interface NUObjectPropertyStatusUtilsTests : XCTestCase

@end

@implementation NUObjectPropertyStatusUtilsTests


- (void)testDoubleNonSetValue
{
    double nonSetValue = [NUObjectPropertyStatusUtils doubleNonSetValue];
    XCTAssert(![NUObjectPropertyStatusUtils isDoubleValueSet:nonSetValue]);
}

- (void)testUnsignedIntegerNonSetValue
{
    NSUInteger nonSetValue = [NUObjectPropertyStatusUtils unsignedIntegerNonSetValue];
    XCTAssert(![NUObjectPropertyStatusUtils isUnsignedIntegerValueSet:nonSetValue]);
}

@end
