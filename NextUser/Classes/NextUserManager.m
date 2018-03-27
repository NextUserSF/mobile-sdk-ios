//
//  NUPrefetchTrackerClient.m
//  NextUserKit
//
//  Created by Dino on 2/10/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NextUserManager.h"
#import "NUHTTPRequestUtils.h"
#import "NUError.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"
#import "MF_Base64Additions.h"
#import "NUTrackerTask.h"
#import "NUTaskManager.h"
#import "NUTask.h"
#import "NUTrackerInitializationTask.h"
#import "NUSubscriberDevice.h"
#import "NUHardwareInfo.h"
#import "NURegistrationToken.h"

#define kDeviceCookieJSONKey @"device_cookie"
#define kSessionCookieJSONKey @"session_cookie"
#define kInstantWorkflowsJSONKey @"instant_workflows"

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface NextUserManager () <UNUserNotificationCenterDelegate>
@end
#endif

@interface PendingTask : NSObject
@property (nonatomic) id trackingObject;
@property (nonatomic) NUTaskType taskType;
@end

@implementation PendingTask
@end

@interface NextUserManager()
{
    NUTracker* tracker;
    NUTrackerSession *session;
    Reachability *reachability;
    NUPushMessageService *pushMessageService;
    NUAppWakeUpManager *wakeUpManager;
    WorkflowManager* workflowManager;
    InAppMsgCacheManager* inAppMessageCacheManager;
    InAppMsgUIManager* inAppMsgUIManager;
    InAppMsgImageManager* inAppMsgImageManager;
    NSMutableArray *pendingTrackRequests;
    NSLock *sessionRequestLock;
    BOOL disabled;
    BOOL initializationFailed;
    BOOL subscribedToAppStatusNotifications;
    BOOL inAppMessagesRequested;
}

-(void) trackSubscriberDevice;

@end

@implementation NextUserManager

NSString *const kGCMMessageIDKey = @"gcm.message_id";

+ (instancetype) sharedInstance
{
    static NextUserManager *instance;
    static dispatch_once_t instanceInitToken;
    dispatch_once(&instanceInitToken, ^{
        instance = [[NextUserManager alloc] init];
        NSArray * args = [[NSProcessInfo processInfo] arguments];
        if (![args containsObject:@"disableTTY"]) {
            [DDLog addLogger:[DDASLLogger sharedInstance]];
        } else {
            [DDLog addLogger:[DDTTYLogger sharedInstance]];
        }
    });
    
    return instance;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
        pendingTrackRequests = [NSMutableArray array];
        tracker = [[NUTracker alloc] init];
        initializationFailed = NO;
        inAppMessagesRequested = NO;
        disabled = NO;
        wakeUpManager = [NUAppWakeUpManager manager];
        wakeUpManager.delegate = self;
        sessionRequestLock = [[NSLock alloc] init];
        [self subscribeToAppStateNotificationsOnce];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTaskManagerNotification:)
                                                     name:COMPLETION_TASK_MANAGER_NOTIFICATION_NAME
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        
        
        reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
    }
    
    return self;
}

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions
{
    static dispatch_once_t appInitToken;
    dispatch_once(&appInitToken, ^{
        DDLogInfo(@"Did finish launching with options: %@", launchOptions);
        if (launchOptions != nil) {
            UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
            if (localNotification && [self isNextUserLocalNotification:localNotification]) {
                [self handleLocalNotification:localNotification application:application];
            }
        }
    
        [[NUTaskManager manager] submitTask: [[NUTrackerInitializationTask alloc] init]];
    });
}

-(NUTracker* ) getTracker
{
    return tracker;
}

-(NUTrackerSession *) getSession
{
    return session;
}

-(WorkflowManager *) workflowManager
{
    return workflowManager;
}

-(InAppMsgCacheManager *) inAppMsgCacheManager
{
    return inAppMessageCacheManager;
}


-(InAppMsgImageManager *) inAppMsgImageManager
{
    return inAppMsgImageManager;
}

