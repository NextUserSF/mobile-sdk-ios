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
#import "NSString+LGUtils.h"

@implementation NUHTTPRequestUtils

#pragma mark - HTTP Request

+ (void)sendCustomSerializedQueryParametersGETRequestWithPath:(NSString *)path
                                                   parameters:(NSDictionary *)parameters
                                                   completion:(void (^)(id, NSError *))completion
{
    DDLogVerbose(@"Fire NextUser API HTTP GET request. Path: %@, Parameters: %@", path, parameters);

    [self sendGETRequestWithPath:path
                      parameters:parameters
     useNextUserAPIQueryEncoding:YES
                      completion:completion];
}

+ (void)sendGETRequestWithPath:(NSString *)path
                    parameters:(NSDictionary *)parameters
                    completion:(void (^)(id responseObject, NSError *error))completion
{
    DDLogVerbose(@"Fire HTTP GET request. Path: %@, Parameters: %@", path, parameters);
    
    [self sendGETRequestWithPath:path
                      parameters:parameters
     useNextUserAPIQueryEncoding:NO
                      completion:completion];
}

#pragma mark - Private

+ (void)sendGETRequestWithPath:(NSString *)path
                    parameters:(NSDictionary *)parameters
   useNextUserAPIQueryEncoding:(BOOL)useNextUserAPIQueryEncoding
                    completion:(void (^)(id responseObject, NSError *error))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (useNextUserAPIQueryEncoding) {
        [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
            
            NSMutableArray *mutablePairs = [NSMutableArray array];
            for (NSString *key in parameters) {
                NSString *value = parameters[key];
                [mutablePairs addObject:[NSString stringWithFormat:@"%@=%@", [self nextUserAPIQueryParameterEncodedString:key], [self nextUserAPIQueryParameterEncodedString:value]]];
            }
            
            return [mutablePairs componentsJoinedByString:@"&"];
        }];
    }
    
    [manager GET:path
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             DDLogVerbose(@"HTTP GET request response");
             DDLogVerbose(@"URL: %@", operation.request.URL);
             DDLogVerbose(@"Response: %@", responseObject);
             
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

+ (NSString *)nextUserAPIQueryParameterEncodedString:(NSString *)string
{
    return [string URLEncodedStringWithIgnoredCharacters:@":,;="];
}

@end
