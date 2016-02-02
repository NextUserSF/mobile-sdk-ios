//
//  NUPurchaseItem.h
//  NextUserKit
//
//  Created by NextUser on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class represents a purchase item and is being used by NUPurchase factory methods when
 *  creating new purchase. Each purchase can contain multiple purchase items.
 *
 *  Each purchase item should have at least productName and SKU set so use itemWithProductName:SKU:
 *  method when creating new item.
 */
@interface NUPurchaseItem : NSObject

#pragma mark - Purchase Item Factory
/**
 * @name Purchase Item Factory
 */

/**
 *  Creates an instance of purchase item.
 *
 *  @param name Product name.
 *  @param SKU  Product SKU.
 *
 *  @return Instance of NUPurchaseItem object.
 */
+ (instancetype)itemWithProductName:(NSString *)name SKU:(NSString *)SKU;


#pragma mark - Purchase Item Properties
/**
 * @name Purchase Item Properties
 */

/**
 *  Name of the product.
 */
@property (nonatomic, readonly) NSString *productName;

/**
 *  Product SKU.
 */
@property (nonatomic, readonly) NSString *SKU;

/**
 *  Product category.
 */
@property (nonatomic) NSString *category;

/**
 *  Product price.
 */
@property (nonatomic) double price;

/**
 *  Indicates how many products are inside this purchase item. Defaults to 1.
 */
@property (nonatomic) NSUInteger quantity;

/**
 *  Product description.
 */
@property (nonatomic) NSString *productDescription;

@end
