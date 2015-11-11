//
//  NUTrackerSession.m
//  NextUserKit
//
//  Created by Dino on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackerSession.h"
#import "AFNetworking.h"
#import "SSKeychain.h"

#define kDeviceCookieSerializationKey @"nu_device_ide"

#define kDeviceCookieJSONKey @"device_cookie"
#define kSessionCookieJSONKey @"session_cookie"

#define kKeychainServiceName @"com.nextuser.nextuserkit"

#define END_POINT_DEV @"https://track-dev.nextuser.com"
#define END_POINT_PROD @"https://track.nextuser.com/"


@implementation NUTrackerSession

#pragma mark - Public API

- (id)init
{
    if (self = [super init]) {
        _baseURLPath = END_POINT_DEV;
        
        // this makes sure that we never migrate keychain data to another device (e.g. iTunes restore from backup)
        [SSKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
    }
    
    return self;
}

- (void)startWithCompletion:(void(^)(NSError *error))completion
{
    NSLog(@"Start tracker session");
    if (!_setupRequestInProgress) {
        
        _setupRequestInProgress = YES;
        
        NSString *currentDeviceCookie = [self serializedDeviceCookie];
        NSString *path = [self sessionURLPathWithDeviceCookie:currentDeviceCookie];
        
        NSLog(@"Fire HTTP request to start the session: %@", path);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:path
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 NSLog(@"Setup tracker response: %@", responseObject);
                 
                 _setupRequestInProgress = NO;

                 _deviceCookie = responseObject[kDeviceCookieJSONKey];
                 _sessionCookie = responseObject[kSessionCookieJSONKey];
                 
                 // save new device cookie only if one does not already exists
                 if (currentDeviceCookie == nil && _deviceCookie != nil) {
                     [self serializeDeviceCookie:_deviceCookie];
                 }
                 
                 if (completion != NULL) {
                     completion(nil);
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 NSLog(@"Setup tracker error: %@", error);
                 
                 _setupRequestInProgress = NO;
                 
                 if (completion != NULL) {
                     completion(error);
                 }
             }];
    }
}

#pragma mark - Private API

- (NSString *)sessionURLPathWithDeviceCookie:(NSString *)deviceCookie
{
    // e.g. https://track-dev.nextuser.com/sdk.js?tid=internal_tests
    NSString *path = [_baseURLPath stringByAppendingString:@"/sdk.js?tid=internal_tests"];
    if (deviceCookie) {
        path = [path stringByAppendingFormat:@"&dc=%@", deviceCookie];
    }
    
    return path;
}

#pragma mark - Serialization

- (NSString *)serializedDeviceCookie
{
    NSError *error = nil;
    NSString *password = [SSKeychain passwordForService:kKeychainServiceName account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        NSLog(@"Error while fetching device identifier from keychain. %@", error);
    }
    
    return password;
}

- (void)serializeDeviceCookie:(NSString *)deviceCookie
{
    NSAssert(deviceCookie, @"deviceCookie can not be nil");
    
    NSError *error = nil;
    [SSKeychain setPassword:deviceCookie forService:kKeychainServiceName account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        NSLog(@"Error while setting device identifier in keychain. %@", error);
    }
}

- (void)clearSerializedDeviceCookie
{
    NSError *error = nil;
    [SSKeychain deletePasswordForService:kKeychainServiceName account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        NSLog(@"Error while deleting device identifier from keychain. %@", error);
    }
}

@end
