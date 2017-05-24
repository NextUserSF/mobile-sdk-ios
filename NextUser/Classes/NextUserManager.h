
#import <Foundation/Foundation.h>
#import "NUTaskType.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "Reachability.h"
#import "NUAppWakeUpManager.h"
#import "NUPushMessageService.h"
#import "NUPushMessageServiceFactory.h"
#import "NUPushMessage.h"
#import "NUIAMUITheme.h"
#import "NUInAppMessageManager.h"

#define kPushMessageLocalNoteTypeKey @"nu_local_note_type"
#define kPushMessageContentURLKey @"nu_content_url"
#define kPushMessageUIThemeDataKey @"nu_ui_theme_data"

@interface NextUserManager : NSObject <NUAppWakeUpManagerDelegate, NUPushMessageServiceDelegate>

@property NUTrackerSession *session;
@property BOOL initializationFailed;


-(instancetype)initManager;

-(BOOL)trackWithObject:(id)trackObject withType:(NUTaskType) taskType;
-(void)refreshPendingRequests;
-(void)addSession:(NUTrackerSession*) session;
-(void)unsubscribeFromAppStateNotifications;
-(void)scheduleLocalNotificationForMessage:(NUPushMessage *)message;
-(void)requestNotificationPermissionsForNotificationTypes:(UIUserNotificationType)types;
-(void)requestLocationPersmissions;
-(BOOL)isNextUserLocalNotification:(UILocalNotification *)note;
-(void)handleLocalNotification:(UILocalNotification *)notification application:(UIApplication *)application;
-(UIUserNotificationType)allNotificationTypes;

@end

@interface PendingTask : NSObject

@property (nonatomic) id trackingObject;
@property (nonatomic) NUTaskType taskType;

@end
