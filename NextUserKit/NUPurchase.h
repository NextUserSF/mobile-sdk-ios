//
//  NUPurchase.h
//  NextUserKit
//
//  Created by Dino on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUPurchaseDetails;

@interface NUPurchase : NSObject

// items is array of NUPurchaseItem objects
+ (NUPurchase *)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items;
+ (NUPurchase *)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items details:(NUPurchaseDetails *)purchaseDetails;

@property (nonatomic, readonly) double totalAmount;
@property (nonatomic, readonly) NSArray *items; // array of NUPurchaseItem objects
@property (nonatomic, readonly) NUPurchaseDetails *details;

@end
