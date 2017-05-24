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
#import "NUTrackerTask.h"


@implementation NUTracker

NextUserManager *nextUserManager;
BOOL initialized;
static NUTracker *instance;

+ (instancetype)sharedTracker
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NUTracker alloc] init];
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        nextUserManager = [[NextUserManager alloc] initManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(receiveTaskManagerCustomNotification:)
                                                     name:COMPLETION_CUSTOM_NOTIFICATION_NAME
                                                   object:nil];
    });
    
    return instance;
}

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
{
    if (initialized) {
        DDLogWarn(@"NextUser Tracker already initialized...");
        
        return;
    }
    
    initialized = YES;
    DDLogInfo(@"Did finish launching with options: %@", launchOptions);
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification && [nextUserManager isNextUserLocalNotification:localNotification]) {
        [nextUserManager handleLocalNotification:localNotification application:application];
    }
    
    [self dispatchInitializationTask];
}

-(void) dispatchInitializationTask
{
    NUTrackerInitializationTask *initTask = [[NUTrackerInitializationTask alloc] init];
    NUTaskManager *manager = [NUTaskManager sharedManager];
    [manager addOperation:initTask];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [nextUserManager unsubscribeFromAppStateNotifications];
}

-(void)receiveTaskManagerCustomNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    __weak NSObject *task = userInfo[COMPLETION_NOTIFICATION_OBJECT_KEY];
    
    if ([task class] == [NUTrackerInitializationTaskResponse class]) {
        __weak NUTrackerInitializationTaskResponse *initResponse = (NUTrackerInitializationTaskResponse *)task;
        [self onInitialization:initResponse];
        
        return;
    }
}

-(void)onInitialization:(NUTrackerInitializationTaskResponse *) initResponse
{
    if ([initResponse successfull]) {
        NUTrackerSession *session = initResponse.responseObject;
        [self setLogLevel: [session logLevel]];
        [nextUserManager addSession:session];
    } else {
        nextUserManager.initializationFailed = YES;
        DDLogError(@"Initialization Exception: %@", initResponse.error);
    }
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

- (void)setLogLevel:(NULogLevel)logLevel
{
    DDLogLevel level = DDLogLevelOff;
    switch (logLevel) {
        case NULogLevelOff: level = DDLogLevelOff; break;
        case NULogLevelError: level = DDLogLevelError; break;
        case NULogLevelWarning: level = DDLogLevelWarning; break;
        case NULogLevelInfo: level = DDLogLevelInfo; break;
        case NULogLevelVerbose: level = DDLogLevelVerbose; break;
    }
    
    [NUDDLog setLogLevel:level];
}

- (NULogLevel)logLevel
{
    DDLogLevel logLevel = [NUDDLog logLevel];
    NULogLevel level = NULogLevelOff;
    switch (logLevel) {
        case DDLogLevelOff: level = NULogLevelOff; break;
        case DDLogLevelError: level = NULogLevelError; break;
        case DDLogLevelWarning: level = NULogLevelWarning; break;
        case DDLogLevelInfo: level = NULogLevelInfo; break;
        case DDLogLevelDebug: level = NULogLevelInfo; break;
        case DDLogLevelVerbose: level = NULogLevelVerbose; break;
        case DDLogLevelAll: level = NULogLevelVerbose; break;
    }
    
    return level;
}

- (void)trackUser:(NUUser *)user
{
    if (!nextUserManager.session) {
        return;
    }
    
    DDLogInfo(@"Tracking user with identifier: %@", user.userIdentifier);
    [self setUser:user];
    [nextUserManager trackWithObject:user withType:(TRACK_USER)];
}

- (void)setUser:(NUUser *)user
{
    if (!nextUserManager.session) {
        return;
    }
    
    nextUserManager.session.user = user;
}

- (NSString *)currentUserIdenifier
{
    if (!nextUserManager.session) {
        return nil;
    }
    
    return [nextUserManager.session.user userIdentifier];
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
    instance = nil;
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
