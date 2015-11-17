//
//  NUTracker.h
//  NextUserKit
//
//  Created by Dino on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (void)startWithCompletion:(void(^)(NSError *error))completion;

#pragma mark - Configuration
@property (nonatomic) NULogLevel logLevel;

#pragma mark - Track Screen
- (void)trackScreenWithName:(NSString *)screenName;

#pragma mark - Track Action
- (void)trackActionWithName:(NSString *)actionName;

/*
 Parameters max count: 10.
 Parameter index is important. If you want to put some parameter at a specific index, use NSNull value for slots before that index.
 e.g. 
 input array of [someValue1, NSNull, someValue3, someValue4, NSNull, NSNull]
 would put values in corresponding indices [someValue1, [EMPTY], someValue3, someValue4].
 Rest of the trailing NSNulls are ignored.
 
 This is the same method as one above (trackActionWithName:) except with this method you can send additional parameters.
 */
- (void)trackActionWithName:(NSString *)actionName parameters:(NSArray *)actionParameters;

/*
 Use these two methods combined when sending multiple actions at once.
 
 Usage:
 First, collect all actions you would like to track and put them into an array (use +actionInfoWithName:parameters: method).
 Then call -trackActions: with that array.
*/
+ (id)actionInfoWithName:(NSString *)actionName parameters:(NSArray *)actionParameters;
- (void)trackActions:(NSArray *)actions;

@end
