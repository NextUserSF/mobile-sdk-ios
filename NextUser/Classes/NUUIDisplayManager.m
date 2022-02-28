#import <Foundation/Foundation.h>
#import "NUUIDisplayManager.h"
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
#import "NUJSONTransformer.h"
#import "NUWebViewContainer.h"

#define kIAMMessageJSONKey @"message"

@interface NUUIDisplayManager() <InAppMsgInteractionListener, NUWebViewContainerListener>
{
    NSOperationQueue *queue;
    InAppMsgViewSettings *viewSettings;
    InAppMessageWrapperBuilder *wrapperBuilder;
    NUPopUpView *popup;
    InAppMsgWrapper* currentWrapper;
    dispatch_group_t iamPrepareGroup;
    id<NUWebViewUIDelegate> webViewDelegate;
    UIProgressView *progressView;
    NUTrackerSession *session;
}
@end

@implementation NUUIDisplayManager


-(instancetype) init
{
    self = [super init];
    if (self) {
        self->session = [[NextUserManager sharedInstance] getSession];
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

- (void) checkCaches
{
    if([self isShowing] == NO) {
        NSString *nextIamId = [[[NextUserManager sharedInstance] inAppMsgCacheManager] getNextMessageID];
        if (nextIamId != nil)
        {
            [self sendToQueue: nextIamId];
        }
    }

    NSString* nextSHAKey = [[[NextUserManager sharedInstance] inAppMsgCacheManager] getNextSHAKey];
    if (nextSHAKey != nil) {
        NUTaskManager* manager = [NUTaskManager manager];
        NUTrackerTask* task = [[NUTrackerTask alloc] initForType:NEW_IAM withTrackObject:nextSHAKey withSession: self->session];
        [manager submitTask:task];
    }
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

-(BOOL) isShowing
{
    return currentWrapper != nil;
}

- (void) onIamDismissed:(NSDictionary *)userInfo
{
    NSString *messageID = [userInfo objectForKey:COMPLETION_MESSAGE_NOTIFICATION_OBJECT_KEY];
    [[[NextUserManager sharedInstance] inAppMsgCacheManager] onMessageDismissed: messageID];
    currentWrapper = nil;
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
        
            
            NUWebViewContainer *webViewContainer = [NUWebViewContainer initWithSettings:settings observerDelegate:self->webViewDelegate withViewSettings:self->viewSettings withContainerListener:self];
            
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
            
            __weak NUPopUpView *popupWeak = self->popup;
            self->popup.didFinishShowingCompletion = ^{
                DDLogVerbose(@"Show Web View completed");
                if (webViewContainer.isError == YES) {
                    [popupWeak dismiss:YES];
                }
            };
            
            self->popup.didFinishDismissingCompletion = ^{
                DDLogVerbose(@"Dismiss Web View completed");
            };
            
            [self->popup showWithLayout: [webViewContainer getFrameLayout]];
            
        } @catch(NSException *e) {
            DDLogError(@"Exception on Web View display: %@", [e reason]);
        } @catch(NSError *e) {
            DDLogError(@"Error on Web View display: %@", e);
        }
    });
}

#pragma mark - Observer selectors
-(void) setSession:(NUTrackerSession*) tSession
{
    session = tSession;
}

-(void)receiveNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NUTrackResponse* taskResponse = userInfo[COMPLETION_HTTP_REQUEST_NOTIFICATION_OBJECT_KEY];
    switch (taskResponse.taskType) {
        case NEW_IAM:
            [self onNewInAppMessage: taskResponse];
            break;
        default:
            break;
    }
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

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self checkCaches];
}

#pragma mark - interface impl methods



-(InAppMsgViewSettings *) viewSettings
{
    return viewSettings;
}

-(void) showNextInAppMessage
{
    [self checkCaches];
}

