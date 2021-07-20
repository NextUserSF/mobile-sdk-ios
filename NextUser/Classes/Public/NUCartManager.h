#import <Foundation/Foundation.h>

#import "NUPurchaseDetails.h"
#import "NUCartItem.h"

@interface NUCartManager : NSObject

- (void) setTotal: (double) total;

- (void) setDetails: (NUPurchaseDetails *) details;
- (void) setDetails:(NSDictionary *) detailsInfo withCompletion:(void (^)(BOOL success, NSError*error))completion;
- (NUPurchaseDetails *) getPurchaseDetails;

- (void) addOrUpdateItem: (NUCartItem *) item;
- (void) addOrUpdateItem:(NSDictionary *) itemInfo withCompletion:(void (^)(BOOL success, NSError*error))completion;

- (void) removeCartItemWithID: (NSString *) ID;
- (NSArray *) getCartItems;
- (void) clearCart;
- (void) viewedProduct: (NSString*) productId;
- (void) checkout;

@end
