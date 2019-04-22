#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import "NUEvent.h"

@interface NUPushNotificationsManager : NSObject

- (void) requestNotificationsPermissions;
- (void) unsubscribeFromAppStateNotifications;
- (void) submitFCMRegistrationToken:(NSString *) fcmToken;
- (void) unregisterFCMRegistrationToken;
- (UIBackgroundFetchResult) didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void) didReceiveRemoteMessage: (NSDictionary *) data;

@end
