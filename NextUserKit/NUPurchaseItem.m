//
//  NUPurchaseItem.m
//  NextUserKit
//
//  Created by Dino on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUPurchaseItem.h"
#import "NUObjectPropertyStatusUtils.h"

@implementation NUPurchaseItem

+ (instancetype)itemWithName:(NSString *)name
{
    NUPurchaseItem *item = [[NUPurchaseItem alloc] initWithName:name];
    
    return item;
}

- (id)initWithName:(NSString *)name
{
    if (self = [super init]) {
        _name = name;
        _quantity = 1;
        _price = [NUObjectPropertyStatusUtils doubleNonSetValue];
    }
    
    return self;
}

@end
