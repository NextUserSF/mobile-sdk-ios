#import <Foundation/Foundation.h>
#import "NUPushMessage.h"
#import "NUEvent.h"
#import "NUDDLog.h"
#import "NUPushMessageService.h"
#import "NURegistrationToken.h"
#import "NUAppWakeUpManager.h"
#import "NUTrackerSession.h"

#define kPushMessageLocalNoteTypeKey @"nu_local_note_type"
#define kPushMessageContentURLKey @"nu_content_url"
#define kPushMessageUIThemeDataKey @"nu_ui_theme_data"
//@protocol NUPushNotificationsDelegate <NSObject>
//
//-(void)receivedBackgroundNotification:(UANotificationContent *)notificationContent completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    // Background content-available notification
//    completionHandler(UIBackgroundFetchResultNoData);
//}
//
//-(void)receivedForegroundNotification:(UANotificationContent *)notificationContent completionHandler:(void (^)())completionHandler {
//    // Foreground notification
//    completionHandler();
//}
//
//-(void)receivedNotificationResponse:(UANotificationResponse *)notificationResponse completionHandler:(void (^)())completionHandler {
//    // Notification response
//    completionHandler();
//}
//
//- (UNNotificationPresentationOptions)presentationOptionsForNotification:(UNNotification *)notification {
//    // iOS 10 foreground presentation options
//    return UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound;
//}
//
//@end

@interface NUPushNotificationsManager : NSObject<NUAppWakeUpManagerDelegate, NUPushMessageServiceDelegate>

+ (BOOL)isNextUserLocalNotification:(UILocalNotification *)note;

- (void) scheduleLocalNotificationForMessage:(NUPushMessage *)message;
- (void) requestLocationPersmissions;
- (void) requestNotificationsPermissions;
- (void) unsubscribeFromAppStateNotifications;

- (void) handleLocalNotification:(UILocalNotification *)notification application:(UIApplication *)application;
- (void) submitFCMRegistrationToken:(NSString *) fcmToken;
- (void) unregisterFCMRegistrationToken;
- (UIBackgroundFetchResult) didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (NSMutableArray<NUEvent *> *) extractTrackingEvent:(NSArray *) eventJSON;

@end
