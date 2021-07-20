#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import "NUEvent.h"

@interface NUPushNotificationsManager : NSObject

- (void) requestNotificationsPermissions;
- (void) unsubscribeFromAppStateNotifications;

- (void) submitFCMRegistrationToken:(NSString *) fcmToken;
- (void) submitFCMRegistrationToken:(NSString *) fcmToken withCompletion:(void (^)(BOOL success, NSError*error))completion;

- (void) unregisterFCMRegistrationToken;
- (void) unregisterFCMRegistrationTokenWithCompletion:(void (^)(BOOL success, NSError*error))completion;


- (UIBackgroundFetchResult) didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void) didReceiveRemoteNotification:(NSDictionary *)userInfo withCompletion:(void (^)(BOOL success, NSError*error))completion;

- (void) didReceiveNotificationResponse: (UNNotificationResponse *)response;
- (void) didReceiveNotificationResponseWithInfo: (NSDictionary *)userInfo andActionIdentifier:(NSString *) actionIdentifier;
- (void) didReceiveNotificationResponseWithInfo: (NSDictionary *)userInfo andActionIdentifier:(NSString *) actionIdentifier withCompletion:(void (^)(BOOL success, NSError*error))completion;

@end
