//
//  NUObjectPropertyStatusUtils.h
//  NextUserKit
//
//  Created by NextUser on 11/19/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUObjectPropertyStatusUtils : NSObject

+ (double)doubleNonSetValue;
+ (BOOL)isDoubleValueSet:(double)doubleValue;

+ (NSUInteger)unsignedIntegerNonSetValue;
+ (BOOL)isUnsignedIntegerValueSet:(double)doubleValue;

+ (BOOL)isStringValueSet:(NSString *)stringValue;

@end
