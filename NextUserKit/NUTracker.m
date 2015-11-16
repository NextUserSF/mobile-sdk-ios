//
//  NUTracker.m
//  NextUserKit
//
//  Created by Dino on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTracker.h"
#import "NUTrackerSession.h"
#import "NUAPIPathGenerator.h"
#import "NUTracker+Tests.h"
#import "NUDDLog.h"
#import "AFNetworking.h"

@interface NUTracker ()

// redefinition of public properties to be r&w (needed for KVO)
@property (nonatomic) BOOL isReady;

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
    _session = [[NUTrackerSession alloc] init];
    [_session startWithCompletion:^(NSError *error) {
        if (error == nil) {
            if (_session.sessionCookie != nil && _session.deviceCookie != nil) {
                self.isReady = YES;
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

#pragma mark - Track

- (void)trackScreenWithName:(NSString *)screenName
{
    DDLogInfo(@"Track screen with name: %@", screenName);
    [self trackScreenWithName:screenName completion:NULL];
}

#pragma mark - Private

- (void)updateParametersWithDefaults:(NSMutableDictionary *)parameters
{
    if ([self isValidSession]) {
        
        NSString *deviceCookieURLValue = [NSString stringWithFormat:@"...%@", _session.deviceCookie];
        parameters[@"nutm_s"] = deviceCookieURLValue;
        parameters[@"nutm_sc"] = _session.sessionCookie;
    }
}

- (BOOL)isValidSession
{
    return _session.deviceCookie != nil && _session.sessionCookie != nil;
}

#pragma mark - Track Screen

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion
{
    NSMutableDictionary *parameters = nil;
    NSString *path = [self trackScreen:screenName URLParameters:&parameters];
    [self updateParametersWithDefaults:parameters];
    
    DDLogInfo(@"Fire HTTP request to track screen. Path: %@, Parameters: %@", path, parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:path
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             DDLogInfo(@"Track screen response");
             DDLogInfo(@"%@", operation.request.URL);
             DDLogInfo(@"%@", responseObject);
             
             if (completion != NULL) {
                 completion(nil);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             DDLogError(@"Track screen error");
             DDLogError(@"%@", operation.request.URL);
             DDLogError(@"%@", error);

             if (completion != NULL) {
                 completion(error);
             }
         }];
}

- (NSString *)trackScreen:(NSString *)screenName URLParameters:(NSMutableDictionary **)URLParameters
{
    // e.g. __nutm.gif?tid=wid+username&pv0=www.google.com
    NSString *path = [NUAPIPathGenerator pathWithAPIName:@"__nutm.gif"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"tid"] = @"internal_tests";
    parameters[@"pv0"] = screenName;
    
    if (URLParameters != NULL) {
        *URLParameters = parameters;
    }
    
    return path;
}

@end
