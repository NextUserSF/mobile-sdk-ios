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

#import "NSError+NextUser.h"
#import "NUDDLog.h"

#import "NUTracker+Tests.h"


@interface NUTracker () <NUAppWakeUpManagerDelegate>

@property (nonatomic) NUTrackerSession *session;
@property (nonatomic) NUPrefetchTrackerClient *prefetchClient;
@property (nonatomic) NUPushMessageService *pushMessageService;
@property (nonatomic) NUAppWakeUpManager *wakeUpManager;

@end

@implementation NUTracker

#pragma mark - Public API

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
//        _pushMessageService = [NUPushMessageServiceFactory createPushMessageServiceWithSession:_session];
        _wakeUpManager = [NUAppWakeUpManager manager];
        _wakeUpManager.delegate = self;
        
        
        //register local notifications
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
        
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
        
        self.logLevel = NULogLevelWarning;
    }
    
    return self;
}

#pragma mark - Application State Notifications

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    NSLog(@"Application did enter background");
    if (_session.isValid) {
        [_wakeUpManager start];
    }
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    NSLog(@"Application will terminate");
    if (_session.isValid) {
        [_wakeUpManager start];
    }}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    NSLog(@"Application did become active");
    [_wakeUpManager stop];
}

#pragma mark - App Wake Up Manager

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
                    
                    DDLogVerbose(@"Session startup finished, pop pending track request");
                    [_prefetchClient refreshPendingRequests];
                    
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

#pragma mark - Configuration

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

@end
