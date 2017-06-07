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


- (id)initWithProperties:(NUTrackerProperties *) properties
{
    if (self = [super init]) {
        _trackerProperties = properties;
        _sessionState = None;
        _deviceCookie = [self serializedDeviceCookie];
        [SSKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
    }
    
    return self;
}

- (NSString *) apiKey
{
    return [_trackerProperties apiKey];
}

- (void)setDeviceCookie:(NSString *) dCookie
{
   _deviceCookie = dCookie;
    NSAssert(_deviceCookie, @"deviceCookie can not be nil");
    NSError *error = nil;
    [SSKeychain setPassword:_deviceCookie forService:[self keychainSerivceName] account:kDeviceCookieSerializationKey error:&error];
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

-(NSString *)trackPath
{
    return [self pathWithAPIName:TRACK_ENDPOINT];
}

-(NSString *)sessionInitPath
{
    return [self pathWithAPIName:SESSION_INIT_ENDPOINT];
}

-(NSString *)trackDevicePath
{
    return [self pathWithAPIName:TRACK_DEVICE_ENDPOINT];
}

- (NSString *)basePath
{
    return _trackerProperties.isProduction ? TRACKER_PROD : TRACKER_DEV;
}

- (NSString *)pathWithAPIName:(NSString *)APIName
{
    return [[self basePath] stringByAppendingFormat:@"%@", APIName];
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
