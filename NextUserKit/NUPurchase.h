//
//  NUPurchase.h
//  NextUserKit
//
//  Created by NextUser on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUPurchaseDetails;

/**
 *  This class represents a general purchase. When user makes a purchase inside your application and
 *  you need to track that, use this class.
 *
 *  Each purchase has 2 parts at minimum: total amount and items being purchased. Purchase can be optionally
 *  supplemented with additional details (NUPurchaseDetails).
 *
 *  *Note: User of this class should not depend on purchase object to calculate total amount based on the item's
 *  price and quantity. Also, total amount value is not being calculated internally based on the purchase details
 *  (e.g. tax, shipping). It is totally up to the user of this class to pre calculate all values needed.*
 */
@interface NUPurchase : NSObject

#pragma mark - Purchase Factory
/**
 * @name Purchase Factory
 */

/**
 *  Creates an instance of purchase with total amount and purchase items. 
 *
 *  It is up to the caller to calculate totalAmount value. This value will NOT be auto generated based on
 *  the price and quantity of purchase items.
 *
 *  If you need to track additional information about a purchase, use purchaseWithTotalAmount:items:details:
 *  method which has one additional parameter, NUPurchaseDetails.
 *
 *  @param totalAmount Purchase total amount.
 *  @param items       Array of NUPurchaseItem objects that are being purchased in this purchase.
 *
 *  @return Instance of NUPurchase object.
 *  @see purchaseWithTotalAmount:items:details: method
 */
+ (instancetype)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items;

/**
 *  Creates an instance of purchase object with total amount, purchase items and purchase details.
 *
 *  It is up to the caller to calculate totalAmount value. This value will NOT be auto generated based on
 *  the price and quantity of purchase items or based on the values in purchase details (e.g. tax, shipping).
 *
 *  Purchase details are optional and passing a *null* value for this parameter would be the same as
 *  if calling the purchaseWithTotalAmount:items: method.
 *
 *  @param totalAmount     Purchase total amount.
 *  @param items           Array of NUPurchaseItem objects that are being purchased in this purchase.
 *  @param purchaseDetails Optional purchase details.
 *
 *  @return Instance of NUPurchase object.
 *  @see purchaseWithTotalAmount:items:details:
 */
+ (instancetype)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items details:(NUPurchaseDetails *)purchaseDetails;

@end
