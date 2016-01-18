//
//  NUTracker.m
//  NextUserKit
//
//  Created by Dino on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTracker.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "NUHTTPRequestUtils.h"
#import "NUTracker+Tests.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"
#import "NSError+NextUser.h"

@interface NUTracker ()

@property (nonatomic) NUTrackerSession *session;
@property (nonatomic) NSMutableArray *pendingTrackRequests; // waiting for session startup

@end

@implementation NUTracker

#pragma mark - Public API

+ (NUTracker *)sharedTracker
{
    static NUTracker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NUTracker alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        // setup logger
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        _session = [[NUTrackerSession alloc] init];
        _pendingTrackRequests = [NSMutableArray array];
        
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
                    [self popPendingTrackRequest];
                    
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

#pragma mark - Private API

#pragma mark - Track Screen

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion
{
    NSDictionary *parameters = [NUTrackingHTTPRequestHelper trackScreenParametersWithScreenName:screenName];
    [self sendTrackRequestWithParameters:parameters completion:completion];
}

#pragma mark - Track Action

- (void)trackAction:(NUAction *)action completion:(void(^)(NSError *error))completion
{
    [self trackActions:@[action] completion:completion];
}

- (void)trackActions:(NSArray *)actions completion:(void(^)(NSError *error))completion
{
    NSDictionary *parameters = [NUTrackingHTTPRequestHelper trackActionsParametersWithActions:actions];
    [self sendTrackRequestWithParameters:parameters completion:completion];
}

#pragma mark - Track Purchase

- (void)trackPurchase:(NUPurchase *)purchase completion:(void(^)(NSError *error))completion
{
    [self trackPurchases:@[purchase] completion:completion];
}

- (void)trackPurchases:(NSArray *)purchases completion:(void(^)(NSError *error))completion
{
    NSDictionary *parameters = [NUTrackingHTTPRequestHelper trackPurchasesParametersWithPurchases:purchases];
    [self sendTrackRequestWithParameters:parameters completion:completion];
}

#pragma mark - Track Generic

- (void)sendTrackRequestWithParameters:(NSDictionary *)trackParameters
                            completion:(void(^)(NSError *error))completion
{
    DDLogInfo(@"Send track request");
    
    if ([self shouldPostponeTrackRequest]) {
    
        DDLogVerbose(@"Postpone track request sending. Session startup in progress.");
        
        [self addPostponedTrackRequestWithTrackParameters:trackParameters completion:completion];
        
    } else if ([self isSessionValid]) {

        NSString *path = [NUTrackingHTTPRequestHelper pathWithAPIName:@"__nutm.gif"];
        NSMutableDictionary *parameters = [self defaultTrackingParameters:!_session.userIdentifierRegistered];
        
        // add track parameters
        for (id key in trackParameters.allKeys) {
            parameters[key] = trackParameters[key];
        }
                
        DDLogVerbose(@"Send track request with parameters: %@", parameters);
        [NUHTTPRequestUtils sendCustomSerializedQueryParametersGETRequestWithPath:path parameters:parameters completion:^(id responseObject, NSError *error) {
            
            // we want to make sure that request was successful and that we registered user identifier.
            // only if request was successful we will not send user identifier anymore
            if (error == nil) {
                if ([self.class hasSessionValidUserIdentifier:_session]) {
                    _session.userIdentifierRegistered = YES;
                }
                
                DDLogVerbose(@"Track request finished, pop pending track request.");
                [self popPendingTrackRequest];
            } else {
                DDLogError(@"Track request error: %@", error);
                DDLogError(@"Response: %@", responseObject);
            }
            
            if (completion != NULL) {
                completion(error);
            }
        }];
    } else {
        
        DDLogWarn(@"Ignore track request sending, session not valid.");
        NSError *error = [NSError nextUserErrorWithMessage:@"Session not valid. Will not send tracking request."];
        if (completion != NULL) {
            completion(error);
        }
    }
}

- (BOOL)shouldPostponeTrackRequest
{
    return ![self isSessionValid] && _session.startupRequestInProgress;
}

- (void)addPostponedTrackRequestWithTrackParameters:(NSDictionary *)trackParameters completion:(void(^)(NSError *error))completion
{
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    requestInfo[@"url_parameters"] = trackParameters;
    if (completion != NULL) {
        requestInfo[@"completion_block"] = [completion copy];
    }
    
    [_pendingTrackRequests addObject:requestInfo];
}

- (void)popPendingTrackRequest
{
    if (_pendingTrackRequests.count > 0) {
        NSDictionary *requestInfo = _pendingTrackRequests.firstObject;
        [_pendingTrackRequests removeObjectAtIndex:0];
        
        DDLogVerbose(@"Popped request: %@", requestInfo);
        
        NSDictionary *trackParameters = requestInfo[@"url_parameters"];
        void(^completion)(NSError *error) = requestInfo[@"completion_block"];
        [self sendTrackRequestWithParameters:trackParameters completion:completion];
    }
}

#pragma mark -

- (NSMutableDictionary *)defaultTrackingParameters:(BOOL)includeUserIdentifier
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([self isSessionValid]) {
        parameters[@"nutm_s"] = [NUTracker deviceCookieParameterForSession:_session];
        parameters[@"nutm_sc"] = _session.sessionCookie;
        parameters[@"tid"] = [NUTracker trackIdentifierParameterForSession:_session appendUserIdentifier:includeUserIdentifier];
    }
    
    return parameters;
}

- (BOOL)isSessionValid
{
    return ![NSString isEmptyString:_session.deviceCookie] &&
    ![NSString isEmptyString:_session.sessionCookie] &&
    ![NSString isEmptyString:_session.trackIdentifier];
}

#pragma mark -

+ (NSString *)deviceCookieParameterForSession:(NUTrackerSession *)session
{
    return [NSString stringWithFormat:@"...%@", session.deviceCookie];
}

+ (NSString *)trackIdentifierParameterForSession:(NUTrackerSession *)session appendUserIdentifier:(BOOL)appendUserIdentifier
{
    NSString *trackIdentifier = session.trackIdentifier;
    if (appendUserIdentifier && [self hasSessionValidUserIdentifier:session]) {
        trackIdentifier = [trackIdentifier stringByAppendingFormat:@"+%@", session.userIdentifier];
    }
    
    return trackIdentifier;
}

+ (BOOL)hasSessionValidUserIdentifier:(NUTrackerSession *)session
{
    return ![NSString isEmptyString:session.userIdentifier];
}

@end
