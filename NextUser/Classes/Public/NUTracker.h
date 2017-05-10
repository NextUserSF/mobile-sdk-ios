//
//  NUTracker.h
//  NextUserKit
//
//  Created by NextUser on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NUPurchase;
@class NUAction;
@class NUUser;

/**
 *  Log level used by the tracker.
 */


/**
 * This class is the primary interface for user tracking which communicates with the NextUser API.
 * Use shared singleton instance of the tracker. Use this class to configure your project analytics
 * and to track events.
 *
 * Before you can track any events, you need to start tracking session. Do this by calling one of two
 * methods: startSessionWithTrackIdentifier:, startSessionWithTrackIdentifier:completion:
 * It is important to initialize sharedTracker tracker in application:didFinishLaunchingWithOptions:
 */
@interface NUTracker : NSObject

#pragma mark - Tracker Singleton Setup
/**
 * @name Tracker Singleton Setup
 */

/**
 *  Shared singleton instance of NUTracker. Use this method to get a reference to NUTracker object.
 *
 *  @return Shared instance of NUTracker.
 */
+ (NUTracker *)sharedTracker;

#pragma mark -

/**
 *  Called when application is finishing launching. Call this method from your AppDelegate's -application:didFinishLaunchingWithOptions:
 *
 *  @param application   Host Application
 *  @param launchOptions Dictionary with launching options
 *
 *  @return NO if the app cannot handle the URL resource or continue a user activity, otherwise return YES.
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 *  Called when application receives local notification. Call this method from your AppDelegate's -application:didReceiveLocalNotification:
 *
 *  @param application  Host Application
 *  @param notification Received notification
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

#pragma mark - Tracker Singleton Setup - User Persmissions

/**
 *  Convenient method which requests all needed user permissions. This method will trigger system alerts for accepting Location and Notification permissions. If you call this method
 *  you don't need to call anything more regarding user permissions requesting.
 */
- (void)requestDefaultPermissions;

#pragma mark -

/**
 *  Triggers system alert view which asks user for permissions to use location. NUTracker is monitoring for significant location changes in order to wake up application
 *  in periods when it is in background or turned off. This is because app can not receive HTTP messages while in background.
 *  
 *  @warning Without calling this method (or expanded version of it bellow) IAMs will not work properly (you will miss messages that arrived during app's background time).
 */
- (void)requestLocationPersmissions;

#pragma mark -

/**
 *  Triggers system alert view which asks user for permissions to use notifications. This method requests all notifications type alerts.
 *  For requesting only specific notification type alerts use -requestNotificationPermissionsForNotificationTypes: method.
 * 
 *  @warning Without calling this method (or expanded version of it bellow) IAMs will not work.
 *  @see requestNotificationPermissionsForNotificationTypes:
 *  @see requestLocationPersmissions
 */
- (void)requestNotificationPermissions;

/**
 *  Triggers system alert view which asks user for permissions to use notifications. This method requests specific notifications type alerts.
 *  For requesting all notification type alerts use -requestNotificationPermissions method.
 *
 *  @param types Requested notification types
 *
 *  @warning Without calling this method (or shorter one above) IAMs will not work.
 *  @see requestNotificationPermissions
 *  @see requestLocationPersmissions
 */
- (void)requestNotificationPermissionsForNotificationTypes:(UIUserNotificationType)types;

#pragma mark - Initialization
/**
 * @name Initialization
 */

/**
 *  Initialize the tracker.
 *
 *  Call this method once, preferably on app startup. Also see initialize:completion:
 *  for the version of this method with an optional completion handler which gets called when tracker is initialized. 
 *  Call only one of them. Note that without calling one of these two methods, tracker won't
 *  be able to track any events.
 */
- (void)initialize;

/**
 *  Starts the session for tracker.
 *  @param completion :Optional completion handler which will notify you if tracker was successfully initialized or not.
 */
- (void)initialize:(void(^)(NSError *error))completion;

#pragma mark - User Identification
/**
 * @name User Identification
 */

/**
 *  Call this method if you want to track a particular user.
 *  Check NUUser.h interface for available user fileds for tracking.
 *  @param user that is currently using the application. 
 */
- (void)trackUser:(NUUser *)user;

/**
 *  Call this method if you want to add user identification to your track requestes
 *  This is for cases when an already identified user is reusing the application.
 */
- (void)setUser:(NUUser *)user;

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


@interface NUTracker (Dev)

- (void)triggerLocalNoteWithDelay:(NSTimeInterval)delay;

@end

