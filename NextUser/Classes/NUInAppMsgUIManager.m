#import <Foundation/Foundation.h>
#import "NUInAppMsgUIManager.h"
#import "NextUserManager.h"
#import "NUInAppMessageWrapperBuilder.h"
#import "NUInAppMsgSkinnyContentView.h"
#import "NUInAppMsgFullContentView.h"
#import "NUInAppMsgModalContentView.h"
#import "NUInAppMsgSkinnyContentView.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"
#import "NUInternalTracker.h"
#import "NUTaskManager.h"

@interface InAppMsgUIManager()
{
    NSOperationQueue *queue;
    InAppMsgViewSettings *viewSettings;
    InAppMessageWrapperBuilder *wrapperBuilder;
    NUPopUpView *popup;
    InAppMsgWrapper* currentWrapper;
    dispatch_group_t iamPrepareGroup;
}
@end

@implementation InAppMsgUIManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [queue setName:@"com.nextuser.iamsDisplayQueue"];
        viewSettings = [[InAppMsgViewSettings alloc] init];
        iamPrepareGroup = dispatch_group_create();
        wrapperBuilder = [[InAppMessageWrapperBuilder alloc] initWithCompetion:^(InAppMsgWrapper *wrapper) {
            currentWrapper = wrapper;
            dispatch_group_leave(iamPrepareGroup);
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessageNotification:)
                                                     name:COMPLETION_TASK_MANAGER_MESSAGE_NOTIFICATION_NAME object:nil];
    }
    
    return self;
}

-(void) sendToQueue:(NSString *) iamID
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayOperationSelector:) object:iamID]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on sendToQueue for iamID: %@%@", iamID, [exception reason]);
    }
}

-(void) displayOperationSelector:(NSString *) iamID
{
    
    @try {
        DDLogVerbose(@"Start IAM display preparations:%@", iamID);
        dispatch_group_enter(iamPrepareGroup);
        InAppMessage* message = [[[NextUserManager sharedInstance] inAppMsgCacheManager] fetchMessage: iamID];
        if (message != nil) {
            [wrapperBuilder prepare:message];
        }
        
        dispatch_group_notify(iamPrepareGroup, dispatch_get_main_queue(), ^{
            if ([currentWrapper state] != READY) {
                DDLogVerbose(@"Invalid IAM preparation state :%@ ", iamID);
                
                return;
            }
            
            @try {
                DDLogVerbose(@"IAM preparation succcessful:%@", iamID);
                currentWrapper.interactionListener = self;
                InAppMsgContentView *contentView;
                switch (currentWrapper.message.type) {
                    case SKINNY:
                        contentView = [[InAppMsgSkinnyContentView alloc] initWithWrapper:currentWrapper withSettings:viewSettings];
                        
                        break;
                    case MODAL:
                        contentView = [[InAppMsgModalContentView alloc] initWithWrapper:currentWrapper withSettings:viewSettings];
                        
                        break;
                    case FULL:
                        contentView = [[InAppMsgFullContentView alloc] initWithWrapper:currentWrapper withSettings:viewSettings];
                        
                        break;
                    default:
                        DDLogError(@"IAM Type not defined.");
                        
                        return;
                }
                
                __weak NSString *trackParams = currentWrapper.message.interactions.nuTrackingParams;
                NUPopUpLayout layout = [contentView getLayout];
                if (UIApplication.sharedApplication.keyWindow == nil) {
                    popup = [NUPopUpView popupWithContentView:contentView
                                                    withFrame:UIApplication.sharedApplication.keyWindow.frame
                                                     showType:NUPopUpShowTypeSlideInFromLeft
                                                  dismissType:NUPopUpDismissTypeSlideOutToRight
                                                     maskType:NUPopUpMaskTypeNone
                                     dismissOnBackgroundTouch:NO
                                        dismissOnContentTouch:NO];
                } else {
                    popup = [NUPopUpView popupWithContentView:contentView
                                                     showType:NUPopUpShowTypeSlideInFromLeft
                                                  dismissType:NUPopUpDismissTypeSlideOutToRight
                                                     maskType:NUPopUpMaskTypeNone
                                     dismissOnBackgroundTouch:NO
                                        dismissOnContentTouch:NO];
                }
                
                popup.didFinishShowingCompletion = ^{
                    DDLogVerbose(@"Show IAM completed: %@", iamID);
                    [InternalEventTracker trackEvent:TRACK_EVENT_DISPLAYED withParams:trackParams];
                };
                
                popup.didFinishDismissingCompletion = ^{
                    DDLogVerbose(@"Dismiss IAM completed.Free IAM queue: %@", iamID);
                    [InternalEventTracker trackEvent:TRACK_EVENT_DISMISSED withParams:trackParams];
                    [[NUTaskManager manager] dispatchMessageNotification:IAM_DISMISSED withObject:[message ID]];
                };
                
                if (currentWrapper.message.dismissTimeout != 0) {
                    [popup showWithLayout:layout duration: [currentWrapper.message.dismissTimeout intValue] / 1000];
                } else {
                    DDLogVerbose(@"Before IAM show: %@", iamID);
                    [popup showWithLayout:layout];
                }
            } @catch(NSException *e) {
                DDLogError(@"Exception on IAM display: %@", [e reason]);
            } @catch(NSError *e) {
                DDLogError(@"Error on IAM display: %@", e);
            }
        });
    } @catch(NSException *e) {
        DDLogError(@"Exception on IAM prepare: %@", [e reason]);
    } @catch(NSError *e) {
        DDLogError(@"Error on IAM prepare: %@", e);
    }
}

- (void) onInteract:(InAppMsgClick *) clickConfig
{
    DDLogVerbose(@"Interacted with IAM");
    [InternalEventTracker trackEvent:TRACK_EVENT_CLICKED withParams:currentWrapper.message.interactions.nuTrackingParams];
    if (clickConfig == nil || clickConfig.action == NO_ACTION) {
        [popup dismiss:YES];
        
        return;
    }
    
    if (clickConfig.trackEvents != nil) {
        [[[NextUserManager sharedInstance] getTracker] trackEvents:clickConfig.trackEvents];
    }
    
    DDLogVerbose(@"Interacted with iam:%lu", (unsigned long)clickConfig.action);
    
    switch (clickConfig.action) {
        case URL:
        case DEEP_LINK:
            if ([NSString lg_isEmptyString:clickConfig.value] == NO) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: clickConfig.value]];
            }
            break;
        default:
            break;
    }
    [popup dismiss:YES];
}

-(InAppMsgViewSettings *) viewSettings
{
    return viewSettings;
}

-(BOOL) isShowing
{
    return currentWrapper != nil;
}

-(void)receiveMessageNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NUTaskType type = [[userInfo valueForKey:COMPLETION_MESSAGE_NOTIFICATION_TYPE_KEY] intValue];
    switch (type) {
        case IAM_DISMISSED:
            [self onIamDismissed:userInfo];
            break;
        default:
            break;
    }
}

- (void) onIamDismissed:(NSDictionary *)userInfo
{
    NSString *messageID = [userInfo objectForKey:COMPLETION_MESSAGE_NOTIFICATION_OBJECT_KEY];
    [[[NextUserManager sharedInstance] inAppMsgCacheManager] onMessageDismissed: messageID];
    currentWrapper = nil;
}

@end
