//
//  NUIamWorkflowManager.m
//  Pods
//
//  Created by Adrian Lazea on 11/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUWorkflowManager.h"
#import "NUTrackerSession.h"
#import "NUTask.h"
#import "NUTaskManager.h"
#import "NUTrackerTask.h"
#import "NUDDLog.h"
#import "NUJSONTransformer.h"
#import "NUInAppMsgCacheManager.h"
#import "NextUserManager.h"

#define kIAMMessageJSONKey @"message"
#define kIAMSHAJSONKey @"key"

@interface WorkflowManager ()
{
    NUTrackerSession* session;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:)
                                                     name:COMPLETION_TASK_MANAGER_NOTIFICATION_NAME object:nil];
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
    NUTrackResponse* taskResponse = userInfo[COMPLETION_NOTIFICATION_OBJECT_KEY];
    
    switch (taskResponse.taskType) {
        case SESSION_INITIALIZATION:
            [self checkCaches];
            break;
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
    NSMutableArray<InAppMessage* > *messages = [[[NextUserManager sharedInstance] inAppMsgCacheManager] fetchMessages];
    if (messages != nil)
    {
        for(InAppMessage *message in messages)
        {
            [[[NextUserManager sharedInstance] inAppMsgUIManager] sendToQueue: [message ID]];
        }
    }
    
    NSMutableArray<NSString* >  *shaList = [[[NextUserManager sharedInstance] inAppMsgCacheManager] fetchShaList];
    if (shaList != nil)
    {
        NUTaskManager* manager = [NUTaskManager manager];
        for(NSString *sha in shaList)
        {
            NUTrackerTask* task = [[NUTrackerTask alloc] initForType:NEW_IAM withTrackObject:sha withSession:session];
            [manager submitTask:task];
        }
    }
}

- (void) onTrackEvent: (id) trackObject
{
    NUTaskManager* manager = [NUTaskManager manager];
    NUTrackerTask* task = [[NUTrackerTask alloc] initForType:IAM_CHECK_EVENT withTrackObject:trackObject withSession:session];
    [manager submitTask:task];
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
                [[[NextUserManager sharedInstance] inAppMsgCacheManager] removeSha: [responseDict objectForKey: kIAMSHAJSONKey]];
                [[[NextUserManager sharedInstance] inAppMsgUIManager] sendToQueue: [message ID]];
            }
        }
    }
}

@end
