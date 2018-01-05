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

typedef NS_ENUM(NSUInteger, NUSessionState) {
    Initialized,
    Initializing,
    Failed,
    None
};


@interface NUTrackerSession : NSObject


@property (nonatomic) NSString *sessionCookie;
@property (nonatomic) NSString *deviceCookie;
@property (nonatomic) NUTrackerProperties *trackerProperties;
@property (nonatomic) NUSessionState sessionState;
@property (nonatomic) NUUser *user;
@property (nonatomic) NSString *trackingIdentifier;
@property (nonatomic) NSString *instantWorkflows;
@property (nonatomic) BOOL requestInAppMessages;


- (id)initWithProperties:(NUTrackerProperties *) trackerProperties;

- (NSString *) apiKey;
- (void) clearSerializedDeviceCookie;
- (BOOL) isValid;
- (NSString *) logLevel;
- (NSString *) trackPath;
- (NSString *) trackCollectPath;
- (NSString *) sessionInitPath;
- (NSString *) deviceTokenPath:(BOOL) isUnsubscribe;
- (NSString *) iamsRequestPath;

@end
