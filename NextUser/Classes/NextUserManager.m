//
//  NUPrefetchTrackerClient.m
//  NextUserKit
//
//  Created by Dino on 2/10/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NextUserManager.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "NUHTTPRequestUtils.h"
#import "NSError+NextUser.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"
#import "Base64.h"
#import "NUTrackerTask.h"
#import "NUTaskManager.h"
#import "NUExecutionTask.h"
#import "NUTracker.h"

#define kDeviceCookieJSONKey @"device_cookie"
#define kSessionCookieJSONKey @"session_cookie"

@implementation NextUserManager

NSLock *sessionRequestLock;

#pragma mark - Factory

+ (instancetype)initialize
{
    NextUserManager *instance = [[NextUserManager alloc] init];
    instance.pendingTrackRequests = [NSMutableArray array];
    instance.initializationFailed = NO;
    instance.disabled = NO;
    instance.wakeUpManager = [NUAppWakeUpManager manager];
    instance.wakeUpManager.delegate = instance;
    
    return instance;
}

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    sessionRequestLock = [[NSLock alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTaskManagerTrackNotification:)
                                                 name:COMPLETION_TRACKER_NOTIFICATION_NAME
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _reachability = [Reachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    
    return self;
}

-(void)addSession:(NUTrackerSession*) session
{
    if (_session) {
        return;
    }
    
    _session = session;
    _helper = [NUTrackingHTTPRequestHelper createWithSession:session];
    [self requestSession];
}

-(void)receiveTaskManagerTrackNotification: (NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSObject *task = userInfo[COMPLETION_NOTIFICATION_OBJECT_KEY];
    
    if ([task class] != [NUTrackerTask class]) {
        return;
    }
    
    NUTrackerTask *trackerTask = (NUTrackerTask *)task;
    switch (trackerTask.taskType) {
        case SESSION_INITIALIZATION:
            [self onSessionInitialization:trackerTask];
            break;
        default:
            if ([trackerTask successfull]) {
                [self sendPendingTrackRequests];
            }
            break;
    }
}

-(void)reachabilityChanged: (NSNotification*) notification
{
    if(_reachability.currentReachabilityStatus != NotReachable) {
        
        [self requestSession];
        
    }
}

-(void)onSessionInitialization: (NUTrackerTask *)sesionStartTask
{
    if ([sesionStartTask successfull]) {
        
        NSError *errorJson=nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:sesionStartTask.responseObject options:kNilOptions error:&errorJson];
        
        DDLogVerbose(@"Start tracker session response: %@", responseDict);
        _session.sessionCookie = responseDict[kSessionCookieJSONKey];
        
        if (_session.sessionCookie == nil) {
            _session.sessionState = Failed;
            DDLogError(@"Setup tracker error: %@", @"Server Error.");
            
            return;
        }
        
        [_session setDeviceCookie: responseDict[kDeviceCookieJSONKey]];
        _session.sessionState = Initialized;
        if (_session.shouldListenForPushMessages) {
            [self connectPushMessageService];
        } else {
            [self disconnectPushMessageService];
        }
        [self sendPendingTrackRequests];
    } else {
        DDLogError(@"Setup tracker error: %@", sesionStartTask.error);
        _session.sessionState = Failed;
        _initializationFailed = YES;
    }
}

-(BOOL)trackWithObject:(id)trackObject withType:(NUTaskType) taskType
{
    if (_initializationFailed || _disabled) {
        return NO;
    }
    
    if (![self validTracker]) {
        DDLogVerbose(@"Cannot sendTrackTask, session or network connection not available...");
        [self queueTrackObject:trackObject withType:taskType];
        
        return false;
    }
    
    NUTrackerTask *trackTask = [self trackerTaskForType:taskType withPath:[_helper trackPath] withTrackObject:trackObject];
    if (!trackTask) {
        return NO;
    }
    
    [self submitTrackerTask:trackTask];
    
    return YES;
}

-(void)submitTrackerTask:(NUTrackerTask *) trackTask
{
    NUTaskManager *manager = [NUTaskManager sharedManager];
    [manager submitHttpTask:trackTask];

}

-(BOOL)validTracker
{
    return _session && [_session isValid];
}

-(void)queueTrackObject:(id)trackObject withType:(NUTaskType) taskType
{
    if (_pendingTrackRequests.count > 10) {
        return;
    }
    
    PendingTask *pendingTask = [PendingTask alloc];
    pendingTask.trackingObject = trackObject;
    pendingTask.taskType = taskType;
    [_pendingTrackRequests addObject:pendingTask];
}

-(NUTrackerTask*)trackerTaskForType:(NUTaskType) taskType withPath:(NSString *)path withTrackObject: (id)trackObject
{
    NSDictionary *params;
    
    switch (taskType) {
        case TRACK_SCREEN:
            params = [_helper trackScreenParametersWithScreenName: trackObject];
            break;
        case TRACK_ACTION:
            params = [_helper trackActionsParametersWithActions: trackObject];
            break;
        case TRACK_PURCHASE:
            params = [_helper trackPurchasesParametersWithPurchases: trackObject];
            break;
        case TRACK_USER:
            params = [_helper trackUserParametersWithVariables: trackObject];
            break;
        case SESSION_INITIALIZATION:
            params = [_helper sessionInitializationParameters];
        default:
            return nil;
    }
    
    return [NUTrackerTask createForType:taskType withPath:path withParameters:params];
}

- (void)refreshPendingRequests
{
    [self sendPendingTrackRequests];
}

- (void)sendPendingTrackRequests
{
    while (_pendingTrackRequests.count > 0) {
        PendingTask *pendingTask = _pendingTrackRequests.firstObject;
        [_pendingTrackRequests removeObjectAtIndex:0];
        
        DDLogVerbose(@"Popped request: %@", pendingTask);
        [self trackWithObject:pendingTask.trackingObject withType:pendingTask.taskType];
    }
}

-(void)requestSession
{
    if ([sessionRequestLock tryLock]) {
        @try
        {
            if (_session && ([_session sessionState] == None || [_session sessionState] == Failed)) {
                _session.sessionState = Initializing;
                DDLogVerbose(@"Start tracker session for sendTrackTask identifier: %@", [_session apiKey]);
                NUTrackerTask *sessionStartTask = [self trackerTaskForType:SESSION_INITIALIZATION withPath:[_helper sessionInitPath]
                                                           withTrackObject:nil];
                [self submitTrackerTask:sessionStartTask];
            }
            
        } @catch (NSException *exception) {
            DDLogError(@"Request tracker session exception: %@", [exception reason]);
        } @finally {
            [sessionRequestLock unlock];
        }
    }

}

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

- (void)requestNotificationPermissionsForNotificationTypes:(UIUserNotificationType)types
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [self userNotificationSettingsForNotificationTypes:types];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

-(void)requestLocationPersmissions
{
    [_wakeUpManager requestLocationUsageAuthorization];
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

#pragma mark - Notification Permissions

- (UIUserNotificationSettings *)userNotificationSettingsForNotificationTypes:(UIUserNotificationType)types
{
    return [UIUserNotificationSettings settingsForTypes:types categories:nil];
}

- (UIUserNotificationType)allNotificationTypes
{
    return  UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
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



@end


@implementation PendingTask
@end
