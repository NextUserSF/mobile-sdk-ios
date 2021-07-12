//
//  NUConstants.h
//  Pods
//
//  Created by Adrian Lazea on 07.07.2021.
//

#import <Foundation/Foundation.h>

@interface NUConstants : NSObject

//Web View Related
extern NSString * const NEXTUSER_JS_BRIDGE;
extern NSString * const NU_WEB_VIEW_SCHEME;
extern NSString * const NU_URL_AUTHORITY_CLOSE;
extern NSString * const NU_URL_AUTHORITY_RELOAD;
extern NSString * const NU_PARAM_NAME_URL;
extern NSString * const NU_PARAM_NAME_EVENT;
extern NSString * const NU_PARAM_NAME_PARAMETERS;
extern NSString * const NU_PARAM_NAME_DATA;
extern NSString * const QUERY_PARAM_SOCIAL_NETWORK;
extern NSString * const QUERY_PARAM_DEEP_LINK;
extern NSString * const USER_CART_LAST_MODIFIED_KEY;
extern NSString * const USER_CART_LAST_TRACKED_KEY;

//External Events
extern NSString * const TRACKER_INITIALIZED;
extern NSString * const ON_TRACK_EVENT;
extern NSString * const ON_TRACK_SCREEN;
extern NSString * const ON_TRACK_PURCHASE;
extern NSString * const ON_TRACK_USER;
extern NSString * const ON_TTRACK_USER_VARIABLES;
extern NSString * const ON_SOCIAL_SHARE;

//Internal
extern NSString * const TRACK_PARAM_NUTMS;
extern NSString * const TRACK_PARAM_NUTMSC;
extern NSString * const TRACK_PARAM_VERSION;
extern NSString * const TRACK_PARAM_DEVICE_TYPE;
extern NSString * const TRACK_PARAM_DEVICE_TYPE_IOS;
extern NSString * const TRACK_PARAM_TID;
extern NSString * const TRACK_PARAM_DATA;
extern NSString * const TRACK_PARAM_DC;
extern NSString * const TRACK_PARAM_SC;
extern NSString * const TRACK_PARAM_API_KEY;
extern NSString * const TRACK_PARAM_DOT;
extern NSString * const TRACK_PARAM_PV;
extern NSString * const TRACK_PARAM_A;
extern NSString * const TRACK_PARAM_PU;
extern NSString * const TRACK_SUBSCRIBER_PARAM;
extern NSString * const TRACK_SUBSCRIBER_VARIABLE_PARAM;
extern NSString * const TRACK_SUBSCRIBER_DEVICE_PARAM;
extern NSString * const TRACK_DEVICE_PARAM;
extern NSString * const TRACKER_PROD;
extern NSString * const TRACKER_DEV;
extern NSString * const AI_PROD;
extern NSString * const AI_DEV;
extern NSString * const REGISTER_TOKEN_ENDPOINT;
extern NSString * const UNREGISTER_TOKEN_ENDPOINT;
extern NSString * const CHECK_EVENT_ENDPOINT;
extern NSString * const GET_IAM_ENDPOINT;
extern NSString * const TRACK_PARAM_TOKEN;
extern NSString * const TRACK_PARAM_TOKEN_PROVIDER;
extern NSString * const CHECK_EVENT_PARAM_EVENTS;
extern NSString * const CHECK_EVENT_PARAM_DC;
extern NSString * const CHECK_EVENT_PARAM_WKF_ID;
extern NSString * const CHECK_EVENT_PARAM_WID;
extern NSString * const CHECK_EVENT_PARAM_EMAIL;
extern NSString * const SESSION_INIT_ENDPOINT;
extern NSString * const TRACK_ENDPOINT;
extern NSString * const TRACK_COLLECT_ENDPOINT;
extern NSString * const IAMS_REQUEST_ENDPOINT;
extern NSString * const USER_TOKEN_KEY;
extern NSString * const USER_TOKEN_SUBMITTED_KEY;
extern NSString * const TRACK_VARIABLE_CART_STATE;
extern NSString * const TRACKING_SOURCE_NAME;

//tracker version
extern NSString * const TRACKER_VERSION;

@end
