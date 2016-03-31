//
//  NUTrackerSession.h
//  NextUserKit
//
//  Created by NextUser on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUPubNubConfiguration;

@interface NUTrackerSession : NSObject

@property (nonatomic, readonly) NSString *sessionCookie;
@property (nonatomic, readonly) NSString *deviceCookie; // gets serialized when retrieved from server
@property (nonatomic, readonly) NSString *trackIdentifier;

@property (nonatomic, readonly) BOOL shouldListenForPushMessages;

@property (nonatomic) NSString *userIdentifier; // username, email or something else
@property (nonatomic) BOOL userIdentifierRegistered;

@property (nonatomic, readonly) BOOL isValid;

@property (nonatomic, readonly) NUPubNubConfiguration *pubNubConfiguration;

// property serialization
- (NSString *)serializedDeviceCookie;
- (void)clearSerializedDeviceCookie;

// starts session (triggers call to fetch device & session cookies)
- (void)startWithTrackIdentifier:(NSString *)trackIdentifier completion:(void(^)(NSError *error))completion;
// YES if request to start the session is being made already and not yet finished
@property (nonatomic, readonly) BOOL startupRequestInProgress;

@end


@interface NUPubNubConfiguration : NSObject

@property (nonatomic, readonly) NSString *subscribeKey;
@property (nonatomic, readonly) NSString *publishKey;

@property (nonatomic, readonly) NSString *publicChannel;
@property (nonatomic, readonly) NSString *privateChannel;

@end
