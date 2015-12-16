//
//  NUPurchaseDetails.h
//  NextUserKit
//
//  Created by Dino on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class represents purchase details to supplement the NUPurchase.
 */
@interface NUPurchaseDetails : NSObject

#pragma mark - Details Factory
/**
 * @name Details Factory
 */

/**
 *  Creates an instance of purchase details.
 *
 *  @return Instance of NUPurchaseDetails object
 */
+ (instancetype)details;

#pragma mark - Properties
/**
 * @name Details Properties
 */

/**
 *  Purchase discount.
 */
@property (nonatomic) double discount; // amount of discount
@property (nonatomic) double shipping; // shipping cost
@property (nonatomic) double tax;
@property (nonatomic) NSString *currency;

@property (nonatomic) BOOL incomplete; // incomplete - purchase not completed (failed, saved for later...)
@property (nonatomic) NSString *paymentMethod;
@property (nonatomic) NSString *affiliation; // site's purchase ID or similar

// address
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *zip;

@end
