#import "NextUserManager.h"
#import "NUError.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"
#import "NUBase64.h"
#import "NUTrackerTask.h"
#import "NUTask.h"
#import "NUTrackerInitializationTask.h"
#import "NUSubscriberDevice.h"
#import "NUHardwareInfo.h"
#import "NUInternalTracker.h"
#import "NUConstants.h"


#define kDeviceCookieJSONKey @"device_cookie"
#define kSessionCookieJSONKey @"session_cookie"
#define kInstantWorkflowsJSONKey @"instant_workflows"

const int MAX_PENDING_TASKS = 100;


@interface PendingTask : NSObject
@property (nonatomic) id trackingObject;
@property (nonatomic) NUTaskType taskType;
@end

@implementation PendingTask
@end

@interface NextUserManager()
{
    NUTracker* tracker;
    NUTrackerSession *session;
    Reachability *reachability;
    WorkflowManager* workflowManager;
    InAppMsgCacheManager* inAppMessageCacheManager;
    InAppMsgUIManager* inAppMsgUIManager;
    InAppMsgImageManager* inAppMsgImageManager;
    NUPushNotificationsManager *notificationsManager;
    NUCartManager *cartManager;
    NSMutableArray *pendingTrackRequests;
    NSLock *sessionRequestLock;
    NSLock *pendingTasksLock;
    BOOL disabled;
    BOOL initializationFailed;
}

-(void) trackSubscriberDevice;

@end

@implementation NextUserManager

NSString *const kGCMMessageIDKey = @"gcm.message_id";

+ (instancetype) sharedInstance
{
    static NextUserManager *instance;
    static dispatch_once_t instanceInitToken;
    dispatch_once(&instanceInitToken, ^{
        instance = [[NextUserManager alloc] init];
        NSArray * args = [[NSProcessInfo processInfo] arguments];
        if (![args containsObject:@"disableTTY"]) {
            [DDLog addLogger:[DDOSLogger sharedInstance]];
        } else {
            [DDLog addLogger:[DDTTYLogger sharedInstance]];
        }
    });
    
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        pendingTrackRequests = [NSMutableArray arrayWithCapacity:100];
        tracker = [[NUTracker alloc] init];
        notificationsManager = [[NUPushNotificationsManager alloc] init];
        initializationFailed = NO;
        disabled = NO;
        sessionRequestLock = [[NSLock alloc] init];
        pendingTasksLock = [[NSLock alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTaskManagerNotification:)
                                                     name:COMPLETION_TASK_MANAGER_HTTP_REQUEST_NOTIFICATION_NAME
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
    }
    
    return self;
}

