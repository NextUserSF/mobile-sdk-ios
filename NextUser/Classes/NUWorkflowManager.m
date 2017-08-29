//
//  NUIamWorkflowManager.m
//  Pods
//
//  Created by Adrian Lazea on 11/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUWorkflowManager.h"
#import "NUTaskManager.h"
#import "NUWorkflows.h"
#import "NUTrackerSession.h"
#import "NUTrackerTask.h"
#import "NUDDLog.h"
#import "NUJSONTransformer.h"
#import "NUInAppMsgCacheManager.h"
#import "NextUserManager.h"

@interface NUWorkflowManager ()
{
    NSOperationQueue* queue;
    NSMutableArray<Workflow *>* workFlows;
    NSLock* WORKFLOWS_LOCK;

}

-(void) decodeWorkflowsJSON:(NSDictionary*) instantWorkflowsJSON;
-(void) workflowConditionCheck:(WorkflowCondition*) condition;
-(void) removeWorkflow:(NSString*) iamID;

@end


@implementation NUWorkflowManager

-(instancetype)initWithSession:(NUTrackerSession*) tSession
{
    NUWorkflowManager* instance = [[NUWorkflowManager alloc] init];
    _session = tSession;
    [self requestInstantWorkflows: SESSION_INITIALIZATION];

    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [queue setName:@"com.nextuser.workflowConditionsQueue"];
        WORKFLOWS_LOCK = [[NSLock alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTaskManagerNotification:)
                                                     name:COMPLETION_TASK_MANAGER_NOTIFICATION_NAME object:nil];
    }
    
    return self;
}

-(void) decodeWorkflowsJSON:(NSDictionary*) instantWorkflowsJSON
{
    DDLogVerbose(@"IdecodeWorkflowsJSON");
    NSMutableArray<InAppMessage* >* messages = [NUJSONTransformer toInAppMessages:[instantWorkflowsJSON objectForKey:@"messages"]];
    if (messages != nil && [messages count] > 0)
    {
        NUInAppMsgCacheManager* iamsCacheManager = [[NextUserManager sharedInstance] getInAppMsgCacheManager];
        [iamsCacheManager cacheMessages:messages];
    }
    
    workFlows = [NUJSONTransformer toWorkflows:[instantWorkflowsJSON objectForKey:@"workFlows"]];
}



-(void)receiveTaskManagerNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NUTrackResponse* taskResponse = userInfo[COMPLETION_NOTIFICATION_OBJECT_KEY];
    WorkflowRule rule = NO_RULE;
    NSString* value;
    
    switch (taskResponse.taskType) {
        case TRACK_USER:
            [self requestInstantWorkflows:taskResponse.taskType];
            break;
        case REQUEST_IN_APP_MESSAGES:
            [self onInAppMsgRequest:taskResponse];
            break;
        case TRACK_ACTION:
            for(NSString* action in [taskResponse getTrackObject]) {
                [queue addOperation:[self createWorkflowOperationForType:ACTION withValue:action]];
            }
            break;
        case TRACK_PURCHASE:
            rule = PURCHASE;
            value = @"true";
            break;
        case TRACK_SCREEN:
            rule = SCREEN_VIEW;
            break;
        default:
            break;
    }
    
    if (rule != NO_RULE) {
        [queue addOperation:[self createWorkflowOperationForType:rule withValue:value]];
    }
}

- (void) requestInstantWorkflows:(NUTaskType) type {
    if (_session.requestInAppMessages == YES) {
        NUTaskManager* manager = [NUTaskManager manager];
        NUTrackerTask* task = [[NUTrackerTask alloc] initForType:REQUEST_IN_APP_MESSAGES withTrackObject:[NSNumber numberWithInt:type] withSession:_session];
        [manager submitTask:task];
    }
}

- (void) onInAppMsgRequest:(NUTrackResponse*) response
{
    
    
    NSString* requestString = @"{\"instant_workflows\":{\"messages\":[{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"text\":\"TITLE\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":1,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_full\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{\"text\":\"CONTENT\"},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"},{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"right\",\"text\":\"BUTTON 2\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"text\":\"TITLE\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":11,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_full\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":2,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full_no_title\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_no_title\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":3,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full_only_image\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_only_image\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":true,\"id\":4,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full_only_image_floating\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_only_image_floating\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{\"text\":\"CONTENT\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"},{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"right\",\"text\":\"BUTTON 2\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"center\",\"text\":\"TITLE\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":5,\"interactions\":{\"click\":{\"params\":\"234,566,3,5\",\"track\":\"_modal_only_text_default_click\"},\"click0\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_modal_only_text_click0\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"click1\":{\"action\":\"dismiss\",\"params\":\"234,566,3,5\",\"track\":\"_modal_only_text_click1\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_modal_only_text_\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{\"align\":\"center\",\"text\":\"CONTENT\"},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"center\",\"text\":\"TITLE\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":6,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full_only_image_floating\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_only_image_floating\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"}],\"workFlows\":[{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_1\"}],\"iamId\":1,\"id\":1},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_11\"}],\"iamId\":11,\"id\":11},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_2\"}],\"iamId\":2,\"id\":2},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_3\"}],\"iamId\":3,\"id\":3},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_4\"}],\"iamId\":4,\"id\":4},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_5\"}],\"iamId\":5,\"id\":5},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_6\"}],\"iamId\":6,\"id\":6}]}}";
    
    NSData *data = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *errorJson=nil;
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
    
   
    NSDictionary* inAppMsgsRequestJSON = [responseDict objectForKey:@"instant_workflows"];
    DDLogVerbose(@"Instant workflows response: %@", inAppMsgsRequestJSON);
    if (inAppMsgsRequestJSON != nil)
    {
        [self decodeWorkflowsJSON: inAppMsgsRequestJSON];
        [queue addOperation:[self createWorkflowOperationForType:NEW_SESSION withValue:@"true"]];
    }
}

-(NSOperation*) createWorkflowOperationForType:(WorkflowRule) rule withValue:(NSString*) value
{
    WorkflowCondition* condition = [[WorkflowCondition alloc] init];
    condition.rule = rule;
    condition.value = value;
    
    return [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(workflowConditionCheck:) object:condition];
}

-(void)workflowConditionCheck:(WorkflowCondition*) condition
{
    if (workFlows == nil || [workFlows count] == 0) {
        return;
    }
    
    if ([WORKFLOWS_LOCK tryLock]) {
        @try
        {
            NSString* nextIamID = nil;
            for (Workflow* wk in workFlows) {
                if ([wk hasCondition:condition]) {
                    nextIamID = wk.iamID;
                    break;
                }
            }
            
            if (nextIamID != nil) {
                //send iam id to in app messanger queue for display
            }
            
            
        } @catch (NSException *exception) {
            DDLogError(@"Exception on workflows conditions check: %@", [exception reason]);
        } @finally {
            [WORKFLOWS_LOCK unlock];
        }
    }
}

-(void) removeWorkflow:(NSString*) iamID
{
    if ([WORKFLOWS_LOCK tryLock]) {
        @try
        {
            NSMutableArray *discardedItems = [NSMutableArray array];
            for (Workflow* item in workFlows) {
                if ([item.iamID isEqual:iamID])
                    [discardedItems addObject:item];
            }
            
            [workFlows removeObjectsInArray:discardedItems];
            
        } @catch (NSException *exception) {
            DDLogError(@"Exception on workflows removal for iamID: %@%@",iamID, [exception reason]);
        } @finally {
            [WORKFLOWS_LOCK unlock];
        }
    }
}

@end
