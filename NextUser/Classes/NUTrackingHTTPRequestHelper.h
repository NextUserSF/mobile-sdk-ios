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

#define TRACK_PARAM_NUTMS @"nutm_s"
#define TRACK_PARAM_NUTMSC @"nutm_sc"
#define TRACK_PARAM_VERSION @"nuv"
#define TRACK_PARAM_BUILD_VERSION @"version"
#define TRACK_PARAM_DEVICE_TYPE @"mobile"
#define TRACK_PARAM_DEVICE_TYPE_IOS @"ios"
#define TRACK_PARAM_TID @"tid"
#define TRACK_PARAM_DC @"dc"
#define TRACK_PARAM_DOT @"_dot_"
#define TRACK_PARAM_PV @"pv0"
#define TRACK_PARAM_A @"a"
#define TRACK_PARAM_PU @"pu"
#define TRACK_SUBSCRIBER_PARAM @"s"
#define TRACK_SUBSCRIBER_VARIABLE_PARAM @"sv"
#define TRACK_SUBSCRIBER_DEVICE_PARAM @"sd"
#define TRACK_DEVICE_PARAM @"dt"
#define TRACKER_VERSION @"1.0.0"
#define TRACKER_PROD @"https://track.nextuser.com"
#define TRACKER_DEV @"https://track-dev.nextuser.com"
#define SESSION_INIT_ENDPOINT @"/sdk.js"
#define TRACK_ENDPOINT @"/__nutm.gif"
#define TRACK_DEVICE_ENDPOINT @"/dt.js"
#define IAMS_REQUEST_ENDPOINT @"/m_wf.js"


@interface NUTrackingHTTPRequestHelper : NSObject

+(NSMutableDictionary *)trackScreenParametersWithScreenName:(NSString *)screenName;
+(NSMutableDictionary *)trackActionsParametersWithActions:(NSArray *)actions;
+(NSMutableDictionary *)trackPurchasesParametersWithPurchases:(NSArray *)purchases;
+(NSMutableDictionary *)trackUserParametersWithVariables:(NUUser *)user;
+(NSMutableDictionary *)sessionInitializationParameters:(NUTrackerSession*) session;
+(NSDictionary *)appendSessionDefaultParameters:(NUTrackerSession*) session withTrackParameters:(NSMutableDictionary*) parameters;
+(NSMutableDictionary *)trackUserDeviceParametersWithVariables:(NUSubscriberDevice *)userDevice;

@end
