//
//  NUInAppMsgUIManager.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

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

@interface InAppMsgUIManager()
{
    NSOperationQueue *queue;
    InAppMsgViewSettings *viewSettings;
    NUPopUpView *popup;
    NSLock *IAMS_LOCK;
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
        IAMS_LOCK = [[NSLock alloc] init];
    }
    
    return self;
}

-(void) sendToQueue:(NSString *) iamID
{
    if ([IAMS_LOCK tryLock]) {
        @try
        {
            NSOperation *operation = [self createIamDisplayOperation:iamID];
            [queue addOperation:operation];
        } @catch (NSException *exception) {
            DDLogError(@"Exception on workflows removal for iamID: %@%@",iamID, [exception reason]);
        } @finally {
            [IAMS_LOCK unlock];
        }
    }
}


-(InAppMsgViewSettings *) viewSettings
{
    return viewSettings;
}


-(NSOperation *) createIamDisplayOperation:(NSString *) iamID
{
    return [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayOperationSelector:) object:iamID];
}

-(void)displayOperationSelector:(NSString *) iamID
{
    
    
    
    DDLogInfo(@"got in que with id:%@", iamID);
    dispatch_group_t iamDisplayGroup = dispatch_group_create();
    dispatch_group_enter(iamDisplayGroup);
    
    @try {
        
        InAppMessage* message = [[[NextUserManager sharedInstance] inAppMsgCacheManager] fetchMessage:iamID];
        if (message != nil) {
            InAppMsgWrapper* wrapper = [InAppMessageWrapperBuilder toWrapper:message];
            if (wrapper != nil) {
                DDLogInfo(@"we have the wrapper:%@", iamID);
                wrapper.interactionListener = self;
                
                
                InAppMsgContentView *contentView;
                switch (wrapper.message.type) {
                    case SKINNY:
                        contentView = [[InAppMsgSkinnyContentView alloc] initWithWrapper:wrapper withSettings:viewSettings];
                        break;
                    case MODAL:
                        contentView = [[InAppMsgModalContentView alloc] initWithWrapper:wrapper withSettings:viewSettings];
                        break;
                    case FULL:
                        contentView = [[InAppMsgFullContentView alloc] initWithWrapper:wrapper withSettings:viewSettings];
                        break;
                    default:
                        DDLogError(@"Iam Type not defined.");
                        dispatch_group_leave(iamDisplayGroup);
                        return;
                }
            
                NUPopUpLayout layout = [contentView getLayout];
                popup = [NUPopUpView popupWithContentView:contentView
                                                 showType:NUPopUpShowTypeSlideInFromLeft
                                              dismissType:NUPopUpDismissTypeSlideOutToRight
                                                 maskType:NUPopUpMaskTypeNone
                                 dismissOnBackgroundTouch:NO
                                    dismissOnContentTouch:YES];
                
                
                popup.didFinishShowingCompletion = ^{
                    DDLogInfo(@"show iam completed");
                };
                
                __weak dispatch_group_t weakGroup = iamDisplayGroup;
                popup.didFinishDismissingCompletion = ^{
                    DDLogInfo(@"dismiss iam completed..free queue:%@", iamID);
                    dispatch_group_leave(weakGroup);
                };
                
                if (wrapper.message.dismissTimeout != 0) {
                    [popup showWithLayout:layout duration: [wrapper.message.dismissTimeout intValue] / 1000];
                } else {
                    DDLogInfo(@"before we show:%@", iamID);
                    [popup showWithLayout:layout];
                }
                DDLogInfo(@"winter...%@", iamID);
                dispatch_group_wait(iamDisplayGroup, DISPATCH_TIME_FOREVER);
                DDLogInfo(@"summer again...%@", iamID);
            }
        }
        
    }@catch(NSException *e) {
        DDLogError(@"exception on iam display: %@", [e reason]);
        dispatch_group_leave(iamDisplayGroup);
    }@catch(NSError *e) {
        DDLogError(@"error on iam display: %@", e);
        dispatch_group_leave(iamDisplayGroup);
    }
}

- (void) onInteract:(InAppMsgClick *) clickConfig
{
    
    DDLogInfo(@"interacted with iam..");
    if (clickConfig == nil || !clickConfig.action || clickConfig.action == NO_ACTION) {
        [popup dismiss:YES];
        
        return;
    }
    
    DDLogInfo(@"interacted with iam:%lu", (unsigned long)clickConfig.action);
    
    switch (clickConfig.action) {
        case DISMISS:
            [popup dismiss:YES];
            break;
        case URL:
        case DEEP_LINK:
            if ([NSString lg_isEmptyString:clickConfig.value] == NO) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: clickConfig.value]];
            }
            break;
        case LANDING_PAGE:
            break;
        default:
            break;
    }
}

@end
