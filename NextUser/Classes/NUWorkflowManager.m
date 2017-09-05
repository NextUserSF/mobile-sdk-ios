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
#import "NUWorkflow.h"
#import "NUTrackerTask.h"
#import "NUDDLog.h"
#import "NUJSONTransformer.h"
#import "NUInAppMsgCacheManager.h"
#import "NextUserManager.h"

@interface WorkflowManager ()
{
    NSOperationQueue* queue;
    NSMutableArray<Workflow *>* workFlows;
    NSLock* WORKFLOWS_LOCK;
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
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [queue setName:@"com.nextuser.workflowConditionsQueue"];
        WORKFLOWS_LOCK = [[NSLock alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:)
                                                     name:COMPLETION_TASK_MANAGER_NOTIFICATION_NAME object:nil];
    }
    
    [self requestInstantWorkflows: SESSION_INITIALIZATION];
    
    return self;
}

-(void) setSession:(NUTrackerSession*) tSession
{
    session = tSession;
    [self requestInstantWorkflows: SESSION_INITIALIZATION];
}

-(void) decodeWorkflowsJSON:(NSDictionary*) instantWorkflowsJSON
{
    DDLogVerbose(@"IdecodeWorkflowsJSON");
    NSMutableArray<InAppMessage* >* messages = [NUJSONTransformer toInAppMessages:[instantWorkflowsJSON objectForKey:@"messages"]];
    if (messages != nil && [messages count] > 0)
    {
        [[[NextUserManager sharedInstance] inAppMsgCacheManager] cacheMessages:messages];
    }
    
    workFlows = [NUJSONTransformer toWorkflows:[instantWorkflowsJSON objectForKey:@"workFlows"]];
}


-(void)receiveNotification:(NSNotification *) notification
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
            [[NextUserManager sharedInstance] inAppMessagesRequested];
            break;
        case TRACK_ACTION:
            for(NUAction* action in [taskResponse getTrackObject]) {
                [queue addOperation:[self createWorkflowOperationForType:ACTION withValue:[action actionName]]];
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
    if (session.requestInAppMessages == YES) {
        NUTaskManager* manager = [NUTaskManager manager];
        NUTrackerTask* task = [[NUTrackerTask alloc] initForType:REQUEST_IN_APP_MESSAGES withTrackObject:[NSNumber numberWithInt:type] withSession:session];
        [manager submitTask:task];

    }
}

