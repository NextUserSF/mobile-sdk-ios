#import "NUTrackerSession.h"
#import "NUTrackerProperties.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "NUDDLog.h"
#import "NUKeychain.h"
#import "NSString+LGUtils.h"
#import "NULogLevel.h"

#pragma mark - Session Keys
#define kDeviceCookieSerializationKey @"nu_device_ide"
#define kDeviceFCMTokenSerializationKey @"nu_device_fcm_token"
#define kKeychainServiceName @"nu.ios"


#pragma mark - Tracker Session
@implementation NUTrackerSession
{
    NSUserDefaults *preferences;
}

- (id)initWithProperties:(NUTrackerProperties *) properties
{
    if (self = [super init]) {
        _trackerProperties = properties;
        _sessionState = None;
        _requestInAppMessages = YES;
        _deviceCookie = [self serializedDeviceCookie];
        [NUKeychain setAccessibilityType:kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly];
        preferences = [NSUserDefaults standardUserDefaults];
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
    [NUKeychain setPassword:_deviceCookie forService:[self keychainSerivceName] account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        DDLogError(@"Error while setting device cookie in keychain. %@", error);
    }
}

- (void)clearSerializedDeviceCookie
{
    NSError *error = nil;
    [NUKeychain deletePasswordForService:[self keychainSerivceName] account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        DDLogError(@"Error while deleting device cookie from keychain. %@", error);
    }
}

- (BOOL)isValid
{
    return _sessionState == Initialized;
}

- (NSString *) logLevel
{
    if (_trackerProperties.production_release) {
        return _trackerProperties.log_level == nil ? @"ERROR" : _trackerProperties.log_level;
    }
    
    return @"VERBOSE";
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
    NSString *password = [NUKeychain passwordForService:[self keychainSerivceName] account:kDeviceCookieSerializationKey
                                                  error:&error];
    if (error != nil) {
        DDLogError(@"Error while fetching device cookie from keychain. %@", error);
    }
    
    return password;
}

-(NSString *)trackPath
{
    return [self trackerPathWithAPIName:TRACK_ENDPOINT];
}

-(NSString *)trackCollectPath
{
    return [self trackerPathWithAPIName:TRACK_COLLECT_ENDPOINT];
}

-(NSString *)sessionInitPath
{
    return [self trackerPathWithAPIName:SESSION_INIT_ENDPOINT];
}

-(NSString *)deviceTokenPath:(BOOL) isUnsubscribe
{
    NSString *url = isUnsubscribe == YES ?  [self aiPathWithAPIName: UNREGISTER_TOKEN_ENDPOINT] : [self aiPathWithAPIName: REGISTER_TOKEN_ENDPOINT];
    url = [NSString stringWithFormat:url, [_trackerProperties apiKey], _deviceCookie];
    
    return url;
}

-(NSString *)checkEventPath
{
    NSString *url = [self aiPathWithAPIName: CHECK_EVENT_ENDPOINT];
    url = [NSString stringWithFormat:url, [_trackerProperties apiKey], _deviceCookie];
    
    return url;
}

-(NSString *)getIAMPath: (NSString *) sha
{
   NSString *url = [NSString stringWithFormat:@"%@?%@=%@", [NSString stringWithFormat:[self aiPathWithAPIName: GET_IAM_ENDPOINT], [_trackerProperties apiKey], _deviceCookie], @"key", sha];
    
    return url;
}

- (NSString *)iamsRequestPath
{
    return [self trackerPathWithAPIName:IAMS_REQUEST_ENDPOINT];
}

- (NSString *)trackerBasePath
{
    return _trackerProperties.production_release ? TRACKER_PROD : TRACKER_DEV;
}

- (NSString *)trackerPathWithAPIName:(NSString *)APIName
{
    return [[self trackerBasePath] stringByAppendingFormat:@"%@", APIName];
}

- (NSString *)aiBasePath
{
    return _trackerProperties.production_release ? AI_PROD : AI_DEV;
}

- (NSString *)aiPathWithAPIName:(NSString *)APIName
{
    return [[self aiBasePath] stringByAppendingFormat:@"%@", APIName];
}

- (void)persistFCMToken:(NSString *) fcmToken
{
    NSError *error = nil;
    [NUKeychain setPassword:fcmToken forService:[self keychainSerivceName] account:kDeviceFCMTokenSerializationKey error:&error];
    if (error != nil) {
        DDLogError(@"Error while setting fcm token in keychain. %@", error);
    }
}

- (void)clearFcmToken
{
    NSError *error = nil;
    [NUKeychain deletePasswordForService:[self keychainSerivceName] account:kDeviceFCMTokenSerializationKey error:&error];
    if (error != nil) {
        DDLogError(@"Error while deleting fcm token from keychain. %@", error);
    }
}

- (NSString *)getdDeviceFCMToken
{
    NSError *error = nil;
    NSString *password = [NUKeychain passwordForService:[self keychainSerivceName] account:kDeviceFCMTokenSerializationKey
                                                   error:&error];
    if (error != nil) {
        DDLogError(@"Error while fetching fcm token from keychain. %@", error);
    }
    
    return password;
}

@end
