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
 *  Log level used by the tracker.
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
 * This class is the primary interface for user tracking which communicates with the NextUser API.
 * Use shared singleton instance of the tracker. Use this class to configure your project analytics
 * and to track events.
 *
 * Before you can track any events, you need to start tracking session. Do this by calling one of two
 * methods: startSessionWithTrackIdentifier:, startSessionWithTrackIdentifier:completion:
 */
@interface NUTracker : NSObject

#pragma mark - Tracker Singleton
/**
 * @name Tracker Singleton
 */

/**
 *  Shared singleton instance of NUTracker. Use this method to get a reference to NUTracker object.
 *
 *  @return Shared instance of NUTracker.
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
 *  for the version of this method with an optional completion handler which gets called when session is successfully
 *  started or if starting failed. Call only one of them. Note that without calling one of these two methods, tracker won't
 *  be able to track any events.
 *
 *  @param trackIdentifier Track identifier used to associate this session with.
 *  @warning Throws an exception if trackIdentifier is invalid (empty or nil).
 *  @see startSessionWithTrackIdentifier:completion:
 */
- (void)startSessionWithTrackIdentifier:(NSString *)trackIdentifier;

/**
 *  Starts the session for tracker.
 *
 *  Call this method once, preferably on app startup. Also see startSessionWithTrackIdentifier:
 *  for the version of this method without the completion handler. Call only one of them. Note that without calling one 
 *  of these two methods, tracker won't be able to track any events.
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
 *  Call this method if you want to track particular user.
 *
 *  Each tracking request will be associated with this user identifier.
 *
 *  @param userIdentifier User identifier that is currently using the application. Can be an email or username or any other identifier which identifies a particular user.
 */
- (void)identifyUserWithIdentifier:(NSString *)userIdentifier;

/**
 *  Gets current user identifier. This value will be *nil* or the one that you passed in -identifyUserWithIdentifier: method.
 *
 *  @return Current user identifier
 */
- (NSString *)currentUserIdenifier;

#pragma mark - Tracking
/**
 * @name Tracking
 */

/**
 *  Tracks screen view inside application.
 *
 *  @param screenName Name of the screen that user just viewed.
 */
- (void)trackScreenWithName:(NSString *)screenName;

#pragma mark -

/**
 *  Tracks single user action.
 *
 *  For tracking of multiple actions at once use trackActions: method.
 *
 *  @param action NUAction to track.
 *  @see trackActions:
 */
- (void)trackAction:(NUAction *)action;

/**
 *  Tracks multiple user actions at once.
 *
 *  For single action tracking use trackAction: method.
 *
 *  @param actions Array of NUAction objects to track.
 *  @see trackAction:
 */
- (void)trackActions:(NSArray *)actions;

#pragma mark -

/**
 *  Tracks single purchase.
 *
 *  For tracking of multiple purchases at once use trackPurchases: method.
 *
 *  @param purchase NUPurchase to track.
 *  @see trackPurchases:
 */
- (void)trackPurchase:(NUPurchase *)purchase;

/**
 *  Tracks multiple purchases.
 *
 *  For single purchase tracking use trackPurchase: method.
 *
 *  @param purchases Array of NUPurchase objects to track.
 *  @see trackPurchase:
 */
- (void)trackPurchases:(NSArray *)purchases;

@end
