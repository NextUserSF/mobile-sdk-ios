#import <UIKit/UIKit.h>
#import "NUEvent.h"
#import "NUUser.h"
#import <UserNotifications/UserNotifications.h>
#import "NUWebViewSettings.h"

#define NEXTUSER_LOCAL_NOTIFICATION @"NextUserLocalNotification"
#define NEXTUSER_LOCAL_NOTIFICATION_OBJECT @"NextUserLocalNotificationObject"
#define NEXTUSER_LOCAL_NOTIFICATION_EVENT @"NextUserLocalNotificationEvent"
#define NEXTUSER_LOCAL_NOTIFICATION_SUCCESS_COMPLETION @"NextUserLocalNotificationSuccessCompletion"
#define TRACKER_INITIALIZED_EVENT_NAME @"onTrackerInitialized"
#define ON_TRACK_EVENT_EVENT_NAME @"onTrackEvent"
#define ON_TRACK_SCREEN_EVENT_NAME @"onTrackPage"
#define ON_TRACK_PURCHASE_EVENT_NAME @"onTrackPurchase"
#define ON_TRACK_USER_EVENT_NAME @"onTrackUser"
#define ON_TRACK_USER_VARIABLES_EVENT_NAME @"onTrackUserVariables"
#define ON_SOCIAL_SHARE_EVENT_NAME @"onSocialShareEvent"

@interface NUTracker : NSObject

@property (nonatomic) BOOL enabled;

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UNNotificationRequest *)notificationRequest;

- (void)trackUser:(NUUser *)user;
- (void)trackUser:(NSDictionary *) user withCompletion:(void (^)(BOOL success, NSError*error))completion;

- (NSString *)currentUserIdentifier;

- (void)trackUserVariables:(NUUserVariables *)userVariables;
- (void)trackUserVariables:(NSDictionary *) userVariables withCompletion:(void (^)(BOOL success, NSError*error))completion;

- (void)trackScreenWithName:(NSString *)screenName;

- (void)trackEvent:(NUEvent *)event;
- (void)trackEvent:(NSDictionary *) event withCompletion:(void (^)(BOOL success, NSError*error))completion;

- (void)trackEvents:(NSArray<NUEvent *> *)events;
- (void)trackEvents:(NSArray<NSDictionary *> *) events withCompletion:(void (^)(BOOL success, NSError*error))completion;

- (void)trackViewedProduct:(NSString*) productId;
- (void)trackViewedProduct:(NSString*) productId withCompletion:(void (^)(BOOL success, NSError*error))completion;

- (BOOL) hasSession;

- (void) disable;
- (void) enable;

@end

@interface NUTracker (Dev)

- (void)triggerLocalNoteWithDelay:(NSTimeInterval)delay;

@end
