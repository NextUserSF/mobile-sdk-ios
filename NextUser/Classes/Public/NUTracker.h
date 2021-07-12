#import <UIKit/UIKit.h>
#import "NUEvent.h"
#import "NUUser.h"
#import <UserNotifications/UserNotifications.h>
#import "NUWebViewSettings.h"

typedef NS_ENUM(NSUInteger, NUTrackedAction) {
    NU_SESSION = 0,
    NU_EVENT,
    NU_SCREEN,
    NU_PURCHASE,
    NU_USER,
    NU_USER_VARIABLES
};

extern NSString * const NEXTUSER_LOCAL_NOTIFICATION;
extern NSString * const NEXTUSER_LOCAL_NOTIFICATION_OBJECT;
extern NSString * const NEXTUSER_LOCAL_NOTIFICATION_EVENT;
extern NSString * const NEXTUSER_LOCAL_NOTIFICATION_SUCCESS_COMPLETION;

@interface NUTracker : NSObject

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UNNotificationRequest *)notificationRequest;
- (void)trackUser:(NUUser *)user;
- (void)setUser:(NUUser *)user;
- (NSString *)currentUserIdentifier;
- (void)trackUserVariables:(NUUserVariables *)userVariables;
- (void)trackScreenWithName:(NSString *)screenName;
- (void)trackEvent:(NUEvent *)event;
- (void)trackEvents:(NSArray<NUEvent *> *)events;
-(void) showWebView:(NUWebViewSettings *) settings withDelegate:(id<NUWebViewUIDelegate>) delegate
     withCompletion: (void (^)(BOOL success, NSError*error))completion;

@end

@interface NUTracker (Dev)

- (void)triggerLocalNoteWithDelay:(NSTimeInterval)delay;

@end
