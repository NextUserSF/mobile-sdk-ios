
#import <Foundation/Foundation.h>

#import "NUTask.h"
#import "NUTrackerSession.h"
#import "NUTrackingHTTPRequestHelper.h"
#import "Reachability.h"
#import "NUAppWakeUpManager.h"

#import "NUPushMessage.h"
#import "NUIAMUITheme.h"
#import "NUInAppMessageManager.h"
#import "NUWorkflowManager.h"
#import "NUInAppMsgCacheManager.h"
#import "NUInAppMsgImageManager.h"
#import "NUInAppMsgUIManager.h"
#import "NUTracker.h"
#import "NUTrackerTask.h"
#import "NUPushNotificationsManager.h"

@interface NextUserManager : NSObject

+ (instancetype) sharedInstance;

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions;
- (BOOL)trackWithObject:(id)trackObject withType:(NUTaskType) taskType;
- (void)refreshPendingRequests;

- (NUTrackerSession *) getSession;
- (NUPushNotificationsManager *) getNotificationsManager;
- (WorkflowManager *) workflowManager;
- (InAppMsgCacheManager *) inAppMsgCacheManager;
- (InAppMsgImageManager *) inAppMsgImageManager;
- (InAppMsgUIManager *) inAppMsgUIManager;

- (NUTracker* ) getTracker;
- (void)setLogLevel:(NSString *)logLevel;
- (NULogLevel)logLevel;

@end