-(void) showWebView:(NUWebViewSettings *) settings withDelegate:(id<NUWebViewUIDelegate>) delegate
     withCompletion:(void (^)(BOOL success, NSError *error)) completion
{
    if (self->webViewDelegate != nil) {
        DDLogVerbose(@"Another Web View is already showing!");
        
        return;
    }
    
    self->webViewDelegate = delegate;
    [self displayWebViewOperationSelector: settings];
    completion(YES, nil);
}

-(void) showWebViewWithDictionary:(NSDictionary *) settingsInfo withDelegate:(id<NUWebViewUIDelegate>) delegate
     withCompletion: (void (^)(BOOL success, NSError*error))completion
{
    @try {
        NUWebViewSettings *settings = [[NUWebViewSettings alloc] init];
        settings.url = [settingsInfo valueForKey:@"url"];
        settings.url = [settings.url stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        settings.firstLoadJs = [settingsInfo valueForKey:@"firstLoadJs"];
        settings.enableNavigation = [[settingsInfo valueForKey:@"enableNavigation"] boolValue];
        settings.overrideOnLoading = [[settingsInfo valueForKey:@"overrideOnLoading"] boolValue];
        settings.spinnerMessage = [settingsInfo valueForKey:@"spinnerMessage"];
        settings.dimmedBackgroundSpinner = [[settingsInfo valueForKey:@"dimmedBackgroundSpinner"] boolValue];
        settings.suppressBrowserJSAlerts = [[settingsInfo valueForKey:@"suppressBrowserJSAlerts"] boolValue];
        settings.httpHeadersExtra = [settingsInfo valueForKey:@"httpHeadersExtra"];
        settings.enableNavigationToolbar = [[settingsInfo valueForKey:@"enableNavigationToolbar"] boolValue];
        settings.closeButtonCaption = [settingsInfo valueForKey:@"closeButtonCaption"];
        settings.closeButtonColor = [settingsInfo valueForKey:@"closeButtonColor"];
        settings.toolbarColor = [settingsInfo valueForKey:@"toolbarColor"];
        settings.navigationButtonColor = [settingsInfo valueForKey:@"navigationButtonColor"];
        settings.toolbarTranslucent = [[settingsInfo valueForKey:@"toolbarTranslucent"] boolValue];
        settings.hideNavigationButtons = [[settingsInfo valueForKey:@"hideNavigationButtons"] boolValue];
        settings.hideCloseButton = [[settingsInfo valueForKey:@"hideCloseButton"] boolValue];
        settings.enableSwipeNavigation = [[settingsInfo valueForKey:@"enableSwipeNavigation"] boolValue];
        
        if ([settingsInfo valueForKey:@"customJSCodes"] != nil) {
            NSArray *customJsCodesArrray = [settingsInfo valueForKey:@"customJSCodes"];
            if ([customJsCodesArrray count] > 0) {
                NSMutableArray<NUCustomJSCode *> *jsCodes = [[NSMutableArray<NUCustomJSCode *> alloc] initWithCapacity:[customJsCodesArrray count]];
                for (NSDictionary *jsCodeDict in customJsCodesArrray) {
                    NSString *conditionStr = [jsCodeDict valueForKey:@"condition"];
                    NUCustomJSCode *jsCode = [NUCustomJSCode customJSCodeWithContionString: conditionStr];
                    jsCode.jsCodeString = [jsCodeDict valueForKey:@"jsCode"];
                    jsCode.pageURL = [jsCodeDict valueForKey:@"pageURL"];
                    [jsCodes addObject:jsCode];
                }
                settings.customJSCodes = jsCodes;
            }
        }
        
        [self showWebView:settings withDelegate:delegate withCompletion:completion];
    } @catch (NSException *exception) {
        completion(NO, [NUError nextUserErrorWithMessage:exception.reason]);
    }
}

#pragma mark - InAppMsgInteractionListener methods

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
#pragma mark - NUWebViewContainerListener methods

- (void) onClose
{
    DDLogVerbose(@"Closing Web View");
    self->webViewDelegate = nil;
    [self->progressView removeFromSuperview];
    [popup dismiss:YES];
}


@end
