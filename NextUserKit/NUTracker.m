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

@interface NUTracker ()

@property (nonatomic) NUTrackerSession *session;

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
    }
    
    return self;
}

#pragma mark - Initialization

- (void)startSessionWithTrackIdentifier:(NSString *)trackIdentifier completion:(void(^)(NSError *error))completion;
{
    if (!_session.startupRequestInProgress) {
        [_session startWithTrackIdentifier:trackIdentifier completion:^(NSError *error) {
            if (error == nil) {
                if (_session.sessionCookie != nil && _session.deviceCookie != nil) {
                    _isReady = YES;
                } else {
                    DDLogError(@"Missing cookies in session initialization response");
                    error = [NSError errorWithDomain:@"com.nextuser" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Missing cookies"}];
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
        case NULogLevelDebug: level = DDLogLevelDebug; break;
        case NULogLevelVerbose: level = DDLogLevelVerbose; break;
        case NULogLevelAll: level = DDLogLevelAll; break;
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
        case DDLogLevelDebug: level = NULogLevelDebug; break;
        case DDLogLevelVerbose: level = NULogLevelVerbose; break;
        case DDLogLevelAll: level = NULogLevelAll; break;
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

#pragma mark - Track Screen

- (void)trackScreenWithName:(NSString *)screenName
{
    DDLogInfo(@"Track screen with name: %@", screenName);
    [self trackScreenWithName:screenName completion:NULL];
}

#pragma mark - Track Action

- (void)trackActionWithName:(NSString *)actionName
{
    DDLogInfo(@"Track action with name: %@", actionName);
    [self trackActionWithName:actionName parameters:nil];
}

- (void)trackActionWithName:(NSString *)actionName parameters:(NSArray *)actionParameters
{
    DDLogInfo(@"Track action with name: %@, parameters: %@", actionName, actionParameters);
    NSArray *actions = @[[NUTrackingHTTPRequestHelper trackActionURLEntryWithName:actionName
                                                                       parameters:actionParameters]];
    [self trackActions:actions completion:NULL];
}

+ (id)actionInfoWithName:(NSString *)actionName parameters:(NSArray *)actionParameters
{
    DDLogInfo(@"Action info with name: %@, parameters: %@", actionName, actionParameters);
    return [self trackActionURLEntryWithName:actionName parameters:actionParameters];
}

- (void)trackActions:(NSArray *)actions
{
    DDLogInfo(@"Track multiple actions: %@", actions);
    [self trackActions:actions completion:NULL];
}

#pragma mark - Track Purchase

- (void)trackPurchaseWithTotalAmount:(double)totalAmount products:(NSArray *)products purchaseDetails:(NUPurchaseDetails *)purchaseDetails
{
    DDLogInfo(@"Track purchase with total amount: %f, products: %@, purchase details: %@", totalAmount, products, purchaseDetails);
    
    NSDictionary *parameters = @{@"pu0" : [NUTrackingHTTPRequestHelper trackPurchaseParametersStringWithTotalAmount:totalAmount
                                                                                                           products:products
                                                                                                    purchaseDetails:purchaseDetails]};
    [self sendTrackRequestWithParameters:parameters completion:NULL];
}

#pragma mark - Private API

#pragma mark -

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion
{
    NSDictionary *parameters = [NUTrackingHTTPRequestHelper trackScreenParametersWithScreenName:screenName];
    [self sendTrackRequestWithParameters:parameters completion:completion];
}

#pragma mark -

+ (NSString *)trackActionURLEntryWithName:(NSString *)actionName parameters:(NSArray *)actionParameters
{
    return [NUTrackingHTTPRequestHelper trackActionURLEntryWithName:actionName parameters:actionParameters];
}

- (void)trackActions:(NSArray *)actions completion:(void(^)(NSError *error))completion
{
    // max 10 actions are allowed
    if (actions.count > 10) {
        actions = [actions subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:actions.count];
    for (int i=0; i<actions.count; i++) {
        NSString *actionKey = [NSString stringWithFormat:@"a%d", i];
        NSString *actionValue = actions[i];
        
        parameters[actionKey] = actionValue;
    }
    
    [self sendTrackRequestWithParameters:parameters completion:completion];
}

#pragma mark - Track Generic

- (void)sendTrackRequestWithParameters:(NSDictionary *)trackParameters
                            completion:(void(^)(NSError *error))completion
{
    if (![self isSessionValid]) {
        DDLogWarn(@"Do not send track request, session is not valid.");
        return;
    }
    
    NSString *path = [NUTrackingHTTPRequestHelper pathWithAPIName:@"__nutm.gif"];
    NSMutableDictionary *parameters = [self defaultTrackingParameters:!_session.userIdentifierRegistered];
    
    // add track parameters
    for (id key in trackParameters.allKeys) {
        parameters[key] = trackParameters[key];
    }
    
    [NUHTTPRequestUtils sendGETRequestWithPath:path parameters:parameters completion:^(id responseObject, NSError *error) {
        
        // we want to make sure that request was successful and that we registered user identifier.
        // only if request was successful we will not send user identifier anymore
        if (error == nil) {
            if ([self.class hasSessionValidUserIdentifier:_session]) {
                _session.userIdentifierRegistered = YES;
            }
        }
        
        if (completion != NULL) {
            completion(error);
        }
    }];
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
