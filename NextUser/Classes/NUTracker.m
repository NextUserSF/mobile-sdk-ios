//
//  NUTracker.m
//  NextUserKit
//
//  Created by NextUser on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTracker.h"
#import "NUTrackerSession.h"
#import "NUPrefetchTrackerClient.h"
#import "NUPushMessageServiceFactory.h"
#import "NUAppWakeUpManager.h"
#import "NUPushMessage.h"
#import "NUIAMUITheme.h"
#import "NUInAppMessageManager.h"

#import "NSError+NextUser.h"
#import "NUDDLog.h"

#import "NUTracker+Tests.h"


#define kPushMessageLocalNoteTypeKey @"nu_local_note_type"
#define kPushMessageContentURLKey @"nu_content_url"
#define kPushMessageUIThemeDataKey @"nu_ui_theme_data"


@interface NUTracker () <NUAppWakeUpManagerDelegate, NUPushMessageServiceDelegate>

@property (nonatomic) NUTrackerSession *session;
@property (nonatomic) NUPrefetchTrackerClient *prefetchClient;
@property (nonatomic) NUPushMessageService *pushMessageService;

@property (nonatomic) NUAppWakeUpManager *wakeUpManager;
@property (nonatomic) BOOL subscribedToAppStatusNotifications;

@end

@implementation NUTracker

#pragma mark - Shared Tracker Setup

static NUTracker *instance;
+ (NUTracker *)sharedTracker
{
    if (instance == nil) {
        instance = [[NUTracker alloc] init];
    }
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        // setup logger
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        _session = [[NUTrackerSession alloc] init];
        _prefetchClient = [NUPrefetchTrackerClient clientWithSession:_session];
        
        // create app wake up manager (importat to create it in tracker initializer since
        // wake up manager listens for app finished launching notification)
        _wakeUpManager = [NUAppWakeUpManager manager];
        _wakeUpManager.delegate = self;
        
        self.logLevel = NULogLevelWarning;
    }
    
    return self;
}

- (void)dealloc
{
    [self unsubscribeFromAppStateNotifications];
}

#pragma mark - Local Notifications

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

- (NUPushMessage *)pushMessageFromLocalNotification:(UILocalNotification *)notification
{
    NUPushMessage *message = [[NUPushMessage alloc] init];
    message.messageText = notification.alertBody;
    message.contentURL = [NSURL URLWithString:notification.userInfo[kPushMessageContentURLKey]];
    message.UITheme = [NSKeyedUnarchiver unarchiveObjectWithData:notification.userInfo[kPushMessageUIThemeDataKey]];
    
    return message;
}

- (BOOL)isNextUserLocalNotification:(UILocalNotification *)note
{
    return note.userInfo[kPushMessageLocalNoteTypeKey] != nil;
}

#pragma mark -

- (void)scheduleLocalNotificationForMessage:(NUPushMessage *)message
{
    DDLogInfo(@"Schedule local note for message: %@", message);
    UILocalNotification *note = [self localNotificationFromPushMessage:message];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
}

