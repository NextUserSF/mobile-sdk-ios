//
//  NUPurchaseDetails.h
//  NextUserKit
//
//  Created by Dino on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class represents purchase details and is being used by the NUPurchase object.
 */
@interface NUPurchaseDetails : NSObject

#pragma mark - Details Factory
/**
 * @name Details Factory
 */

/**
 *  Creates an instance of purchase details.
 *
 *  @return Instance of NUPurchaseDetails object.
 */
+ (instancetype)details;

#pragma mark - Details Properties
/**
 * @name Details Properties
 */

/**
 *  Purchase discount amount.
 */
@property (nonatomic) double discount;

/**
 *  Purchase shipping cost.
 */
@property (nonatomic) double shipping;

/**
 *  Purchase tax amount.
 */
@property (nonatomic) double tax;

/**
 *  Currency in which purchase was done.
 */
@property (nonatomic) NSString *currency;

/**
 *  Indicates whether purchase was incomplete (e.g. failed, saved for later).
 *  Defaults to NO.
 */
@property (nonatomic) BOOL incomplete;

/**
 *  Purchase payment method (e.g. credit card, PayPal).
 */
@property (nonatomic) NSString *paymentMethod;

/**
 *  Site's purchase ID or similar.
 */
@property (nonatomic) NSString *affiliation;

/**
 *  Shipping address, state.
 */
@property (nonatomic) NSString *state;

/**
 *  Shipping address, city.
 */
@property (nonatomic) NSString *city;

/**
 *  Shipping address, zip code.
 */
@property (nonatomic) NSString *zip;

@end
