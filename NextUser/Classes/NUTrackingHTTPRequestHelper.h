//
//  NUTrackingHTTPRequestHelper.h
//  NextUserKit
//
//  Created by NextUser on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUUser.h"
#import "NUSubscriberDevice.h"
#import "NUTrackerSession.h"
#import "NUTask.h"
#import "NURegistrationToken.h"

#define TRACK_PARAM_NUTMS @"nutm_s"
#define TRACK_PARAM_NUTMSC @"nutm_sc"
#define TRACK_PARAM_VERSION @"nuv"
#define TRACK_PARAM_DEVICE_TYPE @"mobile"
#define TRACK_PARAM_DEVICE_TYPE_IOS @"ios"
#define TRACK_PARAM_TID @"tid"
#define TRACK_PARAM_DATA @"data"
#define TRACK_PARAM_DC @"dc"
#define TRACK_PARAM_SC @"sc"
#define TRACK_PARAM_API_KEY @"api-key"
#define TRACK_PARAM_DOT @"_dot_"
#define TRACK_PARAM_PV @"pv0"
#define TRACK_PARAM_A @"a"
#define TRACK_PARAM_PU @"pu"
#define TRACK_SUBSCRIBER_PARAM @"s"
#define TRACK_SUBSCRIBER_VARIABLE_PARAM @"sv"
#define TRACK_SUBSCRIBER_DEVICE_PARAM @"sd"
#define TRACK_DEVICE_PARAM @"dt"
#define TRACKER_VERSION @"1.1.3"
#define TRACKER_PROD @"https://track.nextuser.com"
#define TRACKER_DEV @"https://track-dev.nextuser.com"
#define AI_PROD @"https://ai.nextuser.com"
#define AI_DEV @"https://ai-dev.nextuser.com"
#define REGISTER_TOKEN_ENDPOINT @"/%@/%@/register"
#define UNREGISTER_TOKEN_ENDPOINT @"/%@/%@/unsubscribe"
#define TRACK_PARAM_TOKEN @"token"
#define TRACK_PARAM_TOKEN_PROVIDER @"provider"
#define SESSION_INIT_ENDPOINT @"/sdk.js"
#define TRACK_ENDPOINT @"/__nutm.gif"
#define TRACK_COLLECT_ENDPOINT @"/collect"
#define IAMS_REQUEST_ENDPOINT @"/m_wf.js"
#define USER_TOKEN_KEY @"user_token_key"
#define USER_TOKEN_SUBMITTED_KEY @"user_token_submitted_key"

@interface NUTrackingHTTPRequestHelper : NSObject

+(NSMutableDictionary *)trackScreenParametersWithScreenName:(NSString *)screenName;
+(NSMutableDictionary *)trackEventsParametersWithEvents:(NSArray *)actions;
+(NSMutableDictionary *)trackPurchasesParametersWithPurchases:(NSArray *)purchases;
+(NSMutableDictionary *)trackUserParametersWithVariables:(NUUser *)user;
+(NSMutableDictionary *)trackUserVariables:(NUUserVariables *)userVariables;
+(NSMutableDictionary *)sessionInitializationParameters:(NUTrackerSession*) session;
+(NSDictionary *)appendSessionDefaultParameters:(NUTrackerSession*) session withTrackParameters:(NSMutableDictionary*) parameters;
+(NSMutableDictionary *)trackUserDeviceParametersWithVariables:(NUSubscriberDevice *)userDevice;
+(NSString *) generateTid:(NUTrackerSession *) session;
+(NSMutableDictionary *) generateCollectDictionary:(NUTaskType) type withObject:(id) trackObject withSession:(NUTrackerSession *) session;
+(NSMutableDictionary *) generateDeviceTokenDictionary:(NURegistrationToken *) deviceToken;

@end
