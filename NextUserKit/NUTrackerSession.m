//
//  NUTrackerSession.m
//  NextUserKit
//
//  Created by Dino on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackerSession.h"
#import "AFNetworking.h"

#define kDeviceCookieSerializationKey @"nu_device_cookie"
#define kSessionCookieSerializationKey @"nu_session_cookie"

#define kDeviceCookieJSONKey @"device_cookie"
#define kSessionCookieJSONKey @"session_cookie"


@implementation NUTrackerSession

#pragma mark - Public API

- (id)init
{
    if (self = [super init]) {
        _baseURLPath = @"https://track-dev.nextuser.com/sdk.js?tid=internal_tests";
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
        
        NSLog(@"Fire HTTP request to start the session");
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
    NSString *path = _baseURLPath;
    if (deviceCookie) {
        path = [path stringByAppendingFormat:@"&dc=%@", deviceCookie];
    }
    
    return path;
}

#pragma mark - Serialization

- (NSString *)serializedDeviceCookie
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceCookieSerializationKey];
}

- (void)serializeDeviceCookie:(NSString *)deviceCookie
{
    NSAssert(deviceCookie, @"deviceCookie can not be nil");
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceCookie forKey:kDeviceCookieSerializationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearSerializedDeviceCookie
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDeviceCookieSerializationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
