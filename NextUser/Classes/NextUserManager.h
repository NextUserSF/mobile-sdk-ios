
#import <Foundation/Foundation.h>
#import "NUTask.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "Reachability.h"
#import "NUAppWakeUpManager.h"
#import "NUPushMessageService.h"
#import "NUPushMessageServiceFactory.h"
#import "NUPushMessage.h"
#import "NUIAMUITheme.h"
#import "NUInAppMessageManager.h"
#import "NUWorkflowManager.h"
#import "NUInAppMsgCacheManager.h"
#import "NUTracker.h"

#define kPushMessageLocalNoteTypeKey @"nu_local_note_type"
#define kPushMessageContentURLKey @"nu_content_url"
#define kPushMessageUIThemeDataKey @"nu_ui_theme_data"

@interface NextUserManager : NSObject <NUAppWakeUpManagerDelegate, NUPushMessageServiceDelegate>

+ (instancetype) sharedInstance;

-(BOOL)trackWithObject:(id)trackObject withType:(NUTaskType) taskType;
-(void)refreshPendingRequests;
-(void)unsubscribeFromAppStateNotifications;
-(void)scheduleLocalNotificationForMessage:(NUPushMessage *)message;
-(void)requestNotificationPermissionsForNotificationTypes:(UIUserNotificationType)types;
-(void)requestLocationPersmissions;
-(BOOL)isNextUserLocalNotification:(UILocalNotification *)note;
-(void)handleLocalNotification:(UILocalNotification *)notification application:(UIApplication *)application;
-(UIUserNotificationType)allNotificationTypes;
-(NUTrackerSession *) getSession;
-(NUWorkflowManager *) getWorkflowManager;
-(NUInAppMsgCacheManager *) getInAppMsgCacheManager;
-(NUTracker*) getTracker;

@end
