#import "NUPushNotificationsManager.h"
#import "NextUserManager.h"

@interface NUPushNotificationsManager() <UNUserNotificationCenterDelegate>
{

}
@end

@implementation NUPushNotificationsManager



-(instancetype)init
{
    self = [super init];
    
    return self;
}

- (void)submitFCMRegistrationToken:(NSString *) fcmToken
{
    NUTrackerSession *session = [[NextUserManager sharedInstance] getSession];
    if (session.trackerProperties.notifications == NO) {
        DDLogInfo(@"NextUser otifications system not active. Please contact support for enabling notifications." );
        
        return;
    }
    
    NSString *persistedUserToken = [session getdDeviceFCMToken];
    if (persistedUserToken != nil && [persistedUserToken isEqualToString:fcmToken]) {
        DDLogInfo(@"Already persisted fcm token: %@", persistedUserToken);
        
        return;
    }
    
    NURegistrationToken *deviceToken = [[NURegistrationToken alloc] init];
    deviceToken.token = fcmToken;
    deviceToken.provider = @"google";
    [[NextUserManager sharedInstance] trackWithObject:deviceToken withType:REGISTER_DEVICE_TOKEN];
}

- (void) submitFCMRegistrationToken:(NSString *) fcmToken withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            [self submitFCMRegistrationToken:fcmToken];
            completion(true, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

- (void)unregisterFCMRegistrationToken
{
    NUTrackerSession *session = [[NextUserManager sharedInstance] getSession];
    [session clearFcmToken];
    [[NextUserManager sharedInstance] trackWithObject:nil withType:UNREGISTER_DEVICE_TOKENS];
}

- (void) unregisterFCMRegistrationTokenWithCompletion:(void (^)(BOOL success, NSError*error))completion
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            [self unregisterFCMRegistrationToken];
            completion(true, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

-(void)requestNotificationsPermissions
{
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];

    UNNotificationCategory* nextuserCategory = [UNNotificationCategory
                                                categoryWithIdentifier:@"NextUser"
                                                actions:@[]
                                                intentIdentifiers:@[]
                                                options:UNNotificationCategoryOptionCustomDismissAction];
    
    [center setNotificationCategories:[NSSet setWithObjects:nextuserCategory, nil]];
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionCarPlay;
    [center requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted,
                                                                            NSError * _Nullable error) {
        if (granted == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                center.delegate = self;
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
        
        
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __IOS_AVAILABLE(10.0) __TVOS_AVAILABLE(10.0) __WATCHOS_AVAILABLE(3.0)
{
    NSLog(@"willPresentNotification %@", notification);
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler __IOS_AVAILABLE(10.0) __WATCHOS_AVAILABLE(3.0) __TVOS_PROHIBITED
{
    [self didReceiveNotificationResponse:response];
    completionHandler();
}

- (void) didReceiveNotificationResponse: (UNNotificationResponse *)response
{
    [self didReceiveNotificationResponseWithInfo:[[[[response notification] request] content] userInfo] andActionIdentifier:response.actionIdentifier];
}

- (void) didReceiveNotificationResponseWithInfo: (NSDictionary *)userInfo andActionIdentifier:(NSString *) actionIdentifier
{
    if ([self isNextUserNotification:userInfo]) {
        DDLogInfo(@"didReceiveNotificationResponse %@", userInfo);
        NSArray *eventsArray = nil;
        
        if ([actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
            //track dismiss
            eventsArray = userInfo[@"acme_dismissed"];
            DDLogInfo(@"The user dismissed the notification without taking action %@", userInfo);
        }
        else if ([actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
            //track clicked
            eventsArray = userInfo[@"acme_clicked"];
            DDLogInfo(@"The user launched the app %@", userInfo);
        }
        
        if (eventsArray != nil) {
            NSMutableArray<NUEvent *> * trackEvents = [self extractTrackingEvent:eventsArray];
            [[NextUserManager sharedInstance] trackWithObject:trackEvents withType:TRACK_EVENT];
        }
    }
}

- (void) didReceiveNotificationResponseWithInfo: (NSDictionary *)userInfo andActionIdentifier:(NSString *) actionIdentifier withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            [self didReceiveNotificationResponseWithInfo:userInfo andActionIdentifier:actionIdentifier];
            completion(YES, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

-(NSMutableArray<NUEvent *> *) extractTrackingEvent:(NSArray *) eventsArray
{
    NSMutableArray<NUEvent * >* events = nil;
    if (eventsArray != nil)
    {
        events = [[NSMutableArray alloc] init];
        for(id nextEventDict in eventsArray)
        {
            NSString *eventName = [nextEventDict objectForKey:@"eventName"];
            NSMutableArray *parameters = [nextEventDict objectForKey:@"parameters"];
            NUEvent *event = [NUEvent eventWithName:eventName andParameters:parameters];
            [events addObject:event];
        }
    }
    
    return events;
}

- (UIBackgroundFetchResult) didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([self isNextUserNotification:userInfo] == YES) {
        DDLogInfo(@"NextUser Notification devilvered %@", userInfo);
        //track delivered
        NSArray *eventsArray = [userInfo objectForKey:@"acme_delivered"];
        NSMutableArray<NUEvent *> * trackEvents = [self extractTrackingEvent:eventsArray];
        [[NextUserManager sharedInstance] trackWithObject:trackEvents withType:TRACK_EVENT];
        
        return UIBackgroundFetchResultNewData;
    }

    if ([userInfo objectForKey: @"next_user"] != nil) {
        NSError *errorJson = nil;
        NSString *messageStr = [userInfo objectForKey: @"next_user"];
        NSData *messageData = [messageStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&errorJson];
        NSString *newSha = [responseDict objectForKey: @"sha_key"];
        if (newSha != nil)
        {
            [[[NextUserManager sharedInstance] inAppMsgCacheManager] addNewSha: newSha];
            NUTaskManager *manager = [NUTaskManager manager];
            NUTrackerTask* task = [[NUTrackerTask alloc] initForType:NEW_IAM withTrackObject:newSha withSession:[[NextUserManager sharedInstance] getSession]];
            [manager submitTask:task];
        }
    }
    
    return UIBackgroundFetchResultNewData;
}

- (void) didReceiveRemoteNotification:(NSDictionary *)userInfo withCompletion:(void (^)(BOOL success, NSError*error))completion
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            [self didReceiveRemoteNotification:userInfo];
            completion(YES, nil);
        } @catch (NSException *exception) {
            completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
        }
    });
}

- (BOOL) isNextUserNotification:(NSDictionary *) userInfo
{
    if (userInfo != nil && [userInfo objectForKey:@"aps"] != nil) {
        NSString *category = [[userInfo objectForKey:@"aps"] objectForKey:@"category"];
        
        return category != nil && [category isEqual:@"NextUser"];
    }
    
    return NO;
}

- (void)unsubscribeFromAppStateNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