-(InAppMsgUIManager *) inAppMsgUIManager
{
    return inAppMsgUIManager;
}

-(void)receiveTaskManagerNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    id<NUTaskResponse> taskResponse = userInfo[COMPLETION_NOTIFICATION_OBJECT_KEY];
    
    NUTaskType surfaceType = TASK_NO_TYPE;
    
    switch (taskResponse.taskType) {
        case APPLICATION_INITIALIZATION:
            [self onTrackerInitialization:taskResponse];
            return;
        case SESSION_INITIALIZATION:
            [self onSessionInitialization:taskResponse];
            surfaceType = SESSION_INITIALIZATION;
            break;
        case TRACK_USER:
        case TRACK_USER_VARIABLES:
        case TRACK_EVENT:
        case TRACK_PURCHASE:
        case TRACK_SCREEN:
            surfaceType = taskResponse.taskType;
            [self checkNetworkError: taskResponse];
            break;
        case REGISTER_DEVICE_TOKEN:
        case UNREGISTER_DEVICE_TOKENS:
            [session writeForKey:USER_TOKEN_SUBMITTED_KEY boolValue:[taskResponse successfull]];
            [self checkNetworkError: taskResponse];
            break;
        default:
            break;
    }
    
    if (surfaceType != TASK_NO_TYPE) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:[NSNumber numberWithBool:taskResponse.successfull ] forKey: NU_TRACK_RESPONSE];
        [dictionary setValue:[NSNumber numberWithInt:surfaceType] forKey: NU_TRACK_EVENT];
        [[NSNotificationCenter defaultCenter]
             postNotificationName:COMPLETION_NU_TRACKER_NOTIFICATION_NAME
             object:nil
             userInfo:dictionary];
    }
}

- (void) checkNetworkError: (NUTrackResponse *) response
{
    if ([response successfull] == NO) {
        NSInteger errorCode = [response.error code];
        if (errorCode == -1009 || errorCode == -1005 || errorCode == -1001) {
            [self queueTrackObject:response.trackObject withType:response.type];
        }
    }
}

-(void)onTrackerInitialization:(NUTrackerInitializationResponse *) response
{
    if ([response successfull]) {
        session = response.session;
        [self setLogLevel: [session logLevel]];
        initializationFailed = NO;
        [self requestSession];
    } else {
        initializationFailed = YES;
        DDLogError(@"Initialization Exception: %@", response.errorMessage);
    }
}

-(void)onSessionInitialization:(NUTrackResponse *)response
{
    if ([response successfull]) {
        
        NSError *errorJson=nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response.reponseData options:kNilOptions error:&errorJson];
        
        DDLogVerbose(@"Start tracker session response: %@", responseDict);
        session.sessionCookie = responseDict[kSessionCookieJSONKey];
        
        if (![session sessionCookie]) {
            [session setSessionState: Failed];
            DDLogError(@"Setup tracker error: %@", @"Server Error.");
            initializationFailed = YES;
            
            return;
        }
        
        initializationFailed = NO;
        
        [session setDeviceCookie: responseDict[kDeviceCookieJSONKey]];
        [session setInstantWorkflows: responseDict[kInstantWorkflowsJSONKey]];
        [session setSessionState: Initialized];
        [self trackSubscriberDevice];
        
        if (session.requestInAppMessages == YES) {
            inAppMessagesRequested = NO;
            [self initInAppMsgSessionManagers];
        } else {
            inAppMessagesRequested = YES;
        }
        
        [self sendPendingTrackRequests];
        
    } else {
        DDLogError(@"Setup tracker error: %@", response.error);
        [session setSessionState: Failed];
        initializationFailed = YES;
    }
}

