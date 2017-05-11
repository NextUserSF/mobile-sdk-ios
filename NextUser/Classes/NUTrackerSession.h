//
//  NUTrackerSession.h
//  NextUserKit
//
//  Created by NextUser on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NULogLevel.h"
#import "NUUser.h"
#import "NUTrackerProperties.h"
#import "NUTrackerProperties.h"

#define END_POINT_PROD @"https://track.nextuser.com"
#define END_POINT_DEV @"https://track-dev.nextuser.com"

@class NUPubNubConfiguration;

typedef NS_ENUM(NSUInteger, NUSessionState) {
    Initialized,
    Initializing,
    Failed,
    None
};


@interface NUTrackerSession : NSObject

@property (nonatomic) NUUser *user;
@property (nonatomic) NUSessionState sessionState;
@property (nonatomic, readonly) NSString *sessionCookie;
@property (nonatomic, readonly) NSString *deviceCookie;
@property (nonatomic, readonly) NUTrackerProperties *trackerProperties;
@property (nonatomic, readonly) BOOL shouldListenForPushMessages;
@property (nonatomic, readonly) NUPubNubConfiguration *pubNubConfiguration;


- (NSString *) serializedDeviceCookie;
- (void) clearSerializedDeviceCookie;
- (NUSessionState) sessionState;
- (void) initialize:(void(^)(NSError *error))completion;
- (BOOL)isValid;
- (NULogLevel) logLevel;
- (NSString *)basePath;
- (NSString *)pathWithAPIName:(NSString *)APIName;

@end


@interface NUPubNubConfiguration : NSObject

@property (nonatomic, readonly) NSString *subscribeKey;
@property (nonatomic, readonly) NSString *publishKey;
@property (nonatomic, readonly) NSString *publicChannel;
@property (nonatomic, readonly) NSString *privateChannel;

@end
