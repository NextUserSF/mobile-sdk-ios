//
//  NUTracker+Tests.h
//  NextUserKit
//
//  Created by NextUser on 11/13/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <NextUserKit/NextUserKit.h>
@class NUTrackerSession;

@interface NUTracker (Tests)

- (NUTrackerSession *)session;

- (NSMutableDictionary *)defaultTrackingParameters:(BOOL)includeUserIdentifier;
+ (NSString *)trackIdentifierParameterForSession:(NUTrackerSession *)session appendUserIdentifier:(BOOL)appendUserIdentifier;

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion;
- (void)trackAction:(NUAction *)action completion:(void(^)(NSError *error))completion;
- (void)trackActions:(NSArray *)actions completion:(void(^)(NSError *error))completion;
- (void)trackPurchase:(NUPurchase *)purchase completion:(void(^)(NSError *error))completion;
- (void)trackPurchases:(NSArray *)purchases completion:(void(^)(NSError *error))completion;

@end
