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
#import "NUError.h"

@interface InAppMsgUIManager()
{
    NSOperationQueue *queue;
    InAppMsgViewSettings *viewSettings;
    InAppMessageWrapperBuilder *wrapperBuilder;
    NUPopUpView *popup;
    InAppMsgWrapper* currentWrapper;
    dispatch_group_t iamPrepareGroup;
    void (^webViewCompletion)(BOOL success, NSError *error);
    id<NUWebViewUIDelegate> webViewDelegate;
    UIProgressView *progressView;
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
            self->currentWrapper = wrapper;
            dispatch_group_leave(self->iamPrepareGroup);
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessageNotification:)
                                                     name:COMPLETION_TASK_MANAGER_MESSAGE_NOTIFICATION_NAME object:nil];
    }
    
    return self;
}

-(void) sendToQueue:(NSString *) iamID
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayIAMOperationSelector:) object:iamID]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on sendToQueue for iamID: %@%@", iamID, [exception reason]);
    }
}


-(void) displayIAMOperationSelector:(NSString *) iamID
{
    
    @try {
        DDLogVerbose(@"Start IAM display preparations:%@", iamID);
        dispatch_group_enter(iamPrepareGroup);
        InAppMessage* message = [[[NextUserManager sharedInstance] inAppMsgCacheManager] fetchMessage: iamID];
        if (message != nil) {
            [wrapperBuilder prepare:message];
        }
        
        dispatch_group_notify(iamPrepareGroup, dispatch_get_main_queue(), ^{
            DDLogVerbose(@"IAM iamPrepareGroup");
            
            if ([self->currentWrapper state] != READY) {
                DDLogError(@"Invalid IAM preparation state :%@ ", iamID);
                
                return;
            }
            
            @try {
                DDLogVerbose(@"IAM preparation succcessful:%@", iamID);
                self->currentWrapper.interactionListener = self;
                InAppMsgContentView *contentView;
                switch (self->currentWrapper.message.type) {
                    case SKINNY:
                        contentView = [[InAppMsgSkinnyContentView alloc] initWithWrapper:self->currentWrapper withSettings:self->viewSettings];
                        
                        break;
                    case MODAL:
                        contentView = [[InAppMsgModalContentView alloc] initWithWrapper:self->currentWrapper withSettings:self->viewSettings];
                        
                        break;
                    case FULL:
                        contentView = [[InAppMsgFullContentView alloc] initWithWrapper:self->currentWrapper withSettings:self->viewSettings];
                        
                        break;
                    default:
                        DDLogError(@"IAM Type not defined.");
                        
                        return;
                }
                
                __weak NSString *trackParams = self->currentWrapper.message.interactions.nuTrackingParams;
                NUPopUpLayout layout = [contentView getLayout];
                if (UIApplication.sharedApplication.keyWindow == nil) {
                    self->popup = [NUPopUpView popupWithContentView:contentView
                                                    withFrame:UIApplication.sharedApplication.keyWindow.frame
                                                     showType:NUPopUpShowTypeSlideInFromLeft
                                                  dismissType:NUPopUpDismissTypeSlideOutToRight
                                                     maskType:NUPopUpMaskTypeNone
                                     dismissOnBackgroundTouch:NO
                                        dismissOnContentTouch:NO];
                } else {
                    self->popup = [NUPopUpView popupWithContentView:contentView
                                                     showType:NUPopUpShowTypeSlideInFromLeft
                                                  dismissType:NUPopUpDismissTypeSlideOutToRight
                                                     maskType:NUPopUpMaskTypeNone
                                     dismissOnBackgroundTouch:NO
                                        dismissOnContentTouch:NO];
                }
                
                self->popup.didFinishShowingCompletion = ^{
                    DDLogVerbose(@"Show IAM completed: %@", iamID);
                    [InternalEventTracker trackEvent:TRACK_EVENT_DISPLAYED withParams:trackParams];
                };
                
                self->popup.didFinishDismissingCompletion = ^{
                    DDLogVerbose(@"Dismiss IAM completed.Free IAM queue: %@", iamID);
                    [InternalEventTracker trackEvent:TRACK_EVENT_DISMISSED withParams:trackParams];
                    [[NUTaskManager manager] dispatchMessageNotification:IAM_DISMISSED withObject:[message ID]];
                };
                
                if (self->currentWrapper.message.dismissTimeout != 0) {
                    [self->popup showWithLayout:layout duration: [self->currentWrapper.message.dismissTimeout intValue] / 1000];
                } else {
                    DDLogVerbose(@"Before IAM show: %@", iamID);
                    [self->popup showWithLayout:layout];
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
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: clickConfig.value] options:[[NSMutableDictionary alloc] init] completionHandler:nil];
            }
            break;
        default:
            break;
    }
    [popup dismiss:YES];
}

- (void) onClose
{
    DDLogVerbose(@"Closing Web View");
    self->webViewCompletion = nil;
    self->webViewDelegate = nil;
    [self->progressView removeFromSuperview];
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

-(void) showWebView:(NUWebViewSettings *) settings withDelegate:(id<NUWebViewUIDelegate>) delegate
     withCompletion:(void (^)(BOOL success, NSError *error)) completion
{
    if (self->webViewDelegate != nil) {
        DDLogVerbose(@"Another Web View is already showing!");
        
        return;
    }
    
    self->webViewDelegate = delegate;
    self->webViewCompletion = completion;
    [self displayWebViewOperationSelector: settings];
}


-(void) sendWebViewToQueue:(NUWebViewSettings *) settings
{
    @try {
        [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayWebViewOperationSelector:) object:settings]];
    } @catch (NSException *exception) {
        DDLogError(@"Exception on sendWebViewToQueue for iamID: %@",[exception reason]);
    }
}

