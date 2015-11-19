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
#import "NUTracker+Tests.h"
#import "NUDDLog.h"
#import "AFNetworking.h"

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
    }
    
    return self;
}

#pragma mark - Initialization

- (void)startWithCompletion:(void (^)(NSError *error))completion
{
    if (!_session.startupRequestInProgress) {
        _session = [[NUTrackerSession alloc] init];
        [_session startWithCompletion:^(NSError *error) {
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
    [self trackActionWithName:actionName parameters:actionParameters completion:NULL];
}

+ (id)actionInfoWithName:(NSString *)actionName parameters:(NSArray *)actionParameters
{
    DDLogInfo(@"Action info with name: %@, parameters: %@", actionName, actionParameters);
    return [NUTrackingHTTPRequestHelper trackActionURLEntryWithName:actionName parameters:actionParameters];
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
    [self trackPurchaseWithTotalAmount:totalAmount products:products purchaseDetails:purchaseDetails completion:NULL];
}

#pragma mark - Private

- (BOOL)isValidSession
{
    return _session.deviceCookie != nil && _session.sessionCookie != nil;
}

#pragma mark - Track Generic

- (NSString *)trackRequestPathWithURLParameters:(NSMutableDictionary **)URLParameters
{
    // e.g. __nutm.gif?tid=wid+username&pv0=www.google.com
    NSString *path = [NUTrackingHTTPRequestHelper pathWithAPIName:@"__nutm.gif"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // add default parameters
    if ([self isValidSession]) {
        NSString *deviceCookieURLValue = [NSString stringWithFormat:@"...%@", _session.deviceCookie];
        parameters[@"nutm_s"] = deviceCookieURLValue;
        parameters[@"nutm_sc"] = _session.sessionCookie;
    }
    parameters[@"tid"] = @"internal_tests";
    
    if (URLParameters != NULL) {
        *URLParameters = parameters;
    }
    
    return path;
}

- (void)sendGETRequestWithPath:(NSString *)path
                    parameters:(NSDictionary *)parameters
                    completion:(void(^)(NSError *error))completion
{
    DDLogInfo(@"Fire HTTP GET request. Path: %@, Parameters: %@", path, parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:path
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             DDLogInfo(@"HTTP GET request response");
             DDLogInfo(@"URL: %@", operation.request.URL);
             DDLogInfo(@"Response: %@", responseObject);
             
             if (completion != NULL) {
                 completion(nil);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             DDLogError(@"HTTP GET request error");
             DDLogError(@"%@", operation.request.URL);
             DDLogError(@"%@", error);
             
             if (completion != NULL) {
                 completion(error);
             }
         }];
}

#pragma mark - Track Screen

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion
{
    NSMutableDictionary *parameters = nil;
    NSString *path = [self trackRequestPathWithURLParameters:&parameters];
    
    // e.g. /__nutm.gif?tid=internal_tests&nutm_s=...1446465312539000051&nutm_sc=1447343964091171821&pv0=http%3A//dev1_dot_nextuser_dot_com/%23%21/2/analytics/dashboard
    parameters[@"pv0"] = screenName;

    [self sendGETRequestWithPath:path parameters:parameters completion:completion];
}

#pragma mark - Track Action

- (void)trackActionWithName:(NSString *)actionName parameters:(NSArray *)actionParameters completion:(void(^)(NSError *error))completion
{
    [self trackActions:@[[NUTrackingHTTPRequestHelper trackActionURLEntryWithName:actionName parameters:actionParameters]] completion:completion];
}

- (void)trackActions:(NSArray *)actions completion:(void(^)(NSError *error))completion
{
    // max 10 actions are allowed
    if (actions.count > 10) {
        actions = [actions subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    NSMutableDictionary *parameters = nil;
    NSString *path = [self trackRequestPathWithURLParameters:&parameters];
    
    // e.g. /__nutm.gif?tid=internal_tests&nutm_s=...1446465312539000051&nutm_sc=1447343964091171821&a0=an_action,,,parameter_number_3&a1=other_action
    for (int i=0; i<actions.count; i++) {
        NSString *actionKey = [NSString stringWithFormat:@"a%d", i];
        NSString *actionValue = actions[i];
        
        parameters[actionKey] = actionValue;
    }
    
    [self sendGETRequestWithPath:path parameters:parameters completion:completion];
}

#pragma mark - Track Purchase

- (void)trackPurchaseWithTotalAmount:(double)totalAmount
                            products:(NSArray *)products
                     purchaseDetails:(NUPurchaseDetails *)purchaseDetails
                          completion:(void(^)(NSError *error))completion
{
    NSMutableDictionary *parameters = nil;
    NSString *path = [self trackRequestPathWithURLParameters:&parameters];
    
    parameters[@"pu0"] = [NUTrackingHTTPRequestHelper trackPurchaseParametersStringWithTotalAmount:totalAmount
                                                                                         products:products
                                                                                  purchaseDetails:purchaseDetails];
    
    [self sendGETRequestWithPath:path parameters:parameters completion:completion];
}

@end
