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

#import "NUTrackingHTTPRequestHelper.h"
#import "NUHTTPRequestUtils.h"
#import "NUTracker+Tests.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"
#import "NSError+NextUser.h"

@interface NUTracker ()

@property (nonatomic) NUTrackerSession *session;
@property (nonatomic) NUPrefetchTrackerClient *prefetchClient;
@property (nonatomic) NUPushMessageService *pushMessageService;

@end

@implementation NUTracker

#pragma mark - Public API

static NUTracker *instance = nil;
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
        
        self.logLevel = NULogLevelWarning;
    }
    
    return self;
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
