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
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        nuCache = [[NUCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTaskManagerNotification:)
                                                     name:COMPLETION_TASK_MANAGER_HTTP_REQUEST_NOTIFICATION_NAME
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        cart = [self fetchCartFromCache];
        [self trackCartState];
    }
    
    return self;
}

- (void) setTotal: (double) total
{
    if (cart.items != nil && [cart.items count] > 0) {
        cart.total = total;
        cart.tracked = NO;
        [self refreshCartCache];
        [self trackCartState];
    }
}

- (void) setDetails: (NUPurchaseDetails *) details
{
    cart.details = details;
    [self refreshCartCache];
}

- (NUPurchaseDetails *) getPurchaseDetails
{
    
    return cart.details;
}

- (void) addOrUpdateItem: (NUCartItem *) item
{
    if (item == nil) {
        
        return;
    }
    
    if ([cart addOrUpdateItem:item] == YES) {
        cart.tracked = NO;
        [self refreshCartCache];
        [self trackCartState];
    }
}

- (bool) removeCartItemWithID: (NSString *) ID
{
    if (cart.items != nil && [cart.items count] > 0) {
        BOOL removed = [cart removeItemForID:ID];
        if (removed == YES) {
            cart.tracked = NO;
            [self refreshCartCache];
            [self trackCartState];
        }
        
        return removed;
    }
    
    return NO;
}
- (NSArray *) getCartItems
{
    
    return cart.items;
}

- (void) clearCart
{
    cart = [[NUCart alloc] init];
    [self refreshCartCache];
    [self trackCartState];
}

- (void) checkout
{
    if ([self isValidPurchase] == YES) {
        [[NextUserManager sharedInstance] trackWithObject:cart withType:TRACK_PURCHASE];
        [self clearCart];
    }
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
    if (cart.tracked == YES) {
        
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
        [[[NextUserManager sharedInstance] getTracker] trackUserVariables:userVariables];
    }
}

-(void)receiveTaskManagerNotification:(NSNotification *) notification
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
                NUTrackResponse *trackResp = (NUTrackResponse *) taskResponse;
                NUUserVariables *userVar = (NUUserVariables *) [trackResp trackObject];
                if ([[userVar.variables allKeys] containsObject:TRACK_VARIABLE_CART_STATE] == YES) {
                    cart.tracked = YES;
                    [self refreshCartCache];
                }
            }
            
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
