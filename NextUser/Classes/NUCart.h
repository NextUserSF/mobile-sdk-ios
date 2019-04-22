#import <Foundation/Foundation.h>
#import "NUJSONObject.h"
#import "NUCartItem.h"
#import "NUPurchaseDetails.h"

@interface NUCart : NUJSONObject

@property (nonatomic) double total;
@property (nonatomic) NSMutableArray<NUCartItem *> *items;
@property (nonatomic) NUPurchaseDetails *details;
@property (nonatomic) BOOL tracked;

-(BOOL) addOrUpdateItem:(NUCartItem *) item;
-(BOOL) removeItemForID:(NSString *) ID;

@end