- (void)initializeWithApplication: (UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions
{
    static dispatch_once_t appInitToken;
    dispatch_once(&appInitToken, ^{
        DDLogInfo(@"Did finish launching with options: %@", launchOptions);
        [[NUTaskManager manager] submitTask: [[NUTrackerInitializationTask alloc] init]];
    });
}

-(NUTracker* ) getTracker
{
    return tracker;
}

-(NUTrackerSession *) getSession
{
    return session;
}

- (NUPushNotificationsManager *) notificationsManager
{
    return notificationsManager;
}

-(WorkflowManager *) workflowManager
{
    return workflowManager;
}

-(InAppMsgCacheManager *) inAppMsgCacheManager
{
    return inAppMessageCacheManager;
}


-(InAppMsgImageManager *) inAppMsgImageManager
{
    return inAppMsgImageManager;
}

-(InAppMsgUIManager *) inAppMsgUIManager
{
    return inAppMsgUIManager;
}

- (NUCartManager *) cartManager
{
    return cartManager;
}

-(void)receiveTaskManagerNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    id<NUTaskResponse> taskResponse = userInfo[COMPLETION_HTTP_REQUEST_NOTIFICATION_OBJECT_KEY];
    
    NSString* surfaceEvent = @"";
    BOOL checkResponse = YES;
    
    switch (taskResponse.taskType) {
        case APPLICATION_INITIALIZATION:
            [self onTrackerInitialization:taskResponse];
            checkResponse = NO;
            
            return;
        case SESSION_INITIALIZATION:
            [self onSessionInitialization:taskResponse];
            surfaceEvent = TRACKER_INITIALIZED;
            checkResponse = NO;
            
            break;
        case TRACK_USER:
            surfaceEvent = ON_TRACK_USER;
            
            break;
        case TRACK_USER_VARIABLES:
            surfaceEvent = ON_TTRACK_USER_VARIABLES;
            
            break;
        case TRACK_EVENT:
            surfaceEvent = ON_TRACK_EVENT;
            
            break;
        case TRACK_PURCHASE:
            surfaceEvent = ON_TRACK_PURCHASE;
            
            break;
        case TRACK_SCREEN:
            surfaceEvent = ON_TRACK_SCREEN;
            
            break;
        case REGISTER_DEVICE_TOKEN:
            if ([taskResponse successfull] == YES) {
                NUEvent *subscribedEvent = [NUEvent eventWithName:TRACK_EVENT_IOS_SUBSCRIBED];
                [self trackWithObject:@[subscribedEvent] withType:TRACK_EVENT];

                NUUserVariables *userVariable = [[NUUserVariables alloc] init];
                [userVariable addVariable:TRACK_EVENT_IOS_SUBSCRIBED withValue:@"true"];
                [self trackWithObject:userVariable withType:TRACK_USER_VARIABLES];
                
                NUTrackResponse *trackResp = (NUTrackResponse *) taskResponse;
                NURegistrationToken *regToken = (NURegistrationToken *) [trackResp trackObject];
                [session persistFCMToken: [regToken token]];
            }
            
            break;
        default:
            break;
    }
    
    if (checkResponse == YES) {
        [self checkRequestStatus: taskResponse];
    }
    
    if ([surfaceEvent isEqualToString:@""] == NO) {
        id object = nil;
        if ([taskResponse isKindOfClass:[NUTrackResponse class]]) {
            NUTrackResponse *trackResp = (NUTrackResponse *) taskResponse;
            object = [trackResp trackObject];
        }
        [self sendNextUserLocalNotification:surfaceEvent withObject:object andStatus:taskResponse.successfull];
    }
}

- (void) sendNextUserLocalNotification: (NSString *)event withObject:(id)object andStatus:(BOOL)status
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[NSNumber numberWithBool:status] forKey: NEXTUSER_LOCAL_NOTIFICATION_SUCCESS_COMPLETION];
    [dictionary setValue:[NSNumber numberWithInt:(int)event] forKey: NEXTUSER_LOCAL_NOTIFICATION_EVENT];
    if (object != nil) {
        [dictionary setValue: object forKey: NEXTUSER_LOCAL_NOTIFICATION_OBJECT];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NEXTUSER_LOCAL_NOTIFICATION object:nil userInfo:dictionary];
}

- (void) checkRequestStatus: (NUTrackResponse *) response
{
    if ([response successfull] == NO) {
        [self queueTrackObject:response.trackObject withType:response.type];
        DDLogVerbose(@"Queing task: %@", [response taskTypeAsString]);
    } else if ([response queued] == YES) {
        DDLogVerbose(@"Qeued task found: %@", [response taskTypeAsString]);
        [self onPendingTaskSuccess];
    }
}

-(void)onTrackerInitialization:(NUTrackerInitializationResponse *) response
{
    if ([response successfull]) {
        session = response.session;
        [self setLogLevel: [session logLevel]];
        initializationFailed = NO;
        [self requestSession];
    } else {
        initializationFailed = YES;
        DDLogError(@"Initialization Exception: %@", response.errorMessage);
    }
}

