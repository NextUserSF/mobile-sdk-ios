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
#define kDeviceCookieJSONKey @"device_cookie"
#define kSessionCookieJSONKey @"session_cookie"
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

#pragma mark - Public API

- (id)init
{
    if (self = [super init]) {
        // this makes sure that we never migrate keychain data to another device (e.g. iTunes restore from backup)
        [SSKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
    }
    
    return self;
}

- (void)initialize:(void(^)(NSError *error))completion;
{
    DDLogInfo(@"Start tracker session");
    if (_sessionState != Initializing) {
        
        _sessionState = Initializing;
        _deviceCookie = nil;
        _sessionCookie = nil;
        _trackerProperties = [NUTrackerProperties properties];
        
        if ([_trackerProperties validProps] == NO) {
            @throw [NSException exceptionWithName:@"Tracker session start exception"
                                           reason:@"Invalid properties"
                                         userInfo:nil];
        }
        
        NSString *currentDeviceCookie = [self serializedDeviceCookie];
        NSDictionary *parameters = nil;
        NSString *path = [self sessionURLPathWithDeviceCookie:currentDeviceCookie URLParameters:&parameters];
        
        DDLogVerbose(@"Fire HTTP request to start the session. Path: %@, Parameters: %@", path, parameters);
        [NUHTTPRequestUtils sendGETRequestWithPath:path
                                        parameters:parameters
                                        completion:^(id responseObject, NSError *error) {
    
                                            if (error == nil) {
                                                
                                                DDLogVerbose(@"Start tracker session response: %@", responseObject);
                                                
                                                _deviceCookie = responseObject[kDeviceCookieJSONKey];
                                                _sessionCookie = responseObject[kSessionCookieJSONKey];
                                                if (_sessionCookie == nil) {
                                                    _sessionState = Failed;
                                                    DDLogError(@"Setup tracker error: %@", @"Server Error.");
                                                    if (completion != NULL) {
                                                        completion(nil);
                                                    }
                                                    
                                                    return;
                                                }
                                                
                                                _sessionState = Initialized;
                                                [self setupPushMessageServiceInfoWithSessionResponseObject:responseObject];
                                                
                                                // save new device cookie only if one does not already exists
                                                if (currentDeviceCookie == nil && _deviceCookie != nil) {
                                                    [self serializeDeviceCookie:_deviceCookie];
                                                }
                                                
                                                if (completion != NULL) {
                                                    completion(nil);
                                                }

                                            } else {
                                                
                                                DDLogError(@"Setup tracker error: %@", error);
                                                
                                                if (completion != NULL) {
                                                    completion(error);
                                                }
                                            }
                                        }];
    }
}

- (BOOL)isValid
{
    return _sessionState == Initialized;
}

#pragma mark -

- (void)setupPushMessageServiceInfoWithSessionResponseObject:(id)responseObject
{
    _shouldListenForPushMessages = YES;
    
    _pubNubConfiguration = [[NUPubNubConfiguration alloc] init];
    _pubNubConfiguration.publishKey = @"pub-c-ee9da834-a089-4b5e-9133-ac36b6e7bdb6";
    _pubNubConfiguration.subscribeKey = @"sub-c-77135d64-e6a9-11e5-b07b-02ee2ddab7fe";
    _pubNubConfiguration.privateChannel = @"Channel-Demo";
    _pubNubConfiguration.publicChannel = @"Channel-Demo";
}

#pragma mark - Private API

- (NSString *)sessionURLPathWithDeviceCookie:(NSString *)deviceCookie URLParameters:(NSDictionary **)URLParameters
{
    NSString *path = [self pathWithAPIName:@"sdk.js"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"tid"] = _trackerProperties.wid;
    if (deviceCookie) {
        parameters[@"dc"] = deviceCookie;
    }
    
    if (URLParameters != NULL) {
         *URLParameters = parameters;
    }
    
    return path;
}

#pragma mark - Serialization

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
    NSString *password = [SSKeychain passwordForService:[self keychainSerivceName] account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        DDLogError(@"Error while fetching device cookie from keychain. %@", error);
    }
    
    return password;
}

- (void)serializeDeviceCookie:(NSString *)deviceCookie
{
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

- (NULogLevel) logLevel
{
    if (_trackerProperties.isProduction) {
        return _trackerProperties.prodLogLevel;
    }
    
    return _trackerProperties.devLogLevel;
}

- (NSString *)basePath
{
    if (_trackerProperties.isProduction) {
        return END_POINT_PROD;
    }
    
    return END_POINT_DEV;
}

- (NSString *)pathWithAPIName:(NSString *)APIName
{
    return [[self basePath] stringByAppendingFormat:@"/%@", APIName];
}

@end
