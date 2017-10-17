//
//  NUTracker.m
//  Pods
//
//  Created by Adrian Lazea on 29/08/2017.
//
//

#import <Foundation/Foundation.h>

#import "NUTracker.h"
#import "NUTrackerSession.h"
#import "NUUser.h"
#import "NUError.h"
#import "NUDDLog.h"
#import "NUTracker+Tests.h"
#import "NULogLevel.h"
#import "NUTaskManager.h"
#import "NUTrackerInitializationTask.h"


@implementation NUTracker

NSString * const COMPLETION_NU_TRACKER_NOTIFICATION_NAME = @"NUCompletionTTrackerNotification";
NSString * const NU_TRACK_RESPONSE = @"NUTTrackResponse";
NSString * const NU_TRACK_EVENT = @"NUTTrackEvent";


- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
{
    [[NextUserManager sharedInstance] initializeWithApplication:application withLaunchOptions:launchOptions];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NextUserManager sharedInstance] unsubscribeFromAppStateNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogInfo(@"Did receive local notification: %@", notification);
    if ([[NextUserManager sharedInstance] isNextUserLocalNotification:notification]) {
        [[NextUserManager sharedInstance] handleLocalNotification:notification application:application];
    }
}

#pragma mark -

- (void)requestDefaultPermissions
{
    [self requestLocationPersmissions];
    [self requestNotificationPermissions];
}

- (void)requestLocationPersmissions
{
   [[NextUserManager sharedInstance] requestLocationPersmissions];
}

- (void)requestNotificationPermissions
{
   [[NextUserManager sharedInstance] requestNotificationPermissionsForNotificationTypes:[[NextUserManager sharedInstance] allNotificationTypes]];
}

- (void)requestNotificationPermissionsForNotificationTypes:(UIUserNotificationType)types
{
    [[NextUserManager sharedInstance] requestNotificationPermissionsForNotificationTypes: types];
}

- (void)trackUser:(NUUser *)user
{
    if (user == nil) {
        
        return;
    }
    
    [self setUser:user];
    DDLogInfo(@"Tracking user with identifier: %@", user.userIdentifier);
    [[NextUserManager sharedInstance] trackWithObject:user withType:(TRACK_USER)];
}

- (void)trackUserVariables:(NUUserVariables *)userVariables
{
    if (userVariables == nil) {
        
        return;
    }
    
    
    DDLogInfo(@"Tracking userVariables");
    [[NextUserManager sharedInstance] trackWithObject:userVariables withType:(TRACK_USER_VARIABLES)];
}

- (void)setUser:(NUUser *)user
{
    if (![[NextUserManager sharedInstance] getSession]) {
        return;
    }
    
    [[NextUserManager sharedInstance] getSession].user = user;
}

- (NSString *)currentUserIdenifier
{
    if (![[NextUserManager sharedInstance] getSession]) {
        return nil;
    }
    
    return [[[NextUserManager sharedInstance] getSession].user userIdentifier];
}

- (void)trackScreenWithName:(NSString *)screenName
{
    if (screenName == nil) {
        
        return;
    }
    
    DDLogInfo(@"Track screen with name: %@", screenName);
    [[NextUserManager sharedInstance] trackWithObject:screenName withType:TRACK_SCREEN];
}

- (void)trackEvent:(NUEvent *)event
{
    if (event == nil) {
        
        return;
    }
    
    DDLogInfo(@"Track event: %@", event.eventName);
    [[NextUserManager sharedInstance] trackWithObject:@[event] withType:TRACK_EVENT];
}
- (void)trackEvents:(NSArray<NUEvent *> *)events
{
    if (events == nil || events.count == 0) {
        
        return;
    }
    
    DDLogInfo(@"Track events: %@", events);
    [[NextUserManager sharedInstance] trackWithObject:events withType:TRACK_EVENT];
}

- (void)trackPurchase:(NUPurchase *)purchase
{
    if (purchase == nil) {
        
        return;
    }
        
    DDLogInfo(@"Track purchase: %@", purchase);
    [[NextUserManager sharedInstance] trackWithObject:@[purchase] withType:TRACK_PURCHASE];
}

- (void)trackPurchases:(NSArray *)purchases
{
    if (purchases == nil || purchases.count == 0) {
        
        return;
    }
    
    DDLogInfo(@"Track purchases: %@", purchases);
    [[NextUserManager sharedInstance] trackWithObject:purchases withType:TRACK_PURCHASE];
}

+ (void)releaseSharedInstance
{
    [DDLog removeAllLoggers];
}

- (void)triggerLocalNoteWithDelay:(NSTimeInterval)delay
{
    NUPushMessage *message = [[NUPushMessage alloc] init];
    
    message.messageText = @"Jednom davno iza to sto plavo je li ti mislis o dnevnom jucer. ";
    message.contentURL = [NSURL URLWithString:@"http://www.nextuser.com"];
    message.UITheme = [NUIAMUITheme themeWithBackgroundColor:[UIColor redColor]
                                                   textColor:nil
                                                    textFont:nil];
    message.UITheme = [NUIAMUITheme defautTheme];
    message.fireDate = [NSDate dateWithTimeIntervalSinceNow:delay];
    
    [[NextUserManager sharedInstance] scheduleLocalNotificationForMessage:message];
}

@end
