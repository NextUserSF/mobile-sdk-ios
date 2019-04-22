#import "NUTrackingHTTPRequestHelper.h"
#import "NUEvent+Serialization.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"
#import "NUUser+Serialization.h"
#import "NUSubscriberDevice+Serialization.h"
#import "NUTrackerSession.h"
#import "MF_Base64Additions.h"
#import "NUCart+Serialization.h"

@implementation NUTrackingHTTPRequestHelper

+(NSMutableDictionary *)trackScreenParametersWithScreenName:(NSString *)screenName
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    parameters[TRACK_PARAM_PV] = [screenName URLEncodedString];
    
    return parameters;
}


+(NSMutableDictionary *)trackEventsParametersWithEvents:(NSArray<NUEvent*> *) events
{
    if (events.count > 10) {
        events = [events subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:events.count];
    for (int i=0; i < events.count; i++) {
        NSString *actionKey = [NSString stringWithFormat:TRACK_PARAM_A"%d", i];
        NSString *actionValue = [events[i] httpRequestParameterRepresentation];
        
        parameters[actionKey] = actionValue;
    }
    
    return parameters;
}


+(NSMutableDictionary *)trackCartParametersWithCart:(NUCart *)cart
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString *purchaseKey = [NSString stringWithFormat:TRACK_PARAM_PU"%d", 0];
    NSString *purchaseValue = [cart httpRequestParameterRepresentation];
    parameters[purchaseKey] = purchaseValue;
    
    return parameters;
}

+(NSMutableDictionary *)trackUserParametersWithVariables:(NUUser *)user {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[TRACK_SUBSCRIBER_PARAM] = [user httpRequestParameterRepresentation];
    if (user.nuUserVariables != nil) {
        [parameters addEntriesFromDictionary: [user.nuUserVariables toTrackingFormat]];
    }
    
    return parameters;
}

+(NSMutableDictionary *)trackUserVariables:(NUUserVariables *)userVariables
{
    if (userVariables == nil) {
        return nil;
    }
    
    return [userVariables toTrackingFormat];
}

+(NSMutableDictionary *)trackUserDeviceParametersWithVariables:(NUSubscriberDevice *)userDevice
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[TRACK_SUBSCRIBER_DEVICE_PARAM] = [userDevice httpRequestParameterRepresentation];
    
    return parameters;
}

+(NSDictionary *)sessionInitializationParameters:(NUTrackerSession*) session
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[TRACK_PARAM_TID] = [session apiKey];
    if ([session deviceCookie]) {
        parameters[TRACK_PARAM_DC] = [session deviceCookie];
    }
    
    return parameters;
}

+(NSString *) generateTid:(NUTrackerSession *) session
{
    NSString *tid = [session apiKey];
    if (session.user != nil && ![NSString lg_isEmptyString: session.user.userIdentifier]) {
        NSData *inputData = [session.user.userIdentifier dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Id = [inputData base64String];
        tid = [tid stringByAppendingFormat:@"+%@", base64Id];
    }
    
    return tid;
}

+(NSDictionary *)appendSessionDefaultParameters:(NUTrackerSession*) session withTrackParameters:(NSMutableDictionary*) parameters
{
    parameters[TRACK_PARAM_NUTMS] = [NSString stringWithFormat:@"...%@", [session deviceCookie]];
    parameters[TRACK_PARAM_NUTMSC] = [session sessionCookie];
    parameters[TRACK_PARAM_TID] = [self generateTid:session];
    parameters[TRACK_PARAM_VERSION] = TRACKER_VERSION;
    parameters[TRACK_PARAM_DEVICE_TYPE] = TRACK_PARAM_DEVICE_TYPE_IOS;
    
    return parameters;
}

+(NSMutableDictionary *) generateCollectDictionary:(NUTaskType) type withObject:(id) trackObject withSession:(NUTrackerSession *) session
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[TRACK_PARAM_VERSION] = TRACKER_VERSION;
    data[TRACK_PARAM_DEVICE_TYPE] = TRACK_PARAM_DEVICE_TYPE_IOS;
    
    switch (type) {
        case TRACK_SCREEN:
            [data addEntriesFromDictionary:[NUTrackingHTTPRequestHelper trackScreenParametersWithScreenName: trackObject]];
            break;
        case TRACK_EVENT:
            [data addEntriesFromDictionary:[NUTrackingHTTPRequestHelper trackEventsParametersWithEvents: trackObject]];
            break;
        case TRACK_PURCHASE:
            [data addEntriesFromDictionary:[NUTrackingHTTPRequestHelper trackCartParametersWithCart: trackObject]];
            break;
        case TRACK_USER:
            [data addEntriesFromDictionary:[NUTrackingHTTPRequestHelper trackUserParametersWithVariables: trackObject]];
            break;
        case TRACK_USER_VARIABLES:
            [data addEntriesFromDictionary:[NUTrackingHTTPRequestHelper trackUserVariables: trackObject]];
            break;
        case TRACK_USER_DEVICE:
            [data addEntriesFromDictionary:[NUTrackingHTTPRequestHelper trackUserDeviceParametersWithVariables: trackObject]];
            break;
        default:
            break;
    }
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    if (jsonData == nil) {
        return nil;
    }
    
    payload[TRACK_PARAM_DATA] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    payload[TRACK_PARAM_DC] = session.deviceCookie;
    payload[TRACK_PARAM_SC] = session.sessionCookie;
    payload[TRACK_PARAM_API_KEY] = session.apiKey;
    
    return payload;
}

+(NSMutableDictionary *) generateDeviceTokenDictionary:(NURegistrationToken *) deviceToken
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[TRACK_PARAM_TOKEN] = deviceToken.token;
    payload[TRACK_PARAM_TOKEN_PROVIDER] = deviceToken.provider;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    if (jsonData == nil) {
        return nil;
    }

    return payload;
}

+(NSMutableDictionary *) generateCheckEventDictionary: (id) trackObject withSession:(NUTrackerSession *) session
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    NSArray<NUEvent *> *events = (NSArray<NUEvent *> *) trackObject;
    NSMutableArray *eventNamesArray = [NSMutableArray array];
    for (int i = 0; i < events.count; i++) {
        eventNamesArray[i] = [events[i] eventName];
    }
    payload[CHECK_EVENT_PARAM_EVENTS] = eventNamesArray;
    payload[CHECK_EVENT_PARAM_DC] = [session deviceCookie];
    payload[CHECK_EVENT_PARAM_WID] = [session apiKey];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    if (jsonData == nil) {
        return nil;
    }
    
    return payload;
}

@end
