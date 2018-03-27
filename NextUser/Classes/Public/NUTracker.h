//
//  NUTracker.h
//  NextUserKit
//
//  Created by NextUser on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NUPurchase.h"
#import "NUEvent.h"
#import "NUUser.h"

typedef NS_ENUM(NSUInteger, NUTrackedAction) {
    NU_SESSION = 0,
    NU_EVENT,
    NU_SCREEN,
    NU_PURCHASE,
    NU_USER,
    NU_USER_VARIABLES
};

extern NSString * const COMPLETION_NU_TRACKER_NOTIFICATION_NAME;
extern NSString * const NU_TRACK_RESPONSE;
extern NSString * const NU_TRACK_EVENT;

@interface NUTracker : NSObject

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)requestNotificationsPermissions;
- (void)requestLocationPersmissions;

- (void)trackUser:(NUUser *)user;
- (void)setUser:(NUUser *)user;
- (NSString *)currentUserIdentifier;
- (void)trackUserVariables:(NUUserVariables *)userVariables;
- (void)trackScreenWithName:(NSString *)screenName;
- (void)trackEvent:(NUEvent *)event;
- (void)trackEvents:(NSArray<NUEvent *> *)events;
- (void)trackPurchase:(NUPurchase *)purchase;
- (void)trackPurchases:(NSArray *)purchases;

- (void)submitFCMRegistrationToken:(NSString *) fcmToken;
- (void)unregisterFCMRegistrationToken;
- (UIBackgroundFetchResult) didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end

@interface NUTracker (Dev)

- (void)triggerLocalNoteWithDelay:(NSTimeInterval)delay;

@end
