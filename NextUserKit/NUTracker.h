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

/**
 *  Log level that will be used by the tracker.
 */
typedef NS_ENUM(NSUInteger, NULogLevel) {
    /**
     *  Logging is turned off. No messages.
     */
    NULogLevelOff,
    /**
     *  Logging of error messages only.
     */
    NULogLevelError,
    /**
     *  Logging od error and warning messages.
     */
    NULogLevelWarning,
    /**
     *  Logging of error, warning and info messages.
     */
    NULogLevelInfo,
    /**
     *  Logging of error, warning, info and verbose messages.
     */
    NULogLevelVerbose
};

/**
 *  This class is the central place which you use to communicate with the NextUser API.
 */
@interface NUTracker : NSObject

/**
 *  Shared singleton instance of NUTracker. Use this method to get a reference to NUTracker obkect.
 *
 *  @return Shared instance of NUTracker
 */
+ (NUTracker *)sharedTracker;

#pragma mark - Initialization
/**
 * @name Initialization
 */

/**
 *  Starts the session for tracker.
 *
 *  Call this method once, preferably on app startup. Also see startSessionWithTrackIdentifier:completion:
 *
 *  @param trackIdentifier Track Identifier used to associate this session with.
 *  @warning Throws an exception if trackIdentifier is invalid.
 *  @see startSessionWithTrackIdentifier:completion:
 */
- (void)startSessionWithTrackIdentifier:(NSString *)trackIdentifier;

/**
 *  Starts the session for tracker.
 *
 *  Call this method once, preferably on app startup. Also see startSessionWithTrackIdentifier:
 *
 *  @param trackIdentifier Track Identifier used to associate this session with.
 *  @param completion      Optional completion handler which will notify you if session started successfully.
 *  @see startSessionWithTrackIdentifier:
 */
- (void)startSessionWithTrackIdentifier:(NSString *)trackIdentifier completion:(void(^)(NSError *error))completion;

#pragma mark - Configuration
/**
 * @name Configuration
 */

/**
 *  Defines the NULogLevel being used. Defaults to NULogLevelWarning.
 */
@property (nonatomic) NULogLevel logLevel;

#pragma mark - User Identification
/**
 * @name User Identification
 */

/**
 *  Call this method if you want to track particular users.
 *
 *  Each tracking request will be associated with this user.
 *
 *  @param userIdentifier User identifier. Could be an email or username which identifies particular user.
 */
- (void)identifyUserWithIdentifier:(NSString *)userIdentifier;

#pragma mark - Tracking
/**
 * @name Tracking
 */

/**
 *  Tracks screen view inside your application.
 *
 *  @param screenName Name of the screen that user just viewed.
 */
- (void)trackScreenWithName:(NSString *)screenName;

#pragma mark -

/**
 *  Tracks a single user action.
 *
 *  For multiple actions at once use trackActions: method.
 *
 *  @param action NUAction to track
 *  @see trackActions:
 */
- (void)trackAction:(NUAction *)action;

/**
 *  Tracks multiple user actions.
 *
 *  For single action use trackAction: method.
 *
 *  @param actions Array of NUAction objects.
 *  @see trackAction:
 */
- (void)trackActions:(NSArray *)actions;

#pragma mark -

/**
 *  Tracks a single purchase.
 *
 *  For multiple purchases at once use trackPurchases: method.
 *
 *  @param purchase NUPurchase to track
 *  @see trackPurchases:
 */
- (void)trackPurchase:(NUPurchase *)purchase;

/**
 *  Tracks multiple user purchases.
 *
 *  For single purchase use trackPurchase: method.
 *
 *  @param purchases Array of NUPurchase objects.
 *  @see trackPurchase:
 */
- (void)trackPurchases:(NSArray *)purchases;

@end
