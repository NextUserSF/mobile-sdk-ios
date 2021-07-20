#import <Foundation/Foundation.h>
#import "NUCartManager.h"
#import "NUCart.h"
#import "NUJSONTransformer.h"
#import "NextUserManager.h"
#import "NUCache.h"
#import "NUUserVariables.h"
#import "NUInternalTracker.h"
#import "NUConstants.h"

#define CART_FILE_JSON @"cart.json"
#define LAST_BROWSED_FILE_JSON @"last_browsed.json"

@implementation NUCartManager
{
    NUCache *nuCache;
    NUCart *cart;
    NSOperationQueue *queue;
    NSUserDefaults *preferences;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        preferences = [NSUserDefaults standardUserDefaults];
        nuCache = [[NUCache alloc] init];
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [queue setName:@"com.nextuser.cartQueue"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTaskManagerHttpRequestNotification:)
                                                     name:COMPLETION_TASK_MANAGER_HTTP_REQUEST_NOTIFICATION_NAME
                                                   object:nil];
        cart = [self fetchCartFromCache];
        if ([self isTrackedForLastTrackedKey:USER_CART_LAST_TRACKED_KEY andForLastModifiedKey:USER_CART_LAST_MODIFIED_KEY] == NO) {
            [self trackCartStateSelector: cart];
        }
        
        if ([self isTrackedForLastTrackedKey:LAST_BROWSED_LAST_TRACKED_KEY andForLastModifiedKey:LAST_BROWSED_LAST_MODIFIED_KEY] == NO) {
            [self trackLastBrowsed:[self fetchLastBrowsedItemsFromCache]];
        }
    }
    
    return self;
}

- (BOOL) isTrackedForLastTrackedKey:(NSString*) lastTrackedKey andForLastModifiedKey:(NSString*) lastModifiedKey
{
    double lastTrackedTS = 0;
    double lastModifiedTS = 0;

    if ([self->preferences objectForKey:lastTrackedKey] != nil) {
        lastTrackedTS = [preferences doubleForKey:lastTrackedKey];
    }

    if ([self->preferences objectForKey:lastModifiedKey] != nil) {
        lastModifiedTS = [preferences doubleForKey:lastModifiedKey];
    }
    
    return lastModifiedTS < lastTrackedTS ? YES: NO;
}

- (void) setTotal: (double) total
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(setTotalSelector:) object:[NSNumber numberWithDouble:total]]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on setTotal: %@", [exception reason]);
    }
}

- (void) setDetails: (NUPurchaseDetails *) details
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(setDetailsSelector:) object:details]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on setDetails: %@", [exception reason]);
    }
}

- (void) setDetails:(NSDictionary *) detailsInfo withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NUPurchaseDetails *details = [NUPurchaseDetails details];
            details.currency = [detailsInfo valueForKey:@"currency"];
            details.paymentMethod = [detailsInfo valueForKey:@"paymentMethod"];
            details.affiliation = [detailsInfo valueForKey:@"affiliation"];
            details.state = [detailsInfo valueForKey:@"state"];
            details.city = [detailsInfo valueForKey:@"city"];
            details.zip = [detailsInfo valueForKey:@"zip"];
            
            if ([detailsInfo valueForKey:@"discount"] != nil) {
                details.discount = [[detailsInfo valueForKey:@"discount"] doubleValue];
            }
            if ([detailsInfo valueForKey:@"shipping"] != nil) {
                details.shipping = [[detailsInfo valueForKey:@"shipping"] doubleValue];
            }
            if ([detailsInfo valueForKey:@"tax"] != nil) {
                details.tax = [[detailsInfo valueForKey:@"tax"] doubleValue];
            }
            if ([detailsInfo valueForKey:@"incomplete"] != nil) {
                details.incomplete = [[detailsInfo valueForKey:@"incomplete"] isEqual:@"true"] == YES ? YES : NO;
            }
            
            [self setDetails:details];
            completion(YES, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

- (void) addOrUpdateItem: (NUCartItem *) item
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(addOrUpdateItemSelector:) object:item]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on addOrUpdateItem: %@", [exception reason]);
    }
}

- (void) addOrUpdateItem:(NSDictionary *) itemInfo withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NUCartItem *item = [[NUCartItem alloc] init];
            item.ID = [itemInfo valueForKey:@"ID"];
            item.name = [itemInfo valueForKey:@"name"];
            if (item.ID == nil || [item.ID isEqual:@""] == YES || item.name == nil || [item.name isEqual:@""] == YES) {
                completion(NO, [NUError nextUserErrorWithMessage:@"Invalid cart item data. ID and name are mandatory fields."]);
                
                return;
            }
            item.category = [itemInfo valueForKey:@"category"];
            item.desc = [itemInfo valueForKey:@"desc"];
            if ([itemInfo valueForKey:@"quantity"] != nil) {
                item.quantity = [[itemInfo valueForKey:@"quantity"] doubleValue];
            }
            if ([itemInfo valueForKey:@"price"] != nil) {
                item.price = [[itemInfo valueForKey:@"price"] doubleValue];
            }
            
            [self addOrUpdateItem:item];
            completion(YES, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

- (void) removeCartItemWithID: (NSString *) ID
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(removeCartItemWithIDSelector:) object:ID]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on removeCartItemWithID: %@", [exception reason]);
    }
}

