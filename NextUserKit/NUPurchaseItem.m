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
    NUPurchaseItem *item = [[NUPurchaseItem alloc] init];
    item.name = name;
    
    return item;
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
