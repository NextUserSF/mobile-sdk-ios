//
//  NUPurchaseItem.m
//  NextUserKit
//
//  Created by NextUser on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUPurchaseItem.h"
#import "NUObjectPropertyStatusUtils.h"

@implementation NUPurchaseItem

+ (instancetype)itemWithProductName:(NSString *)name SKU:(NSString *)SKU
{
    NUPurchaseItem *item = [[NUPurchaseItem alloc] initWithProductName:name SKU:SKU];
    
    return item;
}

- (id)initWithProductName:(NSString *)name SKU:(NSString *)SKU
{
    if (self = [super init]) {
        _productName = name;
        _SKU = SKU;
        _quantity = 1;
        _price = [NUObjectPropertyStatusUtils doubleNonSetValue];
    }
    
    return self;
}

@end