- (void) clearCart
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(clearCartSelector:) object:nil]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on clearCart: %@", [exception reason]);
    }
}

- (void) checkout
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(checkoutSelector:) object:nil]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on checkout: %@", [exception reason]);
    }
}

- (void) viewedProduct:(NSString*) productId
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(viewedProductSelector:) object:productId]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on viewedProduct: %@", [exception reason]);
    }
}

- (void) viewedProductSelector:(NSString*) productId
{
    if (productId == nil || [productId isEqual:@""] == YES) {
        
        return;
    }
    
    NSMutableArray<NSString*>* lastBrowsedItems = [self fetchLastBrowsedItemsFromCache];
    if ([lastBrowsedItems count] == 5) {
        [lastBrowsedItems removeObjectAtIndex:0];
    }
    
    if ([lastBrowsedItems containsObject:productId] == YES) {
        [lastBrowsedItems removeObject:productId];
    }
    
    [lastBrowsedItems addObject:productId];
    [self refreshLastBrowsedItemsCache: lastBrowsedItems];
    [self trackLastBrowsed:lastBrowsedItems];
}

-(void) trackLastBrowsed:(NSMutableArray<NSString*>*) lastBrowsedItems
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:lastBrowsedItems
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString* lastBrowsedStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NUUserVariables *userVariables = [[NUUserVariables alloc] init];
    [userVariables addVariable:TRACK_VARIABLE_LAST_BROWSED withValue:lastBrowsedStr];
    [[[NextUserManager sharedInstance] getTracker] trackUserVariables:userVariables];
}

- (void) checkoutSelector:(id) fake
{
    if ([self isValidPurchase] == YES) {
        [[NextUserManager sharedInstance] trackWithObject:cart withType:TRACK_PURCHASE];
        [self clearCartSelector:nil];
    }
}

- (void) clearCartSelector:(id) fake
{
    cart = [[NUCart alloc] init];
    [self refreshCartCache];
    [self trackCartStateSelector: cart];
}

- (void) removeCartItemWithIDSelector: (NSString *) ID
{
    if (cart.items != nil && [cart.items count] > 0) {
        BOOL removed = [cart removeItemForID:ID];
        if (removed == YES) {
            [self refreshCartCache];
            [self trackCartStateSelector: cart];
        }
    }
}

- (void) addOrUpdateItemSelector: (NUCartItem *) item
{
    if (item == nil) {
        
        return;
    }
    
    if ([cart addOrUpdateItem:item] == YES) {
        [self refreshCartCache];
        [self trackCartStateSelector: cart];
    }
}

- (void) setDetailsSelector: (NUPurchaseDetails *) details
{
    cart.details = details;
    [self refreshCartCache];
}

- (void) setTotalSelector: (NSNumber*) total
{
    if (cart.items != nil && [cart.items count] > 0) {
        cart.total = [total doubleValue];
        [self refreshCartCache];
        [self trackCartStateSelector: cart];
    }
}

- (NUPurchaseDetails *) getPurchaseDetails
{
    return cart.details;
}

- (NSArray *) getCartItems
{
    
    return cart.items;
}

- (BOOL) isValidPurchase
{
    return cart.total > 0 && [cart.items count] > 0;
}

- (BOOL) isEmptyCart
{
    return cart.total == 0.0 && [cart.items count] == 0;
}

- (NUCart*) fetchCartFromCache
{
    @try
    {
        NSError *error = nil;
        NSData *jsonData = [nuCache readFromFile:CART_FILE_JSON];
        if (jsonData == nil || [jsonData length] == 0) {
            
            return [[NUCart alloc] init];
        }
        
        id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (error != nil) {
            DDLogError(@"Exception on fetchCartFromCache on data deserialization %@", error);
            
            return [[NUCart alloc] init];
        }
        
        return [NUJSONTransformer toNUCart:object];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on fetchCartFromCache %@", [exception reason]);
    } @catch (NUError *error) {
        DDLogError(@"Error on fetchCartFromCache %@", error);
    }
    
    return [[NUCart alloc] init];
}

- (NSMutableArray<NSString*>*) fetchLastBrowsedItemsFromCache
{
    @try
    {
        NSError *error = nil;
        NSData *jsonData = [nuCache readFromFile:LAST_BROWSED_FILE_JSON];
        if (jsonData == nil || [jsonData length] == 0) {
            
            return [[NSMutableArray<NSString*> alloc] init];
        }
        
        id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (error != nil) {
            DDLogError(@"Exception on fetchLastBrowsedItemsFromCache on data deserialization %@", error);
            
            return [[NSMutableArray<NSString*> alloc] init];
        }
        
        return [NUJSONTransformer toLastBrowsedItems:object];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on fetchCartFromCache %@", [exception reason]);
    } @catch (NUError *error) {
        DDLogError(@"Error on fetchCartFromCache %@", error);
    }
    
    return [[NSMutableArray<NSString*> alloc] init];
}

