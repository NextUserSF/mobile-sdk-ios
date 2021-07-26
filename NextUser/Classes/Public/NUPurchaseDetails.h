#import <Foundation/Foundation.h>
#import "NUJSONObject.h"

@interface NUPurchaseDetails : NUJSONObject

#pragma mark - Details Factory

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
 *  Shipping address, city.

 /**
  *  Site's purchase ID or similar.
  */
 @property (nonatomic) NSString *affiliation;

 /**
  *  Shipping address, state.
  */
 @property (nonatomic) NSString *state;
 */
@property (nonatomic) NSString *city;

/**
 *  Shipping address, zip code.
 */
@property (nonatomic) NSString *zip;

@end
