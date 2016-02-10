//
//  NUPrefetchTrackerClient.h
//  NextUserKit
//
//  Created by Dino on 2/10/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUTrackerSession;
@class NUPurchase;
@class NUAction;

@interface NUPrefetchTrackerClient : NSObject

+ (instancetype)clientWithSession:(NUTrackerSession *)session;

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion;
- (void)trackActions:(NSArray *)actions completion:(void(^)(NSError *error))completion;
- (void)trackPurchases:(NSArray *)purchases completion:(void(^)(NSError *error))completion;

- (void)refreshPendingRequests;


+ (NSMutableDictionary *)defaultTrackingParametersForSession:(NUTrackerSession *)session
                                       includeUserIdentifier:(BOOL)includeUserIdentifier;
+ (NSString *)trackIdentifierParameterForSession:(NUTrackerSession *)session
                            appendUserIdentifier:(BOOL)appendUserIdentifier;

@end