- (void) refreshLastBrowsedItemsCache:(NSMutableArray<NSString*>*) lastBrowsedItems;
{
    @try
    {
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:lastBrowsedItems options:NSJSONWritingPrettyPrinted error:&error];

        if (error == nil) {
            [nuCache writeData:json toFile:LAST_BROWSED_FILE_JSON];
            [preferences setDouble:[[NSDate date] timeIntervalSince1970] forKey:LAST_BROWSED_LAST_MODIFIED_KEY];
            [preferences synchronize];
        } else {
            DDLogDebug(@"Exception on json serialization of lastBrowsedItems %@", error);
        }
    } @catch (NSException *exception) {
        DDLogError(@"Exception on internalCacheMessages %@", [exception reason]);
    } @catch (NUError *error) {
        DDLogError(@"Error on internalCacheMessages %@", error);
    }
}

- (void) refreshCartCache
{
    @try
    {
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:[cart dictionaryReflectFromAttributes]
                                                       options:NSJSONWritingPrettyPrinted error:&error];
        if (error == nil) {
            [nuCache writeData:json toFile:CART_FILE_JSON];
            [preferences setDouble:[[NSDate date] timeIntervalSince1970] forKey:USER_CART_LAST_MODIFIED_KEY];
            [preferences synchronize];
        } else {
            DDLogDebug(@"Exception on json serialization of messages %@", error);
        }
    } @catch (NSException *exception) {
        DDLogError(@"Exception on internalCacheMessages %@", [exception reason]);
    } @catch (NUError *error) {
        DDLogError(@"Error on internalCacheMessages %@", error);
    }
}

- (void) trackCartState
{
    if ([self isTrackedForLastTrackedKey:USER_CART_LAST_TRACKED_KEY andForLastModifiedKey:USER_CART_LAST_MODIFIED_KEY] == NO) {
        @try {
            [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(trackCartStateSelector:) object:cart]];
        } @catch (NSException *exception) {
            DDLogError(@"Exception on checkout: %@", [exception reason]);
        }
    }
}

- (void) trackCartStateSelector:(NUCart*) cart
{
    NSString *cartStr = nil;
    if ([cart.items count] > 0 || [self isEmptyCart] == YES) {
        NSMutableDictionary *cartJSON = [cart dictionaryReflectFromAttributes];
        NSMutableArray *cartItemsJSON = [cartJSON valueForKey:@"items"];
        if (cartItemsJSON != nil && [cartItemsJSON count] > 0) {
            for (NSMutableDictionary *nextItem in cartItemsJSON) {
                [nextItem removeObjectForKey:@"name"];
                [nextItem removeObjectForKey:@"category"];
                [nextItem removeObjectForKey:@"price"];
                [nextItem removeObjectForKey:@"desc"];
                [nextItem setObject:[nextItem objectForKey:@"ID"] forKey:@"id"];
                [nextItem removeObjectForKey:@"ID"];
            }
        }
        [cartJSON removeObjectForKey: @"details"];
        [cartJSON removeObjectForKey: @"tracked"];
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cartJSON
                                                           options:NSJSONWritingPrettyPrinted error:&error];
        cartStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NUUserVariables *userVariables = [[NUUserVariables alloc] init];
        [userVariables addVariable:TRACK_VARIABLE_CART_STATE withValue:cartStr];
        [[[NextUserManager sharedInstance] getTracker] trackUserVariables:userVariables];
    }
}

-(void)receiveTaskManagerHttpRequestNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    id<NUTaskResponse> taskResponse = userInfo[COMPLETION_HTTP_REQUEST_NOTIFICATION_OBJECT_KEY];
    switch (taskResponse.taskType) {
        case TRACK_PURCHASE:
            if ([taskResponse successfull] == YES) {
                NUEvent *purchaseCompletedEvent = [NUEvent eventWithName:TRACK_EVENT_PURCHASE_COMPLETED];
                [[[NextUserManager sharedInstance] getTracker] trackEvent:purchaseCompletedEvent];
            }
            
            break;
        case TRACK_USER_VARIABLES:
            if ([taskResponse successfull] == YES) {
                NUTrackResponse *response = (NUTrackResponse *)taskResponse;
                NUUserVariables *userVariables = (NUUserVariables *)response.trackObject;
                if ([userVariables hasVariable:TRACK_VARIABLE_CART_STATE] == YES) {
                    [preferences setDouble:[[NSDate date] timeIntervalSince1970] forKey:USER_CART_LAST_TRACKED_KEY];
                    [preferences synchronize];
                } else if ([userVariables hasVariable:TRACK_VARIABLE_LAST_BROWSED] == YES) {
                    [preferences setDouble:[[NSDate date] timeIntervalSince1970] forKey:LAST_BROWSED_LAST_TRACKED_KEY];
                    [preferences synchronize];
                }
            }
        default:
            break;
    }
}

@end