-(void) trackSubscriberDevice
{
    NUSubscriberDevice *subDevice = [[NUSubscriberDevice alloc] init];
    subDevice.os = [NUHardwareInfo systemName];
    subDevice.osVersion = [NUHardwareInfo systemVersion];
    subDevice.trackingSource = @"nu.ios";
    subDevice.trackingVersion = TRACKER_VERSION;
    subDevice.deviceModel = [NSString stringWithFormat:@"Apple %@", [NUHardwareInfo systemDeviceTypeFormatted:YES]];
    subDevice.resolution = [NSString stringWithFormat:@"%ldx%ld", (long)[NUHardwareInfo screenWidth],(long)[NUHardwareInfo screenHeight]];
    NSBundle *bundle = [NSBundle mainBundle];
    subDevice.browser =[[bundle infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    subDevice.browserVersion = [[bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    subDevice.tablet = [subDevice.deviceModel containsString:@"Pad"];
    subDevice.mobile = !subDevice.tablet;
    
    [self trackWithObject:subDevice withType:TRACK_USER_DEVICE];
}

-(void) inAppMessagesRequested
{
    inAppMessagesRequested = YES;
    [self sendPendingTrackRequests];
}

-(void) initInAppMsgSessionManagers
{
    if (inAppMessageCacheManager == nil) {
        inAppMessageCacheManager = [InAppMsgCacheManager initWithCache:[[NUCache alloc] init]];
    }
    
    if (inAppMsgImageManager == nil) {
        inAppMsgImageManager = [InAppMsgImageManager initWithCache:[[NUCache alloc] init]];
    }
    
    if (inAppMsgUIManager == nil) {
        inAppMsgUIManager = [[InAppMsgUIManager alloc] init];
    }
    
    if (workflowManager == nil) {
        workflowManager = [WorkflowManager initWithSession:session];
    } else {
        workflowManager.session = session;
        [workflowManager requestInstantWorkflows: SESSION_INITIALIZATION];
    }
}


-(void)track:(id)trackObject withType:(NUTaskType) taskType
{
    NUTrackerTask *trackTask = [[NUTrackerTask alloc] initForType:taskType withTrackObject:trackObject withSession:session];
    [self submitTrackerTask:trackTask];
}

-(void)reachabilityChanged: (NSNotification*) notification
{
    if(reachability.currentReachabilityStatus != NotReachable) {
        if ([self validTracker] == NO) {
            [self requestSession];
            
            return;
        }
        
        [self sendPendingTrackRequests];
    }
}

-(BOOL)trackWithObject:(id)trackObject withType:(NUTaskType) taskType
{
    if (initializationFailed || disabled) {
        return NO;
    }
    
    if (![self validTracker] || !inAppMessagesRequested || reachability.currentReachabilityStatus == NotReachable) {
        DDLogWarn(@"Cannot sendTrackTask, session or network connection not available...");
        [self queueTrackObject:trackObject withType:taskType];
        
        return false;
    }
    
    [self track:trackObject withType:taskType];
    
    return YES;
}

-(void)submitTrackerTask:(NUTrackerTask *) trackTask
{
    NUTaskManager *manager = [NUTaskManager manager];
    [manager submitTask:trackTask];
}

-(BOOL)validTracker
{
    return session && [session isValid];
}

-(void)queueTrackObject:(id)trackObject withType:(NUTaskType) taskType
{
    if (pendingTrackRequests.count > 100) {
        return;
    }
    
    PendingTask *pendingTask = [PendingTask alloc];
    pendingTask.trackingObject = trackObject;
    pendingTask.taskType = taskType;
    [pendingTrackRequests addObject:pendingTask];
}

- (void)refreshPendingRequests
{
    [self sendPendingTrackRequests];
}

- (void)sendPendingTrackRequests
{
    while (pendingTrackRequests.count > 0) {
        PendingTask *pendingTask = pendingTrackRequests.firstObject;
        [pendingTrackRequests removeObjectAtIndex:0];
        
        DDLogVerbose(@"Popped request: %@", pendingTask);
        [self trackWithObject:pendingTask.trackingObject withType:pendingTask.taskType];
    }
}

-(void)requestSession
{
    if ([sessionRequestLock tryLock]) {
        @try
        {
            if (session && ([session sessionState] == None || [session sessionState] == Failed)) {
                [session setSessionState: Initializing];
                DDLogVerbose(@"Start tracker session for apikey: %@", [session apiKey]);
                [self track:nil withType:SESSION_INITIALIZATION];
            }
            
        } @catch (NSException *exception) {
            DDLogError(@"Request tracker session exception: %@", [exception reason]);
        } @finally {
            [sessionRequestLock unlock];
        }
    }
}

- (void)setLogLevel:(NSString *)logLevel
{
    DDLogLevel level;
    
    if ([NSString lg_isEmptyString:logLevel] || [logLevel isEqualToString:@"OFF"]) {
        level = DDLogLevelOff;
    } else if ([logLevel isEqualToString:@"ERROR"]) {
        level = DDLogLevelError;
    } else if ([logLevel isEqualToString:@"WARNING"]) {
        level = DDLogLevelWarning;
    } else if ([logLevel isEqualToString:@"INFO"]) {
        level = DDLogLevelInfo;
    } else if ([logLevel isEqualToString:@"VERBOSE"]) {
        level = DDLogLevelVerbose;
    } else {
        level = DDLogLevelOff;
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

- (void)subscribeToAppStateNotificationsOnce
{
    if (!subscribedToAppStatusNotifications) {
        subscribedToAppStatusNotifications = YES;
        
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{

}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{

}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{

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

#pragma mark - Push Message Service Delegate

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
    
    if (session.trackerProperties.notifications == NO) {
        return;
    }
    
    NSString *persistedUserToken = [session readStringValueForKey: USER_TOKEN_KEY];
    BOOL tokenSubmitted = [session readBoolValueForKey:USER_TOKEN_SUBMITTED_KEY];
    
    if (persistedUserToken != nil && [persistedUserToken isEqualToString:fcmToken] && tokenSubmitted == YES) {
        return;
    }
    
    [session writeForKey:USER_TOKEN_KEY stringValue:fcmToken];
    [self trackWithObject:deviceToken withType:REGISTER_DEVICE_TOKEN];
}

- (void)unregisterFCMRegistrationToken
{
    [session writeForKey:USER_TOKEN_KEY stringValue: nil];
    [session writeForKey:USER_TOKEN_SUBMITTED_KEY boolValue: NO];
    [self trackWithObject:nil withType:UNREGISTER_DEVICE_TOKENS];
}

-(void)requestNotificationsPermissions
{
    //Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        //iOS 8 or later
        if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber10_0) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else if (@available(iOS 10.0, *)) {
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            
            UNNotificationCategory* nextuserCategory = [UNNotificationCategory
                                                       categoryWithIdentifier:@"NextUser"
                                                       actions:@[]
                                                       intentIdentifiers:@[]
                                                       options:UNNotificationCategoryOptionCustomDismissAction];
            
            // Register the notification categories.
            
            [center setNotificationCategories:[NSSet setWithObjects:nextuserCategory, nil]];
            UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionCarPlay;
            [center requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted,
                                                                                                                                  NSError * _Nullable error) {
                if (granted == YES) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                }
            }];
        }
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler NS_AVAILABLE_IOS(10.0) {
    
    NSLog(@"willPresentNotification %@", notification);
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
           withCompletionHandler:(void(^)(void))completionHandler __IOS_AVAILABLE(10.0) {
    
    DDLogInfo(@"didReceiveNotificationResponse %@", response);
    //NSDictionary *userInfo = [[[[response notification] request] content] userInfo];
    //grab tracking actions
    
    if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
        // The user dismissed the notification without taking action.
        //track dismiss
        DDLogInfo(@"The user dismissed the notification without taking action %@", response);
    }
    else if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        // The user launched the app.
        //track clicked
        DDLogInfo(@"The user launched the app %@", response);
    }
    
    // Else handle any custom actions. . .
    completionHandler();
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //track delivered
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

- (BOOL)isNextUserLocalNotification:(UILocalNotification *)note
{
    return note.userInfo[kPushMessageLocalNoteTypeKey] != nil;
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

@end
