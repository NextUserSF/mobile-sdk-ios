#import <Foundation/Foundation.h>
#import "NUCartManager.h"
#import "NUCart.h"
#import "NUJSONTransformer.h"
#import "NextUserManager.h"
#import "NUCache.h"
#import "NUUserVariables.h"
#import "NUInternalTracker.h"

#define CART_FILE_JSON @"cart.json"

@implementation NUCartManager
{
    NUCache *nuCache;
    NUCart *cart;
    NSOperationQueue *queue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        nuCache = [[NUCache alloc] init];
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [queue setName:@"com.nextuser.cartQueue"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTaskManagerHttpRequestNotification:)
                                                     name:COMPLETION_TASK_MANAGER_HTTP_REQUEST_NOTIFICATION_NAME
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessageNotification:)
                                                     name:COMPLETION_TASK_MANAGER_MESSAGE_NOTIFICATION_NAME object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        cart = [self fetchCartFromCache];
        [self trackCartStateSelector: cart];
    }
    
    return self;
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

- (void) addOrUpdateItem: (NUCartItem *) item
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(addOrUpdateItemSelector:) object:item]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on addOrUpdateItem: %@", [exception reason]);
    }
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
            cart.tracked = NO;
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
        cart.tracked = NO;
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
        cart.tracked = NO;
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

- (void) refreshCartCache
{
    @try
    {
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:[cart dictionaryReflectFromAttributes]
                                                       options:NSJSONWritingPrettyPrinted error:&error];
        if (error == nil) {
            [nuCache writeData:json toFile:CART_FILE_JSON];
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
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(trackCartStateSelector:) object:cart]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on checkout: %@", [exception reason]);
    }
}

- (void) trackCartStateSelector:(NUCart*) cart
{
    if (cart.tracked == YES) {
        DDLogVerbose(@"Cart already tracked.");
        
        return;
    }
    
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
        [[[NextUserManager sharedInstance] getSession].user addVariable:TRACK_VARIABLE_CART_STATE withValue:cartStr];
        if ([[NextUserManager sharedInstance] validTracker] == YES) {
            NUTrackerTask *trackTask = [[NUTrackerTask alloc] initForType:TRACK_USER_VARIABLES withTrackObject:userVariables withSession:[[NextUserManager sharedInstance] getSession]];
            id<NUTaskResponse> response = [trackTask execute:[[NUTrackResponse alloc] initWithType:TRACK_USER_VARIABLES withTrackingObject:userVariables andQueued:NO]];
            if ([response successfull] == YES) {
                cart.tracked = YES;
                [self refreshCartCache];
            } else {
                DDLogDebug(@"Could not persist cart state.");
            }
        }
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
        default:
            break;
    }
}

-(void)receiveMessageNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NUTaskType type = [[userInfo valueForKey:COMPLETION_MESSAGE_NOTIFICATION_TYPE_KEY] intValue];
    switch (type) {
        case NETWORK_AVAILABLE:
            [self trackCartState];
            
            break;
        default:
            
            break;
    }
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self trackCartState];
}

@end
