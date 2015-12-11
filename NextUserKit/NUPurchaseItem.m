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

+ (instancetype)itemWithProductName:(NSString *)name
{
    NUPurchaseItem *item = [[NUPurchaseItem alloc] initWithProductName:name];
    
    return item;
}

- (id)initWithProductName:(NSString *)name
{
    if (self = [super init]) {
        _productName = name;
        _quantity = 1;
        _price = [NUObjectPropertyStatusUtils doubleNonSetValue];
    }
    
    return self;
}

@end
