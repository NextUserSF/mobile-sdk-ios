//
//  NUTracker.h
//  NextUserKit
//
//  Created by Dino on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUPurchase;
@class NUAction;

typedef NS_ENUM(NSUInteger, NULogLevel) {
    NULogLevelOff,      // No logs
    NULogLevelError,    // Error logs only
    NULogLevelWarning,  // Error and warning logs
    NULogLevelInfo,     // Error, warning and info logs
    NULogLevelDebug,    // Error, warning, info and debug logs
    NULogLevelVerbose,  // Error, warning, info, debug and verbose logs
    NULogLevelAll       // All logs (1...11111)
};

@interface NUTracker : NSObject

+ (NUTracker *)sharedTracker;

#pragma mark - Initialization
@property (nonatomic, readonly) BOOL isReady;
- (void)startSessionWithTrackIdentifier:(NSString *)trackIdentifier completion:(void(^)(NSError *error))completion;

#pragma mark - Configuration
@property (nonatomic) NULogLevel logLevel;

#pragma mark - User Identification
- (void)identifyUserWithIdentifier:(NSString *)userIdentifier;

#pragma mark - Track Screen
- (void)trackScreenWithName:(NSString *)screenName;

#pragma mark - Track Action
- (void)trackAction:(NUAction *)action;
- (void)trackActions:(NSArray *)actions;

#pragma mark - Track Purchase
- (void)trackPurchase:(NUPurchase *)purchase;
- (void)trackPurchases:(NSArray *)purchases;

@end
