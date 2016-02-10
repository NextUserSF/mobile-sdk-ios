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

#import "NUTrackingHTTPRequestHelper.h"
#import "NUHTTPRequestUtils.h"
#import "NUTracker+Tests.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"
#import "NSError+NextUser.h"

@interface NUTracker ()

@property (nonatomic) NUTrackerSession *session;
@property (nonatomic) NUPrefetchTrackerClient *prefetchTrackerClient;

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
        _prefetchTrackerClient = [NUPrefetchTrackerClient clientWithSession:_session];
        
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
                    [_prefetchTrackerClient refreshPendingRequests];
                    
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

#pragma mark - Track Screen

- (void)trackScreenWithName:(NSString *)screenName
{
    DDLogInfo(@"Track screen with name: %@", screenName);
    [self trackScreenWithName:screenName completion:NULL];
}

#pragma mark - Track Action

- (void)trackAction:(NUAction *)action
{
    DDLogInfo(@"Track action: %@", action);
    [self trackAction:action completion:NULL];
}

- (void)trackActions:(NSArray *)actions
{
    DDLogInfo(@"Track actions: %@", actions);
    [self trackActions:actions completion:NULL];
}

#pragma mark - Track Purchase

- (void)trackPurchase:(NUPurchase *)purchase
{
    DDLogInfo(@"Track purchase: %@", purchase);
    [self trackPurchase:purchase completion:NULL];
}

- (void)trackPurchases:(NSArray *)purchases
{
    DDLogInfo(@"Track purchases: %@", purchases);
    [self trackPurchases:purchases completion:NULL];
}

#pragma mark - Tracker + Tests Category

+ (void)releaseSharedInstance
{
    [instance.session clearSerializedDeviceCookie];
    instance = nil;
}

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion
{
    [_prefetchTrackerClient trackScreenWithName:screenName completion:completion];
}

- (void)trackAction:(NUAction *)action completion:(void(^)(NSError *error))completion
{
    [self trackActions:@[action] completion:completion];
}

- (void)trackActions:(NSArray *)actions completion:(void(^)(NSError *error))completion
{
    [_prefetchTrackerClient trackActions:actions completion:completion];
}

- (void)trackPurchase:(NUPurchase *)purchase completion:(void(^)(NSError *error))completion
{
    [self trackPurchases:@[purchase] completion:completion];
}

- (void)trackPurchases:(NSArray *)purchases completion:(void(^)(NSError *error))completion
{
    [_prefetchTrackerClient trackPurchases:purchases completion:completion];
}

@end
