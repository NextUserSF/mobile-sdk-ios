
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NUTask.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "Reachability.h"

#import "NUInAppMsgWorkflowManager.h"
#import "NUInAppMsgCacheManager.h"
#import "NUInAppMsgImageManager.h"
#import "NUInAppMsgUIManager.h"
#import "NUTracker.h"
#import "NUTrackerTask.h"
#import "NUPushNotificationsManager.h"
#import "NUTaskManager.h"
#import "NUDDLog.h"
#import "NUCartManager.h"

@interface NextUserManager : NSObject

+ (instancetype) sharedInstance;

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
- (BOOL)trackWithObject:(id)trackObject withType:(NUTaskType) taskType;
- (void)refreshPendingRequests;

- (NUTrackerSession *) getSession;
- (NUPushNotificationsManager *) notificationsManager;
- (WorkflowManager *) workflowManager;
- (InAppMsgCacheManager *) inAppMsgCacheManager;
- (InAppMsgImageManager *) inAppMsgImageManager;
- (InAppMsgUIManager *) inAppMsgUIManager;
- (NUCartManager *) cartManager;

- (NUTracker* ) getTracker;
- (void)setLogLevel:(NSString *)logLevel;
- (NULogLevel)logLevel;
- (void) sendNextUserLocalNotification: (NUTaskType )event withObject:(id)object andStatus:(BOOL)status;
- (BOOL) validTracker;

@end