- (void) onInAppMsgRequest:(NUTrackResponse*) response
{
    
    
//    NSString* fullIamsRequestStr = @"{\"instant_workflows\":{\"messages\":[{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{},\"cover\":{\"url\":\"https://d15hng3vemx011.cloudfront.net/attachment/37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"text\":\"TITLE\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":1,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_full\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{\"text\":\"CONTENT\"},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"},{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"right\",\"text\":\"BUTTON 2\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"text\":\"TITLE\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":11,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_full\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":2,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full_no_title\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_no_title\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":3,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full_only_image\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_only_image\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"left\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":true,\"id\":4,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full_only_image_floating\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_only_image_floating\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{\"text\":\"CONTENT\"},\"footer\":[{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"left\",\"text\":\"BUTTON 1\",\"textColor\":\"#ffffff\"},{\"selectedBGColor\":\"#0040FF\",\"unSelectedBgColor\":\"#478cc8\",\"align\":\"right\",\"text\":\"BUTTON 2\",\"textColor\":\"#ffffff\"}],\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"center\",\"text\":\"TITLE\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":5,\"interactions\":{\"click\":{\"params\":\"234,566,3,5\",\"track\":\"_modal_only_text_default_click\"},\"click0\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_modal_only_text_click0\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"click1\":{\"action\":\"dismiss\",\"params\":\"234,566,3,5\",\"track\":\"_modal_only_text_click1\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_modal_only_text_\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"},{\"autoDismiss\":false,\"backgroundColor\":\"#FFFFFF\",\"body\":{\"content\":{\"align\":\"center\",\"text\":\"CONTENT\"},\"cover\":{\"url\":\"https:\\\\\\\\d15hng3vemx011.cloudfront.net\\\\attachment\\\\37001274946437597022.large\"},\"header\":{\"align\":\"left\",\"text\":\"HEADER\",\"textColor\":\"#777777\"},\"title\":{\"align\":\"center\",\"text\":\"TITLE\",\"textColor\":\"#333333\"}},\"dismissColor\":\"#BDBDBD\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":6,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"234,566,3,5\",\"track\":\"_wt_full_only_image_floating\",\"value\":\"https:\\\\\\\\womantalk.com\\\\beauty\\\\articles\\\\4-jenis-kulit-wajah-dan-memilih-pembersih-makeup-yang-cocok-yaPro?page_source\\u003dhome\"},\"dismiss\":{\"params\":\"234,566,3,5\",\"track\":\"_dismiss_reco_only_image_floating\"}},\"position\":\"center\",\"showDismiss\":true,\"type\":\"FULL\"}],\"workFlows\":[{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_1\"}],\"iamId\":1,\"id\":1},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_11\"}],\"iamId\":11,\"id\":11},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_2\"}],\"iamId\":2,\"id\":2},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_3\"}],\"iamId\":3,\"id\":3},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_4\"}],\"iamId\":4,\"id\":4},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_5\"}],\"iamId\":5,\"id\":5},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"full_iam_6\"}],\"iamId\":6,\"id\":6}]}}";
    
    
    NSString* skinnyIamsRequestStr = @"{\"instant_workflows\":{\"messages\":[{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"left\",\"text\":\"-IMAGE\\n-HEADER(ALIGN LEFT)\\n-CONTENT(ALIGN LEFT)\\n\",\"textColor\":\"#191007\"},\"cover\":{\"url\":\"https://www.unilever.com/Images/becel_tcm244-408740.gif\"},\"title\":{\"align\":\"left\",\"text\":\"SKINNY IAM TOP\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":1,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"15,16,17,18\",\"track\":\"_click_skinny_top_text_image\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"11,12,13,14\",\"track\":\"_dismiss_skinny_top_text_image\"}},\"position\":\"top\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"right\",\"text\":\"-IMAGE\\n-HEADER(ALIGN RIGHT)\\n-CONTENT(ALIGN RIGHT)\\n\",\"textColor\":\"#191007\"},\"cover\":{\"url\":\"https://www.unilever.com/Images/becel_tcm244-408740.gif\"},\"title\":{\"align\":\"right\",\"text\":\"SKINNY IAM TOP\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":11,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"15,16,17,18\",\"track\":\"_click_skinny_top_text_image\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"11,12,13,14\",\"track\":\"_dismiss_skinny_top_text_image\"}},\"position\":\"top\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"center\",\"text\":\"-IMAGE\\n-HEADER(ALIGN CENTER)\\n-CONTENT(ALIGN CENTER)\\n\",\"textColor\":\"#191007\"},\"cover\":{\"url\":\"https://www.unilever.com/Images/becel_tcm244-408740.gif\"},\"title\":{\"align\":\"center\",\"text\":\"SKINNY IAM TOP\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":111,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"15,16,17,18\",\"track\":\"_click_skinny_top_text_image\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"11,12,13,14\",\"track\":\"_dismiss_skinny_top_text_image\"}},\"position\":\"top\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"center\",\"text\":\"SKINNY IAM TOP\\n-Image\\n-CONTENT(align center)\\n\",\"textColor\":\"#191007\"},\"cover\":{\"url\":\"https://www.unilever.com/Images/becel_tcm244-408740.gif\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":1111,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"15,16,17,18\",\"track\":\"_click_skinny_top_text_image\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"11,12,13,14\",\"track\":\"_dismiss_skinny_top_text_image\"}},\"position\":\"top\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"cover\":{\"url\":\"https://www.unilever.com/Images/becel_tcm244-408740.gif\"},\"title\":{\"align\":\"center\",\"text\":\"SKINNY IAM TOP\\n-IMAGE\\n-HEADER(ALIGN CENTER)\\n\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":11111,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"15,16,17,18\",\"track\":\"_click_skinny_top_text_image\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"11,12,13,14\",\"track\":\"_dismiss_skinny_top_text_image\"}},\"position\":\"top\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"left\",\"text\":\"-HEADER(ALIGN LEFT)\\n-CONTENT(ALIGN LEFT)\\n\",\"textColor\":\"#191007\"},\"title\":{\"align\":\"left\",\"text\":\"SKINNY IAM TOP\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":2,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"25,26,27,28\",\"track\":\"_click_skinny_top_text\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"21,22,23,24\",\"track\":\"_dismiss_skinny_top_text\"}},\"position\":\"top\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"right\",\"text\":\"-HEADER(ALIGN RIGHT)\\n-CONTENT(ALIGN RIGHT)\\n\",\"textColor\":\"#191007\"},\"title\":{\"align\":\"right\",\"text\":\"SKINNY IAM TOP\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":22,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"25,26,27,28\",\"track\":\"_click_skinny_top_text\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"21,22,23,24\",\"track\":\"_dismiss_skinny_top_text\"}},\"position\":\"top\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"center\",\"text\":\"-HEADER(ALIGN CENTER)\\n-CONTENT(ALIGN CENTER)\\n\",\"textColor\":\"#191007\"},\"title\":{\"align\":\"center\",\"text\":\"SKINNY IAM TOP\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":222,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"25,26,27,28\",\"track\":\"_click_skinny_top_text\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"21,22,23,24\",\"track\":\"_dismiss_skinny_top_text\"}},\"position\":\"top\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"cover\":{\"url\":\"https://static.vecteezy.com/system/assets/asset_files/000/000/517/original/vecteezy-promo-code.gif\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":3,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"35,36,37,38\",\"track\":\"_click_skinny_top_cover\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"31,32,33,34\",\"track\":\"_dismiss_skinny_top_cover\"}},\"position\":\"top\",\"showDismiss\":false,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"left\",\"text\":\"-IMAGE\\n-HEADER(ALIGN LEFT)\\n-CONTENT(ALIGN LEFT)\\n\",\"textColor\":\"#191007\"},\"cover\":{\"url\":\"https://www.unilever.com/Images/becel_tcm244-408740.gif\"},\"title\":{\"align\":\"left\",\"text\":\"SKINNY IAM BOTTOM\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":4,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"45,46,47,48\",\"track\":\"_click_skinny_bottom_text_image\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"41,42,43,44\",\"track\":\"_dismiss_skinny_bottom_text_image\"}},\"position\":\"bottom\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"content\":{\"align\":\"center\",\"text\":\"-HEADER(ALIGN CENTER)\\n-CONTENT(ALIGN CENTER)\\n\",\"textColor\":\"#191007\"},\"title\":{\"align\":\"center\",\"text\":\"SKINNY IAM BOTTOM\",\"textColor\":\"#191007\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":5,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"25,26,27,28\",\"track\":\"_click_skinny_bottom_text\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"21,22,23,24\",\"track\":\"_dismiss_skinny_bottom_text\"}},\"position\":\"bottom\",\"showDismiss\":true,\"type\":\"SKINNY\"},{\"autoDismiss\":false,\"backgroundColor\":\"#E6E6E6\",\"body\":{\"cover\":{\"url\":\"https://static.vecteezy.com/system/assets/asset_files/000/000/517/original/vecteezy-promo-code.gif\"}},\"dismissColor\":\"#DB0930\",\"dismissTimeout\":0,\"displayLimit\":-1,\"floatingButtons\":false,\"id\":6,\"interactions\":{\"click\":{\"action\":\"url\",\"params\":\"65,66,67,68\",\"track\":\"_click_skinny_bottom_cover\",\"value\":\"https://google.com\"},\"dismiss\":{\"params\":\"61,62,63,64\",\"track\":\"_dismiss_skinny_bottom_cover\"}},\"position\":\"bottom\",\"showDismiss\":false,\"type\":\"SKINNY\"}],\"workFlows\":[{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_1\"}],\"iamId\":1,\"id\":1},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_11\"}],\"iamId\":11,\"id\":11},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_111\"}],\"iamId\":111,\"id\":111},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_1111\"}],\"iamId\":1111,\"id\":1111},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_11111\"}],\"iamId\":11111,\"id\":11111},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_2\"}],\"iamId\":2,\"id\":2},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_3\"}],\"iamId\":3,\"id\":3},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_4\"}],\"iamId\":4,\"id\":4},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_5\"}],\"iamId\":5,\"id\":5},{\"conditions\":[{\"rule\":\"ACTION\",\"value\":\"skinny_iam_6\"}],\"iamId\":6,\"id\":6}]}}";
    
    NSData *data = [skinnyIamsRequestStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *errorJson=nil;
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errorJson];
    
   
    NSDictionary* inAppMsgsRequestJSON = [responseDict objectForKey:@"instant_workflows"];
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
                [[[NextUserManager sharedInstance] inAppMsgUIManager] sendToQueue:nextIamID];
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
            NSMutableArray *discardedItems = [NSMutableArray alloc];
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
