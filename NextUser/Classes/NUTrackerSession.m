//
//  NUTrackerSession.m
//  NextUserKit
//
//  Created by NextUser on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackerSession.h"
#import "NUTrackerProperties.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "NUDDLog.h"
#import "NUHTTPRequestUtils.h"
#import "SSKeychain.h"
#import "NSString+LGUtils.h"
#import "NULogLevel.h"

#pragma mark - Session Keys

#define kDeviceCookieSerializationKey @"nu_device_ide"

#define kKeychainServiceName @"com.nextuser.nextuserkit"

#pragma mark - PubNub Configuration

@interface NUPubNubConfiguration ()

@property (nonatomic) NSString *subscribeKey;
@property (nonatomic) NSString *publishKey;
@property (nonatomic) NSString *publicChannel;
@property (nonatomic) NSString *privateChannel;

@end

@implementation NUPubNubConfiguration
@end

#pragma mark - Tracker Session

@implementation NUTrackerSession

+ (instancetype) initializeWithProperties:(NUTrackerProperties *) trackerProperties
{
    NUTrackerSession *instance = [[NUTrackerSession alloc] init];
    instance.trackerProperties = trackerProperties;
    instance.sessionState = None;
    instance.deviceCookie = [instance serializedDeviceCookie];
    
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        [SSKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
    }
    
    return self;
}

- (NSString *) apiKey
{
    return [_trackerProperties apiKey];
}

- (void)setDeviceCookie:(NSString *)deviceCookie
{
    _deviceCookie = deviceCookie;
    
    NSAssert(deviceCookie, @"deviceCookie can not be nil");
    NSError *error = nil;
    [SSKeychain setPassword:deviceCookie forService:[self keychainSerivceName] account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        DDLogError(@"Error while setting device cookie in keychain. %@", error);
    }
}

- (void)clearSerializedDeviceCookie
{
    NSError *error = nil;
    [SSKeychain deletePasswordForService:[self keychainSerivceName] account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        DDLogError(@"Error while deleting device cookie from keychain. %@", error);
    }
}

- (NUSessionState) sessionState
{
    return _sessionState;
}

- (BOOL)isValid
{
    return _sessionState == Initialized;
}

- (NULogLevel) logLevel
{
    if (_trackerProperties.isProduction) {
        return _trackerProperties.prodLogLevel;
    }
    
    return _trackerProperties.devLogLevel;
}

- (NSString *)keychainSerivceName
{
    NSString *serviceName = kKeychainServiceName;
    
    NSString *appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    serviceName = [serviceName stringByAppendingFormat:@"_%@", appID];
    
    return serviceName;
}

- (NSString *)serializedDeviceCookie
{
    NSError *error = nil;
    NSString *password = [SSKeychain passwordForService:[self keychainSerivceName] account:kDeviceCookieSerializationKey
                                                  error:&error];
    if (error != nil) {
        DDLogError(@"Error while fetching device cookie from keychain. %@", error);
    }
    
    return password;
}

- (void)setupPushMessageServiceInfoWithSessionResponseObject:(id)responseObject
{
    _shouldListenForPushMessages = YES;
    
    _pubNubConfiguration = [[NUPubNubConfiguration alloc] init];
    _pubNubConfiguration.publishKey = @"pub-c-ee9da834-a089-4b5e-9133-ac36b6e7bdb6";
    _pubNubConfiguration.subscribeKey = @"sub-c-77135d64-e6a9-11e5-b07b-02ee2ddab7fe";
    _pubNubConfiguration.privateChannel = @"Channel-Demo";
    _pubNubConfiguration.publicChannel = @"Channel-Demo";
}

@end
