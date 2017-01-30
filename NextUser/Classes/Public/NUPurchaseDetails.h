//
//  NUPurchaseDetails.h
//  NextUserKit
//
//  Created by NextUser on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class represents additional purchase information. It contains methods which add more information
 *  into the purchase (e.g. shipping cost, discount amount etc).
 *
 *  This class is being used by NUPurchase factory method when creating new purchase.
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
 *  Purchase completion (incomplete) status. E.g. if purchase is failed or saved for later, its 
 *  incomplete status would be *YES*. Defaults to *NO*.
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
