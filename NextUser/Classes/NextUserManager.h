
#import <Foundation/Foundation.h>
#import "NUTask.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "Reachability.h"
#import "NUAppWakeUpManager.h"
#import "NUPushMessageService.h"
#import "NUPushMessage.h"
#import "NUIAMUITheme.h"
#import "NUInAppMessageManager.h"
#import "NUWorkflowManager.h"
#import "NUInAppMsgCacheManager.h"
#import "NUInAppMsgImageManager.h"
#import "NUInAppMsgUIManager.h"
#import "NUTracker.h"
#import "NUTrackerTask.h"

#define kPushMessageLocalNoteTypeKey @"nu_local_note_type"
#define kPushMessageContentURLKey @"nu_content_url"
#define kPushMessageUIThemeDataKey @"nu_ui_theme_data"

@interface NextUserManager : NSObject <NUAppWakeUpManagerDelegate, NUPushMessageServiceDelegate>

+ (instancetype) sharedInstance;

-(void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
-(BOOL)trackWithObject:(id)trackObject withType:(NUTaskType) taskType;
-(void)refreshPendingRequests;
-(void)unsubscribeFromAppStateNotifications;
-(void)scheduleLocalNotificationForMessage:(NUPushMessage *)message;
-(void)requestLocationPersmissions;
-(BOOL)isNextUserLocalNotification:(UILocalNotification *)note;
-(void)handleLocalNotification:(UILocalNotification *)notification application:(UIApplication *)application;
-(NUTrackerSession *) getSession;
-(WorkflowManager *) workflowManager;
-(InAppMsgCacheManager *) inAppMsgCacheManager;
-(InAppMsgImageManager *) inAppMsgImageManager;
-(InAppMsgUIManager *) inAppMsgUIManager;

-(NUTracker* ) getTracker;
-(void) inAppMessagesRequested;
- (void)setLogLevel:(NSString *)logLevel;
- (NULogLevel)logLevel;

- (void)submitFCMRegistrationToken:(NSString *) fcmToken;
- (void)unregisterFCMRegistrationToken;

@end
