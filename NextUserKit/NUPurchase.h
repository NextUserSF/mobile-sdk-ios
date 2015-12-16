//
//  NUPurchase.h
//  NextUserKit
//
//  Created by Dino on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUPurchaseDetails;

/**
 *  This class represents a purchase that user performed inside of the application.
 */
@interface NUPurchase : NSObject

#pragma mark - Purchase Factory
/**
 * @name Purchase Factory
 */

/**
*  Creates an instance of NUPurchase.
*
*  For more detailed purchase use purchaseWithTotalAmount:items:details:purchaseDetails method.
*
*  @param totalAmount Purchase total amount
*  @param items       Array of NUPurchaseItem objects
*
*  @return Instance of NUPurchase object
*  @see purchaseWithTotalAmount:items:details: method
*/
+ (instancetype)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items;

/**
 *  Creates an instance of NUPurchase.
 *
 *  @param totalAmount     Purchase total amount
 *  @param items           Array of NUPurchaseItem objects
 *  @param purchaseDetails Optional purchase details
 *
 *  @return Instance of NUPurchase object
 *  @see purchaseWithTotalAmount:items:details:
 */
+ (instancetype)purchaseWithTotalAmount:(double)totalAmount items:(NSArray *)items details:(NUPurchaseDetails *)purchaseDetails;

@end
