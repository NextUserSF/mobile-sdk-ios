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

// items is an array of NUPurchaseItem objects
+ (instancetype)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items;
+ (instancetype)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items details:(NUPurchaseDetails *)purchaseDetails;

@end
