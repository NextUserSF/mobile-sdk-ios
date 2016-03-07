//
//  NUPrefetchTrackerClient.m
//  NextUserKit
//
//  Created by Dino on 2/10/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUPrefetchTrackerClient.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "NUHTTPRequestUtils.h"
#import "NSError+NextUser.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"

@interface NUPrefetchTrackerClient ()

@property (nonatomic) NUTrackerSession *session;
@property (nonatomic) NSMutableArray *pendingTrackRequests; // waiting for session startup

@end

@implementation NUPrefetchTrackerClient

#pragma mark - Factory

+ (instancetype)clientWithSession:(NUTrackerSession *)session
{
    NUPrefetchTrackerClient *client = [[NUPrefetchTrackerClient alloc] init];
    client.session = session;
    client.pendingTrackRequests = [NSMutableArray array];
    
    return client;
}

#pragma mark - Public API

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion
{
    NSDictionary *parameters = [NUTrackingHTTPRequestHelper trackScreenParametersWithScreenName:screenName];
    [self sendTrackRequestWithParameters:parameters completion:completion];
}

- (void)trackActions:(NSArray *)actions completion:(void(^)(NSError *error))completion
{
    NSDictionary *parameters = [NUTrackingHTTPRequestHelper trackActionsParametersWithActions:actions];
    [self sendTrackRequestWithParameters:parameters completion:completion];
}

- (void)trackPurchases:(NSArray *)purchases completion:(void (^)(NSError *))completion
{
    NSDictionary *parameters = [NUTrackingHTTPRequestHelper trackPurchasesParametersWithPurchases:purchases];
    [self sendTrackRequestWithParameters:parameters completion:completion];
}

- (void)refreshPendingRequests
{
    [self popPendingTrackRequest];
}

#pragma mark - Private API

#pragma mark - Track Generic

- (void)sendTrackRequestWithParameters:(NSDictionary *)trackParameters
                            completion:(void(^)(NSError *error))completion
{
    DDLogInfo(@"Send track request");
    
    if ([self shouldPostponeTrackRequest]) {
        
        DDLogVerbose(@"Postpone track request sending. Session startup in progress.");
        
        [self addPostponedTrackRequestWithTrackParameters:trackParameters completion:completion];
        
    } else if ([_session isValid]) {
        
        NSString *path = [NUTrackingHTTPRequestHelper pathWithAPIName:@"__nutm.gif"];
        NSMutableDictionary *parameters = [self.class defaultTrackingParametersForSession:_session
                                                                    includeUserIdentifier:!_session.userIdentifierRegistered];
        
        // add track parameters
        for (id key in trackParameters.allKeys) {
            parameters[key] = trackParameters[key];
        }
        
        DDLogVerbose(@"Send track request with parameters: %@", parameters);
        [NUHTTPRequestUtils sendGETRequestWithPath:path parameters:parameters completion:^(id responseObject, NSError *error) {
            
            // we want to make sure that request was successful and that we registered user identifier.
            // only if request was successful we will not send user identifier anymore
            if (error == nil) {
                if ([self.class isUserIdentifierValidForSession:_session]) {
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

#pragma mark - Track Request Queue

- (BOOL)shouldPostponeTrackRequest
{
    return ![_session isValid] && _session.startupRequestInProgress;
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

#pragma mark - Utils

+ (NSMutableDictionary *)defaultTrackingParametersForSession:(NUTrackerSession *)session
                                       includeUserIdentifier:(BOOL)includeUserIdentifier
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([session isValid]) {
        parameters[@"nutm_s"] = [self deviceCookieParameterForSession:session];
        parameters[@"nutm_sc"] = session.sessionCookie;
        parameters[@"tid"] = [self trackIdentifierParameterForSession:session appendUserIdentifier:includeUserIdentifier];
        parameters[@"nuv"] = @"m1";
    }
    
    return parameters;
}

+ (NSString *)deviceCookieParameterForSession:(NUTrackerSession *)session
{
    return [NSString stringWithFormat:@"...%@", session.deviceCookie];
}

+ (NSString *)trackIdentifierParameterForSession:(NUTrackerSession *)session appendUserIdentifier:(BOOL)appendUserIdentifier
{
    NSString *trackIdentifier = session.trackIdentifier;
    if (appendUserIdentifier && [self isUserIdentifierValidForSession:session]) {
        trackIdentifier = [trackIdentifier stringByAppendingFormat:@"+%@", session.userIdentifier];
    }
    
    return trackIdentifier;
}

+ (BOOL)isUserIdentifierValidForSession:(NUTrackerSession *)session
{
    return ![NSString lg_isEmptyString:session.userIdentifier];
}

@end