- (void)handleLocalNotification:(UILocalNotification *)notification application:(UIApplication *)application
{
    if ([self isNextUserLocalNotification:notification]) {

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

#pragma mark - Notification Permissions

- (UIUserNotificationSettings *)userNotificationSettingsForNotificationTypes:(UIUserNotificationType)types
{
    return [UIUserNotificationSettings settingsForTypes:types categories:nil];
}

- (UIUserNotificationType)allNotificationTypes
{
    return  UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
}

#pragma mark - App State Subscribe/Unsubscribe

- (void)subscribeToAppStateNotificationsOnce
{
    if (!_subscribedToAppStatusNotifications) {
        _subscribedToAppStatusNotifications = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackgroundNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminateNotification:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
}

- (void)unsubscribeFromAppStateNotifications
{
    if (_subscribedToAppStatusNotifications) {
        _subscribedToAppStatusNotifications = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Application State Notifications

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    if (_session.shouldListenForPushMessages) {
        DDLogInfo(@"Application did enter background, start app wake up manager");
        [_wakeUpManager start];
    }
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    if (_session.shouldListenForPushMessages) {
        DDLogInfo(@"Application will terminate, start app wake up manager");
        [_wakeUpManager start];
    }
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    if (_session.shouldListenForPushMessages) {
        DDLogInfo(@"Application did become active, stop app wake up manager");
        [_wakeUpManager stop];
    }
}

#pragma mark - App Wake Up Manager Delegate

- (void)appWakeUpManager:(NUAppWakeUpManager *)manager didWakeUpAppInBackgroundWithTaskCompletion:(void (^)())completion
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

#pragma mark - Push Message Service Delegate

- (void)pushMessageService:(NUPushMessageService *)service didReceiveMessages:(NSArray *)messages
{
    // TODO: figure out scheduling logic. Schedule all messages or skip some of them if they are overlapping.
    for (NUPushMessage *message in messages) {
        [self scheduleLocalNotificationForMessage:message];
    }
}

#pragma mark - Push Messages Service Connect/Disconnect

- (void)connectPushMessageService
{
    // connect push service
    if (_pushMessageService != nil) {
        [_pushMessageService stopListening];
    }
    _pushMessageService = [NUPushMessageServiceFactory createPushMessageServiceWithSession:_session];
    _pushMessageService.delegate = self;
    [_pushMessageService startListening];
    
    [self subscribeToAppStateNotificationsOnce];
}

- (void)disconnectPushMessageService
{
    // disconnect push service
    if (_pushMessageService != nil) {
        [_pushMessageService stopListening];
    }
    _pushMessageService = nil;
    
    [self unsubscribeFromAppStateNotifications];
}

#pragma mark - Public API

#pragma mark - Setup

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DDLogInfo(@"Did finish launching with options: %@", launchOptions);
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification && [self isNextUserLocalNotification:localNotification]) {
        [self handleLocalNotification:localNotification application:application];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogInfo(@"Did receive local notification: %@", notification);
    if ([self isNextUserLocalNotification:notification]) {
        [self handleLocalNotification:notification application:application];
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
    [_wakeUpManager requestLocationUsageAuthorization];
}

- (void)requestNotificationPermissions
{
    [self requestNotificationPermissionsForNotificationTypes:[self allNotificationTypes]];
}

- (void)requestNotificationPermissionsForNotificationTypes:(UIUserNotificationType)types
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [self userNotificationSettingsForNotificationTypes:types];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

#pragma mark - Initialization

- (void)startSessionWithTrackIdentifier:(NSString *)trackIdentifier
{
    [self startSessionWithTrackIdentifier:trackIdentifier completion:nil];
}

- (void)startSessionWithTrackIdentifier:(NSString *)trackIdentifier completion:(void(^)(NSError *error))completion;
{
    if (trackIdentifier == nil || trackIdentifier.length == 0) {
        @throw [NSException exceptionWithName:@"Tracker session start exception"
                                       reason:@"Track identifier must be a non-empty string"
                                     userInfo:nil];
    }
    
    DDLogInfo(@"Start tracker session with identifier: %@", trackIdentifier);
    if (!_session.startupRequestInProgress) {
        [_session startWithTrackIdentifier:trackIdentifier completion:^(NSError *error) {
            if (error == nil) {
                if (_session.sessionCookie != nil && _session.deviceCookie != nil) {
                    
                    DDLogVerbose(@"Session startup finished, setup tracker");
                    
                    // send queued events
                    [_prefetchClient refreshPendingRequests];
                    
                    if (_session.shouldListenForPushMessages) {
                        [self connectPushMessageService];
                    } else {
                        [self disconnectPushMessageService];
                    }
                    
                } else {
                    DDLogError(@"Missing cookies in session initialization response");
                    error = [NSError nextUserErrorWithMessage:@"Missing cookies"];
                }
            } else {
                DDLogError(@"Error initializing tracker: %@", error);
            }
            
            if (completion != NULL) {
                completion(error);
            }
        }];
    } else {
        DDLogWarn(@"Startup session request already in progress");
    }
}

#pragma mark - Logging

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

#pragma mark - User Identification

- (void)identifyUserWithIdentifier:(NSString *)userIdentifier
{
    DDLogInfo(@"Identify user with identifer: %@", userIdentifier);
    _session.userIdentifier = userIdentifier;
    _session.userIdentifierRegistered = NO;
}

- (NSString *)currentUserIdenifier
{
    return _session.userIdentifier;
}

#pragma mark - Tracking

- (void)trackScreenWithName:(NSString *)screenName
{
    DDLogInfo(@"Track screen with name: %@", screenName);
    [_prefetchClient trackScreenWithName:screenName completion:NULL];
}

#pragma mark -

- (void)trackAction:(NUAction *)action
{
    DDLogInfo(@"Track action: %@", action);
    [_prefetchClient trackActions:@[action] completion:NULL];
}

- (void)trackActions:(NSArray *)actions
{
    DDLogInfo(@"Track actions: %@", actions);
    [_prefetchClient trackActions:actions completion:NULL];
}

#pragma mark -

- (void)trackPurchase:(NUPurchase *)purchase
{
    DDLogInfo(@"Track purchase: %@", purchase);
    [_prefetchClient trackPurchases:@[purchase] completion:NULL];
}

- (void)trackPurchases:(NSArray *)purchases
{
    DDLogInfo(@"Track purchases: %@", purchases);
    [_prefetchClient trackPurchases:purchases completion:NULL];
}

#pragma mark - Tracker + Tests Category

+ (void)releaseSharedInstance
{
    [DDLog removeAllLoggers];
    [instance.session clearSerializedDeviceCookie];
    instance = nil;
}

#pragma mark - Tracker + Dev Category

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
    
    [self scheduleLocalNotificationForMessage:message];
}

@end
