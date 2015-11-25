//
//  NUHTTPRequestUtils.m
//  NextUserKit
//
//  Created by Dino on 11/25/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUHTTPRequestUtils.h"
#import "NUDDLog.h"
#import "AFNetworking.h"

@implementation NUHTTPRequestUtils

#pragma mark - HTTP Request

+ (void)sendHTTPGETRequestWithPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
                        completion:(void (^)(id responseObject, NSError *error))completion
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
                 completion(responseObject, nil);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             DDLogError(@"HTTP GET request error");
             DDLogError(@"%@", operation.request.URL);
             DDLogError(@"%@", error);
             
             if (completion != NULL) {
                 completion(nil, error);
             }
         }];
}

@end
