//
//  NUObjectPropertyStatusUtils.m
//  NextUserKit
//
//  Created by NextUser on 11/19/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUObjectPropertyStatusUtils.h"

@implementation NUObjectPropertyStatusUtils

+ (double)doubleNonSetValue
{
    return DBL_MAX;
}

+ (BOOL)isDoubleValueSet:(double)doubleValue
{
    return doubleValue != [self doubleNonSetValue];
}

+ (NSUInteger)unsignedIntegerNonSetValue
{
    return UINT_MAX;
}

+ (BOOL)isUnsignedIntegerValueSet:(double)unsignedIntegerValue
{
    return unsignedIntegerValue != [self unsignedIntegerNonSetValue];
}

+ (BOOL)isStringValueSet:(NSString *)stringValue
{
    return stringValue != nil;
}

@end
