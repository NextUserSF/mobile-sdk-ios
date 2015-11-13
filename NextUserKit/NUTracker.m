//
//  NUTracker.m
//  NextUserKit
//
//  Created by Dino on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTracker.h"
#import "NUTrackerSession.h"
#import "NUAPIPathGenerator.h"
#import "NUTracker+Tests.h"
#import "AFNetworking.h"


@interface NUTracker ()

@property (nonatomic) NUTrackerSession *session;

@end

@implementation NUTracker

#pragma mark - Public API

+ (NUTracker *)sharedTracker
{
    static NUTracker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NUTracker alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        _session = [[NUTrackerSession alloc] init];
        [_session startWithCompletion:^(NSError *error) {
            if (error == nil) {
                if (_session.sessionCookie != nil && _session.deviceCookie != nil) {
                    _isReady = YES;
                }
            } else {
                NSLog(@"Error initializing tracker: %@", error);
            }
        }];
    }
    
    return self;
}

- (void)trackScreenWithName:(NSString *)screenName
{
    [self trackScreenWithName:screenName completion:NULL];
}

#pragma mark - Private

#pragma mark -

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion
{
    NSLog(@"Track screen with name: %@", screenName);
    
    NSMutableDictionary *parameters = nil;
    NSString *path = [self trackScreen:screenName URLParameters:&parameters];
    [_session updateParametersWithDefaults:parameters];
    
    NSLog(@"Fire HTTP request to track screen. Path: %@, Parameters: %@", path, parameters);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:path
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSLog(@"Track screen response: %@", responseObject);
             if (completion != NULL) {
                 completion(nil);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Track screen error: %@", error);
             if (completion != NULL) {
                 completion(error);
             }
         }];
}

- (NSString *)trackScreen:(NSString *)screenName URLParameters:(NSMutableDictionary **)URLParameters
{
    // e.g. __nutm.gif?tid=wid+username&pv0=www.google.com
    NSString *path = [NUAPIPathGenerator pathWithAPIName:@"__nutm.gif"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"tid"] = @"internal_tests";
    parameters[@"pv0"] = screenName;
    
    if (URLParameters != NULL) {
        *URLParameters = parameters;
    }
    
    return path;
}

@end
