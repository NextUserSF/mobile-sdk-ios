//
//  NUProduct.m
//  NextUserKit
//
//  Created by Dino on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUProduct.h"
#import "NUObjectPropertyStatusUtils.h"

@implementation NUProduct

+ (instancetype)productWithName:(NSString *)name
{
    NUProduct *product = [[NUProduct alloc] init];
    product.name = name;
    
    return product;
}

- (id)init
{
    if (self = [super init]) {
        _quantity = 1;
        _price = [NUObjectPropertyStatusUtils doubleNonSetValue];
    }
    
    return self;
}

@end
