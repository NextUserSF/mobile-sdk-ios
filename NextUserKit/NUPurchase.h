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

+ (NUPurchase *)purchase;

@property (nonatomic) double totalAmount;
@property (nonatomic) NSArray *products; // array of NUProduct objects
@property (nonatomic) NUPurchaseDetails *details; // optional

@end
