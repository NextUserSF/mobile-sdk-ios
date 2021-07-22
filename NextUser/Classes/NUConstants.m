//
//  NUConstants.m
//  NextUser
//
//  Created by Adrian Lazea on 07.07.2021.
//

#import "NUConstants.h"

@implementation NUConstants

//webview
NSString * const NEXTUSER_JS_BRIDGE = @"nextuser_js_bridge";
NSString * const NU_PARAM_NAME_URL = @"url";
NSString * const NU_PARAM_NAME_EVENT = @"event";
NSString * const NU_PARAM_NAME_PARAMETERS = @"parameters";
NSString * const NU_PARAM_NAME_DATA = @"data";
NSString * const QUERY_PARAM_SOCIAL_NETWORK = @"social_network";
NSString * const QUERY_PARAM_DEEP_LINK = @"deep_link";
NSString * const USER_CART_LAST_MODIFIED_KEY= @"user_cart_last_modified";
NSString * const USER_CART_LAST_TRACKED_KEY= @"user_cart_last_tracked";
NSString * const LAST_BROWSED_LAST_MODIFIED_KEY= @"last_browsed_last_modified";
NSString * const LAST_BROWSED_LAST_TRACKED_KEY= @"last_browsed_last_tracked";

//internal
NSString * const TRACK_PARAM_NUTMS = @"nutm_s";
NSString * const TRACK_PARAM_NUTMSC = @"nutm_sc";
NSString * const TRACK_PARAM_VERSION = @"nuv";
NSString * const TRACK_PARAM_DEVICE_TYPE = @"mobile";
NSString * const TRACK_PARAM_DEVICE_TYPE_IOS = @"ios";
NSString * const TRACK_PARAM_TID = @"tid";
NSString * const TRACK_PARAM_DATA = @"data";
NSString * const TRACK_PARAM_DC = @"dc";
NSString * const TRACK_PARAM_SC = @"sc";
NSString * const TRACK_PARAM_API_KEY = @"api-key";
NSString * const TRACK_PARAM_DOT = @"_dot_";
NSString * const TRACK_PARAM_PV = @"pv0";
NSString * const TRACK_PARAM_A = @"a";
NSString * const TRACK_PARAM_PU = @"pu";
NSString * const TRACK_SUBSCRIBER_PARAM = @"s";
NSString * const TRACK_SUBSCRIBER_VARIABLE_PARAM = @"sv";
NSString * const TRACK_SUBSCRIBER_DEVICE_PARAM = @"sd";
NSString * const TRACK_DEVICE_PARAM = @"dt";
NSString * const TRACKER_PROD = @"https://track.nextuser.com";
NSString * const TRACKER_DEV = @"https://track-dev.nextuser.com";
NSString * const AI_PROD = @"https://ai.nextuser.com";
NSString * const AI_DEV = @"https://ai-dev.nextuser.com";
NSString * const REGISTER_TOKEN_ENDPOINT = @"/%@/%@/register";
NSString * const UNREGISTER_TOKEN_ENDPOINT = @"/%@/%@/unsubscribe";
NSString * const CHECK_EVENT_ENDPOINT = @"/%@/%@/mobile/iam/check-event";
NSString * const GET_IAM_ENDPOINT = @"/%@/%@/mobile/iam/get-message";
NSString * const TRACK_PARAM_TOKEN = @"token";
NSString * const TRACK_PARAM_TOKEN_PROVIDER = @"provider";
NSString * const CHECK_EVENT_PARAM_EVENTS = @"events";
NSString * const CHECK_EVENT_PARAM_DC = @"device_cookie";
NSString * const CHECK_EVENT_PARAM_WKF_ID = @"workflow_id";
NSString * const CHECK_EVENT_PARAM_WID = @"wid";
NSString * const CHECK_EVENT_PARAM_EMAIL = @"email";
NSString * const SESSION_INIT_ENDPOINT = @"/sdk.js";
NSString * const TRACK_ENDPOINT = @"/__nutm.gif";
NSString * const TRACK_COLLECT_ENDPOINT = @"/collect";
NSString * const IAMS_REQUEST_ENDPOINT = @"/m_wf.js";
NSString * const USER_TOKEN_KEY = @"user_token_key";
NSString * const USER_TOKEN_SUBMITTED_KEY = @"user_token_submitted_key";
NSString * const TRACK_VARIABLE_CART_STATE = @"cart_state";
NSString * const TRACK_VARIABLE_LAST_BROWSED  = @"last_browsed";
NSString * const TRACKING_SOURCE_NAME = @"nu.ios";
NSString * const TRACK_EVENT_DISPLAYED = @"_displayed";
NSString * const TRACK_EVENT_CLICKED = @"_clicked";
NSString * const TRACK_EVENT_DISMISSED = @"_dismissed";
NSString * const TRACK_EVENT_DELIVERD = @"_delivered";
NSString * const TRACK_EVENT_PURCHASE_COMPLETED = @"purchase_completed";
NSString * const TRACK_EVENT_IOS_SUBSCRIBED = @"ios_subscribed";
NSString * const TRACK_EVENT_VIEWED_PRODUCT = @"product_view";


//tracker version
NSString * const TRACKER_VERSION = @"2.0.0";

@end
