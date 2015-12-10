//
//  NUPurchase.m
//  NextUserKit
//
//  Created by Dino on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUPurchase.h"

@interface NUPurchase ()

// redefinition to be r&w
@property (nonatomic) double totalAmount;
@property (nonatomic) NSArray *items; // array of NUPurchaseItem objects
@property (nonatomic) NUPurchaseDetails *details; // optional

@end

@implementation NUPurchase

+ (NUPurchase *)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items
{
    return [self purchaseWithTotalAmount:totalAmount items:items details:nil];
}

+ (NUPurchase *)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items details:(NUPurchaseDetails *)details
{
    NUPurchase *purchase = [[NUPurchase alloc] init];
    
    purchase.totalAmount = totalAmount;
    purchase.items = items;
    purchase.details = details;
    
    return purchase;
}

@end
