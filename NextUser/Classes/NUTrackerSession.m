
#import "NUTrackerSession.h"
#import "NUTrackerProperties.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "NUDDLog.h"
#import "SAMKeychain.h"
#import "NSString+LGUtils.h"
#import "NULogLevel.h"

#pragma mark - Session Keys
#define kDeviceCookieSerializationKey @"nu_device_ide"
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
        _requestInAppMessages = NO;
        _deviceCookie = [self serializedDeviceCookie];
        [SAMKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
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
    [SAMKeychain setPassword:_deviceCookie forService:[self keychainSerivceName] account:kDeviceCookieSerializationKey error:&error];
    if (error != nil) {
        DDLogError(@"Error while setting device cookie in keychain. %@", error);
    }
}

- (void)clearSerializedDeviceCookie
{
    NSError *error = nil;
    [SAMKeychain deletePasswordForService:[self keychainSerivceName] account:kDeviceCookieSerializationKey error:&error];
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
    NSString *password = [SAMKeychain passwordForService:[self keychainSerivceName] account:kDeviceCookieSerializationKey
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

- (BOOL) readBoolValueForKey: (NSString *) key
{
    return [preferences objectForKey:key] == nil ? NO : [preferences boolForKey:key];
}

- (NSString *) readStringValueForKey: (NSString *) key
{
    return [preferences objectForKey:key] == nil ? nil : [preferences stringForKey:key];
}

- (BOOL) writeForKey: (NSString *) key boolValue: (BOOL) value
{
    [preferences setBool:value forKey:key];
    
    return [preferences synchronize];
}

- (BOOL) writeForKey: (NSString *) key stringValue: (NSString *) value
{
    [preferences setValue:key forKey:key];
    
    return [preferences synchronize];
}

@end
