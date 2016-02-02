//
//  NUPurchaseDetails.m
//  NextUserKit
//
//  Created by NextUser on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUPurchaseDetails.h"
#import "NUObjectPropertyStatusUtils.h"

@implementation NUPurchaseDetails

+ (instancetype)details
{
    return [[NUPurchaseDetails alloc] init];
}

- (id)init
{
    if (self = [super init]) {
        _discount = [NUObjectPropertyStatusUtils doubleNonSetValue];
        _shipping = [NUObjectPropertyStatusUtils doubleNonSetValue];
        _tax = [NUObjectPropertyStatusUtils doubleNonSetValue];
    }
    
    return self;
}

@end
