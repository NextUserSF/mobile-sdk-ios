#import <Foundation/Foundation.h>

#import "NUTracker.h"
#import "NUTrackerSession.h"
#import "NUUser.h"
#import "NUError.h"
#import "NUDDLog.h"
#import "NULogLevel.h"
#import "NUTaskManager.h"
#import "NUTrackerInitializationTask.h"
#import "NUTask.h"
#import "NextUserManager.h"
#import "NUConstants.h"
#import "NUInternalTracker.h"
#import "NUJSONTransformer.h"


@implementation NUTracker

- (id)init
{
    if (self = [super init]) {
        _enabled = YES;
    }
    
    return self;
}

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
{
    [[NextUserManager sharedInstance] initializeWithApplication:application withLaunchOptions:launchOptions];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NextUserManager sharedInstance] notificationsManager] unsubscribeFromAppStateNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UNNotificationRequest *)notification
{
    DDLogInfo(@"Did receive local notification: %@", notification);
}

- (void) trackObject:(id) trackObject withType:(NUTaskType) type
{
    [[NextUserManager sharedInstance] trackWithObject:trackObject withType:type];
}

-(NUEvent *) nuEventFromDictionary:(NSDictionary *) eventInfo
{
    if (eventInfo == nil || [[eventInfo allKeys] count] == 0) {
        
        return nil;
    }
    
    if ([eventInfo valueForKey:@"event"] == nil || [[eventInfo valueForKey:@"event"] isEqual:@""] == YES) {
        
        return nil;
    }
    
    return [NUEvent eventWithName:[eventInfo valueForKey:@"event"] andParameters:[eventInfo valueForKey:@"parameters"]];
}

-(BOOL) isEnabled
{
    DDLogVerbose(@"Tracker is %@", _enabled == YES ? @"enabled. Start Tracking..." : @"disabled. Please enable in order to start tracking. ");
    
    return _enabled;
}

+ (void)releaseSharedInstance
{
    [DDLog removeAllLoggers];
}

#pragma mark - NUTracker

- (UIBackgroundFetchResult) didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    return [[[NextUserManager sharedInstance] notificationsManager] didReceiveRemoteNotification:userInfo];
}

- (void)requestNotificationsPermissions
{
     [[[NextUserManager sharedInstance] notificationsManager] requestNotificationsPermissions];
}

- (void)trackUser:(NUUser *)user
{
    if ([self isEnabled] == NO) {
        
        return;
    }
    
    if (user == nil) {
        
        return;
    }
    
    [self setUser:user];
    DDLogInfo(@"Tracking user with identifier: %@", user.userIdentifier);
    [self trackObject:user withType:TRACK_USER];
}

- (void)trackUser:(NSDictionary *) user withCompletion:(void (^)(BOOL success, NSError*error))completion;
{
    if ([self isEnabled] == NO) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Tracker is not enabled."]);
        
        return;
    }
    
    if (user == nil || [[user allKeys] count] == 0) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Invalid user data."]);
        
        return;
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            NUUser *nuUser =[NUUser user];
            nuUser.email = [user valueForKey:@"email"];
            nuUser.customerID = [user valueForKey:@"customerID"];
            nuUser.subscription = [user valueForKey:@"subscription"];
            nuUser.firstname = [user valueForKey:@"firstname"];
            nuUser.lastname = [user valueForKey:@"lastname"];
            nuUser.birthyear = [user valueForKey:@"birthyear"];
            nuUser.country = [user valueForKey:@"country"];
            nuUser.state = [user valueForKey:@"state"];
            nuUser.zipcode = [user valueForKey:@"zipcode"];
            nuUser.locale = [user valueForKey:@"locale"];
            if ([user valueForKey:@"gender"] != nil) {
                if ([[user valueForKey:@"gender"] isEqual:@"M"] || [[user valueForKey:@"gender"] isEqual:@"m"]) {
                    nuUser.gender = MALE;
                } else if ([[user valueForKey:@"gender"] isEqual:@"F"] || [[user valueForKey:@"gender"] isEqual:@"f"]) {
                    nuUser.gender = FEMALE;
                }
            }
            
            [self trackUser:nuUser];
            completion(YES, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage: exception.reason]);
        }
    });
}

- (void)trackUserVariables:(NUUserVariables *)userVariables
{
    if ([self isEnabled] == NO) {
        
        return;
    }
    
    if (userVariables == nil) {
        
        return;
    }
    
    DDLogInfo(@"Tracking userVariables");
    [self trackObject:userVariables withType:TRACK_USER_VARIABLES];
}

