#import <Foundation/Foundation.h>
#import "NUJSONObject.h"
#import "NUCartItem.h"
#import "NUPurchaseDetails.h"
#import "NextUserManagers.h"

@interface NUCart : NUJSONObject

@property (nonatomic) double total;
@property (nonatomic) NSMutableArray<NUCartItem *> *items;
@property (nonatomic) NUPurchaseDetails *details;

-(BOOL) addOrUpdateItem:(NUCartItem *) item;
-(BOOL) removeItemForID:(NSString *) ID;

@end
