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


@implementation NUTracker

NSString * const NEXTUSER_LOCAL_NOTIFICATION = @"NextUserLocalNotification";
NSString * const NEXTUSER_LOCAL_NOTIFICATION_OBJECT = @"NextUserLocalNotificationObject";
NSString * const NEXTUSER_LOCAL_NOTIFICATION_EVENT = @"NextUserLocalNotificationEvent";
NSString * const NEXTUSER_LOCAL_NOTIFICATION_SUCCESS_COMPLETION = @"NextUserLocalNotificationSuccessCompletion";

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
{
    [[NextUserManager sharedInstance] initializeWithApplication:application withLaunchOptions:launchOptions];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NextUserManager sharedInstance] notificationsManager] unsubscribeFromAppStateNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogInfo(@"Did receive local notification: %@", notification);
}

#pragma mark -

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
    if (user == nil) {
        
        return;
    }
    
    [self setUser:user];
    DDLogInfo(@"Tracking user with identifier: %@", user.userIdentifier);
    [self trackObject:user withType:TRACK_USER];
}

- (void)trackUserVariables:(NUUserVariables *)userVariables
{
    if (userVariables == nil) {
        
        return;
    }
    
    for (NSString *key in userVariables.variables.allKeys) {
        [[[NextUserManager sharedInstance] getSession].user addVariable:key withValue:userVariables.variables[key]];
    }
    
    DDLogInfo(@"Tracking userVariables");
    [self trackObject:userVariables withType:TRACK_USER_VARIABLES];
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
    if (screenName == nil) {
        
        return;
    }
    
    DDLogInfo(@"Track screen with name: %@", screenName);
    [self trackObject:screenName withType:TRACK_SCREEN];
}

- (void)trackEvent:(NUEvent *)event
{
    if (event == nil) {
        
        return;
    }
    
    DDLogInfo(@"Track event: %@", event.eventName);
    [self trackObject:@[event] withType:TRACK_EVENT];
}
- (void)trackEvents:(NSArray<NUEvent *> *)events
{
    if (events == nil || events.count == 0) {
        
        return;
    }
    
    DDLogInfo(@"Track events: %@", events);
    [self trackObject:events withType:TRACK_EVENT];
}

- (void) trackObject:(id) trackObject withType:(NUTaskType) type
{
    [[NextUserManager sharedInstance] trackWithObject:trackObject withType:type];
}

+ (void)releaseSharedInstance
{
    [DDLog removeAllLoggers];
}

@end
