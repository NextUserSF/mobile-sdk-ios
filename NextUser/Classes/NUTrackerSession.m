#import "NUTrackerSession.h"
#import "NUTrackerProperties.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "NUDDLog.h"
#import "NUKeyChainStore.h"
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
    UICKeyChainStore *keychain;
}

- (id)initWithProperties:(NUTrackerProperties *) properties
{
    if (self = [super init]) {
        _trackerProperties = properties;
        _sessionState = None;
        _requestInAppMessages = YES;
        keychain = [UICKeyChainStore keyChainStoreWithService: kKeychainServiceName];
        keychain.accessibility = UICKeyChainStoreAccessibilityAfterFirstUnlock;
        _deviceCookie = [self serializedDeviceCookie:keychain];
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
    NSAssert(dCookie, @"deviceCookie can not be nil");
    NSError *error;
    @try {
        [keychain setString:dCookie forKey:kDeviceCookieSerializationKey error:&error];
    } @catch (NSException *exception) {
        DDLogError(@"Exception while saving device cookie in keychain. %@", exception);
    } @finally {
        if (error) {
            DDLogError(@"Error while setting device cookie in keychain. %@", error);
        } else {
            _deviceCookie = dCookie;
        }
    }
}

- (void)clearSerializedDeviceCookie
{
    NSError *error;
    [keychain removeItemForKey:kDeviceCookieSerializationKey error:&error];
    if (error) {
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

- (NSString *)serializedDeviceCookie:(UICKeyChainStore*) store
{
    NSString *sdc = nil;
    @try {
        NSError *error;
        sdc = [keychain stringForKey: kDeviceCookieSerializationKey error:&error];
        if (error != nil) {
            DDLogError(@"Error while fetching device cookie from keychain. %@", error);
        }
    } @catch (NSException *exception) {
        DDLogError(@"Exception while fetching device cookie from keychain. %@", exception);
    } @finally {
        return sdc;
    }
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
    NSError *error;
    @try {
        [keychain setString:fcmToken forKey:kDeviceFCMTokenSerializationKey error:&error];
    } @catch (NSException *exception) {
        DDLogError(@"Exception while saving FCM token in keychain. %@", exception);
    } @finally {
        if (error) {
            DDLogError(@"Error while saving FCM token in keychain. %@", error);
        }
    }
}

- (void)clearFcmToken
{
    NSError *error;
    @try {
        [keychain removeItemForKey:kDeviceFCMTokenSerializationKey error:&error];
    } @catch (NSException *exception) {
        DDLogError(@"Exception while deleting FCM token in keychain. %@", exception);
    } @finally {
        if (error) {
            DDLogError(@"Error while deleting FCM token from keychain. %@", error);
        }
    }
}

- (NSString *)getdDeviceFCMToken
{
    NSError *error;
    NSString *fcmToken = nil;
    @try {
        fcmToken = [keychain stringForKey:kDeviceFCMTokenSerializationKey error:&error];
    } @catch (NSException *exception) {
        DDLogError(@"Exception while fetching FCM token from keychain. %@", exception);
    } @finally {
        if (error) {
            DDLogError(@"Error while fetching FCM token from keychain. %@", error);
        }
        
        return fcmToken;
    }
}

@end
