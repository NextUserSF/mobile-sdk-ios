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
@property (nonatomic) NSString *sessionCookie;
@property (nonatomic) NSString *deviceCookie;
@property (nonatomic) NUTrackerProperties *trackerProperties;
@property (nonatomic) BOOL shouldListenForPushMessages;
@property (nonatomic) NUPubNubConfiguration *pubNubConfiguration;

+ (instancetype) initializeWithProperties:(NUTrackerProperties *) trackerProperties;

- (NSString *) apiKey;
- (NSString *) serializedDeviceCookie;
- (void) clearSerializedDeviceCookie;
- (NUSessionState) sessionState;
- (BOOL)isValid;
- (NULogLevel) logLevel;
- (void)setDeviceCookie:(NSString *)deviceCookie;

@end

@interface NUPubNubConfiguration : NSObject

@property (nonatomic, readonly) NSString *subscribeKey;
@property (nonatomic, readonly) NSString *publishKey;
@property (nonatomic, readonly) NSString *publicChannel;
@property (nonatomic, readonly) NSString *privateChannel;

@end