-(void)onSessionInitialization:(NUTrackResponse *)response
{
    if ([response successfull]) {
        
        NSError *errorJson=nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:response.reponseData options:kNilOptions error:&errorJson];
        
        DDLogVerbose(@"Start tracker session response: %@", responseDict);
        session.sessionCookie = responseDict[kSessionCookieJSONKey];
        
        if (![session sessionCookie]) {
            [session setSessionState: Failed];
            DDLogError(@"Setup tracker error: %@", @"Server Error.");
            initializationFailed = YES;
    
            return;
        }
        
        initializationFailed = NO;
        
        [session setDeviceCookie: responseDict[kDeviceCookieJSONKey]];
        [session setSessionState: Initialized];
        [self trackSubscriberDevice];
        
        cartManager = [[NUCartManager alloc] init];
        
        if (session.requestInAppMessages == YES) {
            [self initInAppMsgSessionManagers];
        }
        
        [self popNextPendingTask];
        
    } else {
        DDLogError(@"Setup tracker error: %@", response.error);
        [session setSessionState: Failed];
        initializationFailed = YES;
    }
}

-(void) trackSubscriberDevice
{
    NUSubscriberDevice *subDevice = [[NUSubscriberDevice alloc] init];
    subDevice.os = [NUHardwareInfo systemName];
    subDevice.osVersion = [NUHardwareInfo systemVersion];
    subDevice.trackingSource = TRACKING_SOURCE_NAME;
    subDevice.trackingVersion = TRACKER_VERSION;
    subDevice.deviceModel = [NSString stringWithFormat:@"Apple %@", [NUHardwareInfo systemDeviceTypeFormatted:YES]];
    subDevice.resolution = [NSString stringWithFormat:@"%ldx%ld", (long)[NUHardwareInfo screenWidth],(long)[NUHardwareInfo screenHeight]];
    NSBundle *bundle = [NSBundle mainBundle];
    subDevice.browser =[[bundle infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    subDevice.browserVersion = [[bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    subDevice.tablet = [subDevice.deviceModel containsString:@"Pad"];
    subDevice.mobile = !subDevice.tablet;
    
    [self trackWithObject:subDevice withType:TRACK_USER_DEVICE];
}

-(void) initInAppMsgSessionManagers
{
    if (inAppMessageCacheManager == nil) {
        inAppMessageCacheManager = [[InAppMsgCacheManager alloc] init];
    }
    
    if (inAppMsgImageManager == nil) {
        inAppMsgImageManager = [[InAppMsgImageManager alloc] init];
    }
    
    if (inAppMsgUIManager == nil) {
        inAppMsgUIManager = [[InAppMsgUIManager alloc] init];
    }
    
    if (workflowManager == nil) {
        workflowManager = [WorkflowManager initWithSession:session];
    }
}

-(void)track:(id)trackObject withType:(NUTaskType) taskType andQueued:(BOOL) queued
{
    NUTrackerTask *trackTask = [[NUTrackerTask alloc] initForType:taskType withTrackObject:trackObject withSession:session];
    trackTask.queued = queued;
    [self submitTrackerTask:trackTask];
}

-(void)reachabilityChanged: (NSNotification*) notification
{
    if(reachability.currentReachabilityStatus != NotReachable) {
        if ([self validTracker] == NO) {
            [self requestSession];
            
            return;
        }
        [self refreshPendingRequests];
        [[NUTaskManager manager] dispatchMessageNotification:NETWORK_AVAILABLE withObject:nil];
    }
}

-(BOOL)trackWithObject:(id)trackObject withType:(NUTaskType) taskType
{
    if (initializationFailed || disabled) {
        return NO;
    }
    
    if (![self validTracker] || reachability.currentReachabilityStatus == NotReachable) {
        DDLogWarn(@"Cannot sendTrackTask, session or network connection not available...");
        [self queueTrackObject:trackObject withType:taskType];
        
        return false;
    }
    
    [self track:trackObject withType:taskType andQueued:NO];
    
    return YES;
}

-(void)submitTrackerTask:(NUTrackerTask *) trackTask
{
    NUTaskManager *manager = [NUTaskManager manager];
    [manager submitTask:trackTask];
}

-(BOOL)validTracker
{
    return session && [session isValid];
}

-(void)queueTrackObject:(id)trackObject withType:(NUTaskType) taskType
{
    if (taskType == TRACK_USER_VARIABLES) {
        NUUserVariables *userVar = (NUUserVariables *) trackObject;
        if ([[userVar.variables allKeys] containsObject:TRACK_VARIABLE_CART_STATE] == YES) {
            
            return;
        }
    }
    
    [pendingTasksLock lock];
    if (pendingTrackRequests.count == MAX_PENDING_TASKS) {
        [pendingTrackRequests removeLastObject];
    }
    PendingTask *pendingTask = [PendingTask alloc];
    pendingTask.trackingObject = trackObject;
    pendingTask.taskType = taskType;
    [pendingTrackRequests insertObject:pendingTask atIndex:0];
    [pendingTasksLock unlock];
}

-(void) onPendingTaskSuccess
{
    [pendingTasksLock lock];
    [pendingTrackRequests removeLastObject];
    [self popNextPendingTask];
    [pendingTasksLock unlock];
}

- (void)refreshPendingRequests
{
    [pendingTasksLock lock];
    [self popNextPendingTask];
    [pendingTasksLock unlock];
}

- (void)popNextPendingTask
{
    if (pendingTrackRequests.count > 0) {
        PendingTask *pendingTask = pendingTrackRequests.lastObject;
        DDLogVerbose(@"Popped request: %@", pendingTask);
        [self track:pendingTask.trackingObject withType:pendingTask.taskType andQueued:YES];
    }
}

-(void)requestSession
{
    if ([sessionRequestLock tryLock]) {
        @try
        {
            if (session && ([session sessionState] == None || [session sessionState] == Failed)) {
                [session setSessionState: Initializing];
                DDLogVerbose(@"Start tracker session for apikey: %@", [session apiKey]);
                [self track:nil withType:SESSION_INITIALIZATION andQueued:NO];
            }
            
        } @catch (NSException *exception) {
            DDLogError(@"Request tracker session exception: %@", [exception reason]);
        } @finally {
            [sessionRequestLock unlock];
        }
    }
}

- (void)setLogLevel:(NSString *)logLevel
{
    DDLogLevel level;
    
    if ([NSString lg_isEmptyString:logLevel] || [logLevel isEqualToString:@"OFF"]) {
        level = DDLogLevelOff;
    } else if ([logLevel isEqualToString:@"ERROR"]) {
        level = DDLogLevelError;
    } else if ([logLevel isEqualToString:@"WARNING"]) {
        level = DDLogLevelWarning;
    } else if ([logLevel isEqualToString:@"INFO"]) {
        level = DDLogLevelInfo;
    } else if ([logLevel isEqualToString:@"VERBOSE"]) {
        level = DDLogLevelVerbose;
    } else {
        level = DDLogLevelOff;
    }
    
    [NUDDLog setLogLevel:level];
}

- (NULogLevel)logLevel
{
    DDLogLevel logLevel = [NUDDLog logLevel];
    NULogLevel level = NULogLevelOff;
    switch (logLevel) {
        case DDLogLevelOff: level = NULogLevelOff; break;
        case DDLogLevelError: level = NULogLevelError; break;
        case DDLogLevelWarning: level = NULogLevelWarning; break;
        case DDLogLevelInfo: level = NULogLevelInfo; break;
        case DDLogLevelDebug: level = NULogLevelInfo; break;
        case DDLogLevelVerbose: level = NULogLevelVerbose; break;
        case DDLogLevelAll: level = NULogLevelVerbose; break;
    }
    
    return level;
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self requestSession];
}

@end
