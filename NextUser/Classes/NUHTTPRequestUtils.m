//
//  NUHTTPRequestUtils.m
//  NextUserKit
//
//  Created by NextUser on 11/25/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

@import AFNetworking;

#import "NUHTTPRequestUtils.h"
#import "NUDDLog.h"
#import "NSString+LGUtils.h"

@implementation NUHTTPRequestUtils

#pragma mark - HTTP Request

+ (void)sendGETRequestWithPath:(NSString *)path
                    parameters:(NSDictionary *)parameters
                    completion:(void (^)(id responseObject, NSError *error))completion
{
//    DDLogVerbose(@"Fire HTTP GET request. Path: %@, Parameters: %@", path, parameters);
    DDLogVerbose(@"");
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:path parameters:parameters error:nil];

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            DDLogError(@"HTTP GET request error");
            DDLogError(@"%@", request.URL);
            DDLogError(@"%@", error);
            
            if (completion != NULL) {
                completion(nil, error);
            }
        } else {
            DDLogVerbose(@"HTTP GET request response");
            DDLogVerbose(@"URL: %@", request.URL);
            DDLogVerbose(@"Response: %@", responseObject);
            
            if (completion != NULL) {
                completion(responseObject, nil);
            }
        }
    }];
    
    [dataTask resume];
}

@end
