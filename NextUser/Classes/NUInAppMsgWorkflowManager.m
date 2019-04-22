#import <Foundation/Foundation.h>
#import "NUInAppMsgWorkflowManager.h"
#import "NUTrackerSession.h"
#import "NUTask.h"
#import "NUTaskManager.h"
#import "NUTrackerTask.h"
#import "NUDDLog.h"
#import "NUJSONTransformer.h"
#import "NUInAppMsgCacheManager.h"
#import "NextUserManager.h"

#define kIAMMessageJSONKey @"message"

@interface WorkflowManager ()
{
    NUTrackerSession* session;
    BOOL messageConsumed;
}

@end

@implementation WorkflowManager

+(instancetype)initWithSession:(NUTrackerSession*) tSession
{
    WorkflowManager* instance = [[WorkflowManager alloc] init:tSession];
    
    return instance;
}

-(instancetype)init:(NUTrackerSession*) tSession
{
    self = [super init];
    if (self) {
        session = tSession;
        messageConsumed = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:)
                                                     name:COMPLETION_TASK_MANAGER_HTTP_REQUEST_NOTIFICATION_NAME object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackgroundNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [self checkCaches];
    }
    
    return self;
}

-(void) setSession:(NUTrackerSession*) tSession
{
    session = tSession;
}

-(void)receiveNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NUTrackResponse* taskResponse = userInfo[COMPLETION_HTTP_REQUEST_NOTIFICATION_OBJECT_KEY];
    switch (taskResponse.taskType) {
        case TRACK_EVENT:
            [self onTrackEvent: [taskResponse trackObject]];
            break;
        case NEW_IAM:
            [self onNewInAppMessage: taskResponse];
            break;
        default:
            break;
    }
}

- (void) checkCaches
{
    if(messageConsumed == NO && [[[NextUserManager sharedInstance] inAppMsgUIManager] isShowing] == NO) {
        NSString *nextIamId = [[[NextUserManager sharedInstance] inAppMsgCacheManager] getNextMessageID];
        if (nextIamId != nil)
        {
            [[[NextUserManager sharedInstance] inAppMsgUIManager] sendToQueue: nextIamId];
            messageConsumed = YES;
        }
    }

    NSString* nextSHAKey = [[[NextUserManager sharedInstance] inAppMsgCacheManager] getNextSHAKey];
    if (nextSHAKey != nil)
    {
        NUTaskManager* manager = [NUTaskManager manager];
        NUTrackerTask* task = [[NUTrackerTask alloc] initForType:NEW_IAM withTrackObject:nextSHAKey withSession:session];
        [manager submitTask:task];
    }
}

- (void) onTrackEvent: (id) trackObject
{
//    NUTaskManager* manager = [NUTaskManager manager];
//    NUTrackerTask* task = [[NUTrackerTask alloc] initForType:IAM_CHECK_EVENT withTrackObject:trackObject withSession:session];
//    [manager submitTask:task];
}

- (void) onNewInAppMessage: (NUTrackResponse*) taskResponse
{
    if ([taskResponse successfull] == YES)
    {
        NSError *errorJson=nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:taskResponse.reponseData options:kNilOptions error:&errorJson];
        NSData *inAppMsgData = [[responseDict objectForKey: kIAMMessageJSONKey] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* inAppMsgDict = [NSJSONSerialization JSONObjectWithData:inAppMsgData options:NSJSONReadingMutableContainers error:&errorJson];
        if (inAppMsgDict != nil)
        {
            InAppMessage *message = [NUJSONTransformer toInAppMessage: inAppMsgDict];
            if (message != nil)
            {
                [[[NextUserManager sharedInstance] inAppMsgCacheManager] cacheMessage: message];
                [[[NextUserManager sharedInstance] inAppMsgCacheManager] removeSha: [message storageIdentifier]];
                [self checkCaches];
            }
        }
    }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    messageConsumed = NO;
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self checkCaches];
}

@end
