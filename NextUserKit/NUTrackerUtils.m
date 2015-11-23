//
//  NUTrackerUtils.m
//  NextUserKit
//
//  Created by Dino on 11/23/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackerUtils.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "NUDDLog.h"
#import "AFNetworking.h"

@implementation NUTrackerUtils

#pragma mark - Track Generic

+ (NSString *)trackRequestPathWithURLParameters:(NSMutableDictionary **)URLParameters inSession:(NUTrackerSession *)session
{
    // e.g. __nutm.gif?tid=wid+username&pv0=www.google.com
    NSString *path = [NUTrackingHTTPRequestHelper pathWithAPIName:@"__nutm.gif"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // add default parameters
    if ([self isSessionValid:session]) {
        NSString *deviceCookieURLValue = [NSString stringWithFormat:@"...%@", session.deviceCookie];
        parameters[@"nutm_s"] = deviceCookieURLValue;
        parameters[@"nutm_sc"] = session.sessionCookie;
    }
    parameters[@"tid"] = @"internal_tests";
    
    if (URLParameters != NULL) {
        *URLParameters = parameters;
    }
    
    return path;
}

+ (BOOL)isSessionValid:(NUTrackerSession *)session
{
    return session.deviceCookie != nil && session.sessionCookie != nil;
}

+ (void)sendGETRequestWithPath:(NSString *)path
                    parameters:(NSDictionary *)parameters
                    completion:(void(^)(NSError *error))completion
{
    DDLogInfo(@"Fire HTTP GET request. Path: %@, Parameters: %@", path, parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:path
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             DDLogInfo(@"HTTP GET request response");
             DDLogInfo(@"URL: %@", operation.request.URL);
             DDLogInfo(@"Response: %@", responseObject);
             
             if (completion != NULL) {
                 completion(nil);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             DDLogError(@"HTTP GET request error");
             DDLogError(@"%@", operation.request.URL);
             DDLogError(@"%@", error);
             
             if (completion != NULL) {
                 completion(error);
             }
         }];
}

#pragma mark - Track Screen

+ (void)trackScreenWithName:(NSString *)screenName inSession:(NUTrackerSession *)session completion:(void(^)(NSError *error))completion
{
    NSMutableDictionary *parameters = nil;
    NSString *path = [self trackRequestPathWithURLParameters:&parameters inSession:session];
    
    // e.g. /__nutm.gif?tid=internal_tests&nutm_s=...1446465312539000051&nutm_sc=1447343964091171821&pv0=http%3A//dev1_dot_nextuser_dot_com/%23%21/2/analytics/dashboard
    parameters[@"pv0"] = screenName;
    
    [self sendGETRequestWithPath:path parameters:parameters completion:completion];
}

#pragma mark - Track Action

+ (void)trackActionWithName:(NSString *)actionName parameters:(NSArray *)actionParameters inSession:(NUTrackerSession *)session completion:(void(^)(NSError *error))completion
{
    [self trackActions:@[[NUTrackingHTTPRequestHelper trackActionURLEntryWithName:actionName parameters:actionParameters]] inSession:(NUTrackerSession *)session completion:completion];
}

+ (NSString *)trackActionURLEntryWithName:(NSString *)actionName parameters:(NSArray *)actionParameters
{
    return [NUTrackingHTTPRequestHelper trackActionURLEntryWithName:actionName parameters:actionParameters];
}

+ (void)trackActions:(NSArray *)actions inSession:(NUTrackerSession *)session completion:(void(^)(NSError *error))completion
{
    // max 10 actions are allowed
    if (actions.count > 10) {
        actions = [actions subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    NSMutableDictionary *parameters = nil;
    NSString *path = [self trackRequestPathWithURLParameters:&parameters inSession:session];
    
    // e.g. /__nutm.gif?tid=internal_tests&nutm_s=...1446465312539000051&nutm_sc=1447343964091171821&a0=an_action,,,parameter_number_3&a1=other_action
    for (int i=0; i<actions.count; i++) {
        NSString *actionKey = [NSString stringWithFormat:@"a%d", i];
        NSString *actionValue = actions[i];
        
        parameters[actionKey] = actionValue;
    }
    
    [self sendGETRequestWithPath:path parameters:parameters completion:completion];
}

#pragma mark - Track Purchase

+ (void)trackPurchaseWithTotalAmount:(double)totalAmount
                            products:(NSArray *)products
                     purchaseDetails:(NUPurchaseDetails *)purchaseDetails
                           inSession:(NUTrackerSession *)session
                          completion:(void(^)(NSError *error))completion
{
    NSMutableDictionary *parameters = nil;
    NSString *path = [self trackRequestPathWithURLParameters:&parameters inSession:session];
    
    parameters[@"pu0"] = [NUTrackingHTTPRequestHelper trackPurchaseParametersStringWithTotalAmount:totalAmount
                                                                                          products:products
                                                                                   purchaseDetails:purchaseDetails];
    
    [self sendGETRequestWithPath:path parameters:parameters completion:completion];
}

@end
