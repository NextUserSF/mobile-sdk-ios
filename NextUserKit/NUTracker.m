//
//  NUTracker.m
//  NextUserKit
//
//  Created by Dino on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTracker.h"
#import "NUTrackerSession.h"
#import "NUTrackerUtils.h"
#import "NUTracker+Tests.h"
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
    [NUTrackerUtils trackScreenWithName:screenName inSession:_session completion:NULL];
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
    [NUTrackerUtils trackActionWithName:actionName parameters:actionParameters inSession:_session completion:NULL];
}

+ (id)actionInfoWithName:(NSString *)actionName parameters:(NSArray *)actionParameters
{
    DDLogInfo(@"Action info with name: %@, parameters: %@", actionName, actionParameters);
    return [NUTrackerUtils trackActionURLEntryWithName:actionName parameters:actionParameters];
}

- (void)trackActions:(NSArray *)actions
{
    DDLogInfo(@"Track multiple actions: %@", actions);
    [NUTrackerUtils trackActions:actions inSession:_session completion:NULL];
}

#pragma mark - Track Purchase

- (void)trackPurchaseWithTotalAmount:(double)totalAmount products:(NSArray *)products purchaseDetails:(NUPurchaseDetails *)purchaseDetails
{
    DDLogInfo(@"Track purchase with total amount: %f, products: %@, purchase details: %@", totalAmount, products, purchaseDetails);
    [NUTrackerUtils trackPurchaseWithTotalAmount:totalAmount products:products purchaseDetails:purchaseDetails inSession:_session completion:NULL];
}

@end
