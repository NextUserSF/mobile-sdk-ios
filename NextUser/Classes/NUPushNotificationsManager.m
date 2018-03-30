#import "NUPushNotificationsManager.h"
#import "NextUserManager.h"


@interface NUPushNotificationsManager() <UNUserNotificationCenterDelegate>
{
    NUPushMessageService *pushMessageService;
    NUAppWakeUpManager *wakeUpManager;
}
@end

@implementation NUPushNotificationsManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        wakeUpManager = [NUAppWakeUpManager manager];
        wakeUpManager.delegate = self;
    }
    
    return self;
}

- (void)pushMessageService:(NUPushMessageService *)service didReceiveMessages:(NSArray *)messages
{
    // TODO: figure out scheduling logic. Schedule all messages or skip some of them if they are overlapping.
    for (NUPushMessage *message in messages) {
        [self scheduleLocalNotificationForMessage:message];
    }
}

- (void)scheduleLocalNotificationForMessage:(NUPushMessage *)message
{
    DDLogInfo(@"Schedule local note for message: %@", message);
    UILocalNotification *note = [self localNotificationFromPushMessage:message];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
}

- (UILocalNotification *)localNotificationFromPushMessage:(NUPushMessage *)message
{
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.timeZone = [NSTimeZone defaultTimeZone];
    note.alertBody = message.messageText;
    note.fireDate = message.fireDate;
    
    NSData *UIThemeData = [NSKeyedArchiver archivedDataWithRootObject:message.UITheme];
    
    NSDictionary *userInfo = @{kPushMessageLocalNoteTypeKey : @YES,
                               kPushMessageContentURLKey : message.contentURL.absoluteString,
                               kPushMessageUIThemeDataKey : UIThemeData};
    note.userInfo = userInfo;
    
    return note;
}

- (void)submitFCMRegistrationToken:(NSString *) fcmToken
{
    NURegistrationToken *deviceToken = [[NURegistrationToken alloc] init];
    deviceToken.token = fcmToken;
    deviceToken.provider = @"google";

    NUTrackerSession *session = [[NextUserManager sharedInstance] getSession];
    if (session.trackerProperties.notifications == NO) {
        return;
    }
    
    NSString *persistedUserToken = [session readStringValueForKey: USER_TOKEN_KEY];
    BOOL tokenSubmitted = [session readBoolValueForKey:USER_TOKEN_SUBMITTED_KEY];
    
    if (persistedUserToken != nil && [persistedUserToken isEqualToString:fcmToken] && tokenSubmitted == YES) {
        return;
    }
    
    [session writeForKey:USER_TOKEN_KEY stringValue:fcmToken];
    [[NextUserManager sharedInstance] trackWithObject:deviceToken withType:REGISTER_DEVICE_TOKEN];
}

- (void)unregisterFCMRegistrationToken
{
    NUTrackerSession *session = [[NextUserManager sharedInstance] getSession];
    [session writeForKey:USER_TOKEN_KEY stringValue: nil];
    [session writeForKey:USER_TOKEN_SUBMITTED_KEY boolValue: NO];
    [[NextUserManager sharedInstance] trackWithObject:nil withType:UNREGISTER_DEVICE_TOKENS];
}

-(void)requestNotificationsPermissions
{
    if (@available(iOS 10.0, *)) {
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
    } else {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
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
    DDLogInfo(@"didReceiveNotificationResponse %@", response);
    NSDictionary *userInfo = [[[[response notification] request] content] userInfo];
    NSArray *eventsArray = nil;
    
    if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
        //track dismiss
        eventsArray = userInfo[@"acme_dismissed"];
        DDLogInfo(@"The user dismissed the notification without taking action %@", response);
    }
    else if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        //track clicked
        eventsArray = userInfo[@"acme_clicked"];
        DDLogInfo(@"The user launched the app %@", response);
    }
    
    if (eventsArray != nil) {
        NSMutableArray<NUEvent *> * trackEvents = [self extractTrackingEvent:eventsArray];
        [[NextUserManager sharedInstance] trackWithObject:trackEvents withType:TRACK_EVENT];
    }
    
    completionHandler();
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
    DDLogInfo(@"Notification devilvered %@", userInfo);
    //track delivered
    NSArray *eventsArray = [userInfo objectForKey:@"acme_delivered"];
    NSMutableArray<NUEvent *> * trackEvents = [self extractTrackingEvent:eventsArray];
     [[NextUserManager sharedInstance] trackWithObject:trackEvents withType:TRACK_EVENT];
    
    return UIBackgroundFetchResultNewData;
}

-(void)requestLocationPersmissions
{
    [wakeUpManager requestLocationUsageAuthorization];
}

- (NUPushMessage *)pushMessageFromLocalNotification:(UILocalNotification *)notification
{
    NUPushMessage *message = [[NUPushMessage alloc] init];
    message.messageText = notification.alertBody;
    message.contentURL = [NSURL URLWithString:notification.userInfo[kPushMessageContentURLKey]];
    message.UITheme = [NSKeyedUnarchiver unarchiveObjectWithData:notification.userInfo[kPushMessageUIThemeDataKey]];
    
    return message;
}

+ (BOOL)isNextUserLocalNotification:(UILocalNotification *)note
{
    return note.userInfo[kPushMessageLocalNoteTypeKey] != nil;
}

- (void)handleLocalNotification:(UILocalNotification *)notification application:(UIApplication *)application
{
    if ([NUPushNotificationsManager isNextUserLocalNotification:notification]) {
        
        DDLogInfo(@"Handle local notification. App state: %@", @(application.applicationState));
        NUPushMessage *message = [self pushMessageFromLocalNotification:notification];
        
        if (application.applicationState == UIApplicationStateActive) {
            [[NUInAppMessageManager sharedManager] showPushMessage:message skipNotificationUI:NO];
        } else if (application.applicationState == UIApplicationStateInactive ||
                   application.applicationState == UIApplicationStateBackground) {
            [[NUInAppMessageManager sharedManager] showPushMessage:message skipNotificationUI:YES];
        }
    }
}

- (void)appWakeUpManager:(NUAppWakeUpManager *)manager didWakeUpAppInBackgroundWithTaskCompletion:(void (^)(void))completion
{
    // fetch missed messages (history)
    // schedule local notes
    // call completion
    
    NSLog(@"Did wake up application");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *text = [NSString stringWithFormat:@"AS: %@, BG time: %@", @([[UIApplication sharedApplication] applicationState]), @([[UIApplication sharedApplication] backgroundTimeRemaining])];
        
        UILocalNotification *note = [[UILocalNotification alloc] init];
        note.timeZone = [NSTimeZone defaultTimeZone];
        note.alertBody = text;
        note.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:note];
        
        completion();
    });
}

- (void)unsubscribeFromAppStateNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
