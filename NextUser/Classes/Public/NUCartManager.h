#import <Foundation/Foundation.h>

#import "NUPurchaseDetails.h"
#import "NUCartItem.h"

@interface NUCartManager : NSObject

- (void) setTotal: (double) total;
- (void) setDetails: (NUPurchaseDetails *) details;
- (NUPurchaseDetails *) getPurchaseDetails;
- (void) addOrUpdateItem: (NUCartItem *) item;
- (void) removeCartItemWithID: (NSString *) ID;
- (NSArray *) getCartItems;
- (void) clearCart;
- (void) checkout;

@end
