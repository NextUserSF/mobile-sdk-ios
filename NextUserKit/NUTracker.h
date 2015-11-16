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

#pragma mark - Track
- (void)trackScreenWithName:(NSString *)screenName;

@end
