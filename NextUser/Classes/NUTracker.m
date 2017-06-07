//
//  NUTracker.m
//  NextUserKit
//
//  Created by NextUser on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTracker.h"
#import "NUTrackerSession.h"
#import "NextUserManager.h"
#import "NUUser.h"
#import "NSError+NextUser.h"
#import "NUDDLog.h"
#import "NUTracker+Tests.h"
#import "NULogLevel.h"
#import "NUTaskManager.h"
#import "NUTrackerInitializationTask.h"


@implementation Tracker
{
    NextUserManager *nextUserManager;
}

+ (instancetype)sharedTracker
{
    static Tracker *instance;
    static dispatch_once_t instanceInitToken;
    dispatch_once(&instanceInitToken, ^{
        instance = [[Tracker alloc] init];
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        instance -> nextUserManager = [[NextUserManager alloc] initManager];
    });
    
    return instance;
}

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
{
    static dispatch_once_t appInitToken;
    dispatch_once(&appInitToken, ^{
        DDLogInfo(@"Did finish launching with options: %@", launchOptions);
        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification && [nextUserManager isNextUserLocalNotification:localNotification]) {
            [nextUserManager handleLocalNotification:localNotification application:application];
        }
        
        NUTrackerInitializationTask *initTask = [[NUTrackerInitializationTask alloc] init];
        NUTaskManager *manager = [NUTaskManager manager];
        [manager submitTask: initTask];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [nextUserManager unsubscribeFromAppStateNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogInfo(@"Did receive local notification: %@", notification);
    if ([nextUserManager isNextUserLocalNotification:notification]) {
        [nextUserManager handleLocalNotification:notification application:application];
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
    [nextUserManager requestLocationPersmissions];
}

- (void)requestNotificationPermissions
{
    [nextUserManager requestNotificationPermissionsForNotificationTypes:[nextUserManager allNotificationTypes]];
}

- (void)requestNotificationPermissionsForNotificationTypes:(UIUserNotificationType)types
{
    [nextUserManager requestNotificationPermissionsForNotificationTypes: types];
}


- (void)trackUser:(NUUser *)user
{
    [self setUser:user];
    DDLogInfo(@"Tracking user with identifier: %@", user.userIdentifier);
    [nextUserManager trackWithObject:user withType:(TRACK_USER)];
}

- (void)setUser:(NUUser *)user
{
    if (![nextUserManager getSession]) {
        return;
    }
    
    [nextUserManager getSession].user = user;
}

- (NSString *)currentUserIdenifier
{
    if (![nextUserManager getSession]) {
        return nil;
    }
    
    return [[nextUserManager getSession].user userIdentifier];
}

- (void)trackScreenWithName:(NSString *)screenName
{
    DDLogInfo(@"Track screen with name: %@", screenName);
    [nextUserManager trackWithObject:screenName withType:TRACK_SCREEN];
}

- (void)trackAction:(NUAction *)action
{
    DDLogInfo(@"Track action: %@", action);
    [nextUserManager trackWithObject:@[action] withType:TRACK_ACTION];
}

- (void)trackActions:(NSArray *)actions
{
    DDLogInfo(@"Track actions: %@", actions);
    [nextUserManager trackWithObject:actions withType:TRACK_ACTION];
}

- (void)trackPurchase:(NUPurchase *)purchase
{
    DDLogInfo(@"Track purchase: %@", purchase);
    [nextUserManager trackWithObject:@[purchase] withType:TRACK_PURCHASE];
}

- (void)trackPurchases:(NSArray *)purchases
{
    DDLogInfo(@"Track purchases: %@", purchases);
    [nextUserManager trackWithObject:purchases withType:TRACK_PURCHASE];
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
    
    [nextUserManager scheduleLocalNotificationForMessage:message];
}

@end
