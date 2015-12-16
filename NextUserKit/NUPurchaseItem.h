//
//  NUPurchaseItem.h
//  NextUserKit
//
//  Created by Dino on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class represents a purchase item to supplement the NUPurchase.
 */
@interface NUPurchaseItem : NSObject

#pragma mark - Purchase Item Factory
/**
 * @name Purchase Item Factory
 */

/**
 *  Creates an instance of purchase item.
 *
 *  @param name Product name
 *  @param SKU  SKU of this item
 *
 *  @return Instance of NUPurchaseItem object
 */
+ (instancetype)itemWithProductName:(NSString *)name SKU:(NSString *)SKU;


#pragma mark - Properties
/**
 * @name Properties
 */

/**
 *  Name of the product.
 */
@property (nonatomic, readonly) NSString *productName;
@property (nonatomic, readonly) NSString *SKU;
@property (nonatomic) NSString *category;
@property (nonatomic) double price;
@property (nonatomic) NSUInteger quantity; // defaults to 1
@property (nonatomic) NSString *itemDescription;

@end
