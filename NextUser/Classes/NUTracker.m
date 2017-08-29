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

+ (instancetype)sharedTracker
{
    static NUTracker *instance;
    static dispatch_once_t instanceInitToken;
    dispatch_once(&instanceInitToken, ^{
        instance = [[NUTracker alloc] init];
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    });
    
    return instance;
}

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
{
    static dispatch_once_t appInitToken;
    dispatch_once(&appInitToken, ^{
        DDLogInfo(@"Did finish launching with options: %@", launchOptions);
        //UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        //if (localNotification && [[NextUserManager sharedInstance] isNextUserLocalNotification:localNotification]) {
        //    [[NextUserManager sharedInstance] handleLocalNotification:localNotification application:application];
        //}
        
        //NUTrackerInitializationTask *initTask = [[NUTrackerInitializationTask alloc] init];
        //NUTaskManager *manager = [NUTaskManager manager];
        //[manager submitTask: initTask];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[NextUserManager sharedInstance] unsubscribeFromAppStateNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogInfo(@"Did receive local notification: %@", notification);
    //if ([[NextUserManager sharedInstance] isNextUserLocalNotification:notification]) {
    //    [[NextUserManager sharedInstance] handleLocalNotification:notification application:application];
    //}
}

#pragma mark -

- (void)requestDefaultPermissions
{
    [self requestLocationPersmissions];
    [self requestNotificationPermissions];
}

- (void)requestLocationPersmissions
{
   // [[NextUserManager sharedInstance] requestLocationPersmissions];
}

- (void)requestNotificationPermissions
{
   // [[NextUserManager sharedInstance] requestNotificationPermissionsForNotificationTypes:[[NextUserManager sharedInstance] allNotificationTypes]];
}

- (void)requestNotificationPermissionsForNotificationTypes:(UIUserNotificationType)types
{
    //[[NextUserManager sharedInstance] requestNotificationPermissionsForNotificationTypes: types];
}


- (void)trackUser:(NUUser *)user
{
    [self setUser:user];
    DDLogInfo(@"Tracking user with identifier: %@", user.userIdentifier);
    //[[NextUserManager sharedInstance] trackWithObject:user withType:(TRACK_USER)];
}

- (void)setUser:(NUUser *)user
{
    //if (![[NextUserManager sharedInstance] getSession]) {
    //    return;
    //}
    
   // [[NextUserManager sharedInstance] getSession].user = user;
}

- (NSString *)currentUserIdenifier
{
    //if (![[NextUserManager sharedInstance] getSession]) {
        return nil;
    //}
    
    return nil; //[[[NextUserManager sharedInstance] getSession].user userIdentifier];
}

- (void)trackScreenWithName:(NSString *)screenName
{
    DDLogInfo(@"Track screen with name: %@", screenName);
    //[[NextUserManager sharedInstance] trackWithObject:screenName withType:TRACK_SCREEN];
}

- (void)trackAction:(NUAction *)action
{
    DDLogInfo(@"Track action: %@", action);
   // [[NextUserManager sharedInstance] trackWithObject:@[action] withType:TRACK_ACTION];
}

- (void)trackActions:(NSArray *)actions
{
    DDLogInfo(@"Track actions: %@", actions);
    //[[NextUserManager sharedInstance] trackWithObject:actions withType:TRACK_ACTION];
}

- (void)trackPurchase:(NUPurchase *)purchase
{
    DDLogInfo(@"Track purchase: %@", purchase);
    //[[NextUserManager sharedInstance] trackWithObject:@[purchase] withType:TRACK_PURCHASE];
}

- (void)trackPurchases:(NSArray *)purchases
{
    DDLogInfo(@"Track purchases: %@", purchases);
    //[[NextUserManager sharedInstance] trackWithObject:purchases withType:TRACK_PURCHASE];
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
    
    //[[NextUserManager sharedInstance] scheduleLocalNotificationForMessage:message];
}

@end