- (void)trackUserVariables:(NSDictionary *) userVariables withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    if ([self isEnabled] == NO) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Tracker is not enabled."]);
        
        return;
    }
    
    if (userVariables == nil || [[userVariables allKeys] count] == 0) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Invalid user variables data."]);
        
        return;
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NUUserVariables *nuUserVariables =[[NUUserVariables alloc] init];
            for (NSString* key in [userVariables allKeys]) {
                [nuUserVariables addVariable:key withValue:[userVariables valueForKey:key]];
            }
        
            [self trackUserVariables:nuUserVariables];
            completion(YES, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

- (void)setUser:(NUUser *)user
{
    if (![[NextUserManager sharedInstance] getSession]) {
        return;
    }
    
    [[NextUserManager sharedInstance] getSession].user = user;
}

- (NSString *)currentUserIdentifier
{
    if (![[NextUserManager sharedInstance] getSession]) {
        return nil;
    }
    
    return [[[NextUserManager sharedInstance] getSession].user userIdentifier];
}

- (void)trackScreenWithName:(NSString *)screenName
{
    if ([self isEnabled] == NO) {
        
        return;
    }
    
    if (screenName == nil) {
        
        return;
    }
    
    DDLogInfo(@"Track screen with name: %@", screenName);
    [self trackObject:screenName withType:TRACK_SCREEN];
}

- (void)trackEvent:(NUEvent *)event
{
    if ([self isEnabled] == NO) {
        
        return;
    }
    
    if (event == nil) {
        
        return;
    }
    
    DDLogInfo(@"Track event: %@", event.eventName);
    [self trackObject:event withType:TRACK_EVENT];
}

- (void)trackEvent:(NSDictionary *) eventDict withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    if ([self isEnabled] == NO) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Tracker is not enabled."]);
        
        return;
    }
    
    if (eventDict == nil || [[eventDict allKeys] count] == 0) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Invalid event data."]);
        
        return;
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NUEvent *nuEvent = [self nuEventFromDictionary:eventDict];
            if (nuEvent == nil) {
                completion(NO, [NUError nextUserErrorWithMessage:@"Invalid event data."]);
                
                return;
            }
           
            [self trackEvent:nuEvent];
            completion(YES, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

- (void)trackEvents:(NSArray<NUEvent *> *)events
{
    if ([self isEnabled] == NO) {
        
        return;
    }
    
    if (events == nil || events.count == 0) {
        
        return;
    }
    
    DDLogInfo(@"Track events: %@", events);
    [self trackObject:events withType:TRACK_EVENT];
}

- (void)trackEvents:(NSArray<NSDictionary *> *) events withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    if ([self isEnabled] == NO) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Tracker is not enabled."]);
        
        return;
    }
    
    if (events == nil || [events count] == 0) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Invalid events data."]);
        
        return;
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSMutableArray<NUEvent*>* nuEvents = [[NSMutableArray alloc] initWithCapacity:[events count]];
            for (NSDictionary *eventDict in events) {
                NUEvent *nuEvent = [self nuEventFromDictionary:eventDict];
                if (nuEvent == nil) {
                    completion(NO, [NUError nextUserErrorWithMessage:@"Invalid events data."]);
                    
                    return;
                }
                [nuEvents addObject:nuEvent];
            }
        
            if ([nuEvents count] > 0) {
                [self trackEvents:nuEvents];
                completion(YES, nil);
            } else {
                completion(NO, [NUError nextUserErrorWithMessage:@"Invalid events data."]);
            }
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

- (BOOL) hasSession
{
    return [[NextUserManager sharedInstance] validTracker];
}

- (void) disable
{
    _enabled = NO;
}

- (void) enable
{
    _enabled = YES;
}

- (void)trackViewedProduct:(NSString*) productId
{
    [InternalEventTracker trackEvent:TRACK_EVENT_VIEWED_PRODUCT withParams:productId];
    [[NextUser cartManager] viewedProduct:productId];
}

- (void)trackViewedProduct:(NSString*) productId withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    if ([self isEnabled] == NO) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Tracker is not enabled."]);
        
        return;
    }
    
    if (productId == nil || [productId isEqual:@""]) {
        completion(NO, [NUError nextUserErrorWithMessage:@"Invalid product id."]);
        
        return;
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self trackViewedProduct:productId];
        completion(YES, nil);
    });
}

@end
