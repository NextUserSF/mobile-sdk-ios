//
//  NUTracker+Tests.h
//  NextUserKit
//
//  Created by Dino on 11/13/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <NextUserKit/NextUserKit.h>
@class NUTrackerSession;

@interface NUTracker (Tests)

- (NUTrackerSession *)session;

- (NSMutableDictionary *)defaultTrackingParameters:(BOOL)includeUserIdentifier;
+ (NSString *)trackIdentifierParameterForSession:(NUTrackerSession *)session appendUserIdentifier:(BOOL)appendUserIdentifier;

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion;

@end