-(void) displayWebViewOperationSelector:(NUWebViewSettings *) settings
{
    
    dispatch_async( dispatch_get_main_queue(), ^{
        
        @try {
            DDLogVerbose(@"Showing WebView...");
            NUWebViewContainer *webViewContainer = [NUWebViewContainer initWithSettings:settings observerDelegate:self->webViewDelegate withViewSettings:viewSettings withContainerListener:self];
            
            __weak void (^webViewCompletionWeak)(BOOL success, NSError *error) = self->webViewCompletion;
            if (UIApplication.sharedApplication.keyWindow == nil) {
                self->popup = [NUPopUpView popupWithContentView:webViewContainer
                                                withFrame:UIApplication.sharedApplication.keyWindow.frame
                                                 showType:NUPopUpShowTypeSlideInFromLeft
                                              dismissType:NUPopUpDismissTypeSlideOutToRight
                                                 maskType:NUPopUpMaskTypeNone
                                 dismissOnBackgroundTouch:NO
                                    dismissOnContentTouch:NO];
            } else {
                self->popup = [NUPopUpView popupWithContentView:webViewContainer
                                                 showType:NUPopUpShowTypeSlideInFromLeft
                                              dismissType:NUPopUpDismissTypeSlideOutToRight
                                                 maskType:NUPopUpMaskTypeDimmed
                                 dismissOnBackgroundTouch:NO
                                    dismissOnContentTouch:NO];
            }
            
            self->popup.didFinishShowingCompletion = ^{
                DDLogVerbose(@"Show Web View completed");
                webViewCompletionWeak(true, nil);
            };
            
            self->popup.didFinishDismissingCompletion = ^{
                DDLogVerbose(@"Dismiss Web View completed");
            };
            
            [self->popup showWithLayout: [webViewContainer getFrameLayout]];
            
        } @catch(NSException *e) {
            DDLogError(@"Exception on Web View display: %@", [e reason]);
            self->webViewCompletion(false, [NUError nextUserErrorWithMessage: e.reason]);
        } @catch(NSError *e) {
            DDLogError(@"Error on Web View display: %@", e);
            self->webViewCompletion(false, e);
        }
    });
}

@end
