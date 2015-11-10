//
//  NUTracker.m
//  NextUserKit
//
//  Created by Dino on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTracker.h"
#import "AFNetworking.h"

//https://track-dev.nextuser.com/sdk.js?tid=internal_tests&dc=1


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

#pragma mark - Tracking

 - (void)trackScreenWithName:(NSString *)screenName
{
    NSLog(@"This is log from framework. Try making HTTP request with AFNetworking");
    
    NSString *path = @"https://track-dev.nextuser.com/sdk.js?tid=internal_tests&dc=1";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
