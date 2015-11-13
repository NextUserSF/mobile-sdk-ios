//
//  NUTrackerSession.h
//  NextUserKit
//
//  Created by Dino on 11/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUTrackerSession : NSObject

@property (nonatomic, readonly) NSString *sessionCookie;
@property (nonatomic, readonly) NSString *deviceCookie; // gets serialized when retrieved from server

// property serialization
- (NSString *)serializedDeviceCookie;
- (void)clearSerializedDeviceCookie;

// starts session (triggers call to fetch device & session cookies)
- (void)startWithCompletion:(void(^)(NSError *error))completion;
// YES if request to start the session is being made already and not yet finished
@property (nonatomic, readonly) BOOL setupRequestInProgress;

- (void)updateParametersWithDefaults:(NSMutableDictionary *)parameters;

@end
