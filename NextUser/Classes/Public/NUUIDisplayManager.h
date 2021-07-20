//
//  NUUIDisplayManager.h
//  NextUser
//
//  Created by Adrian Lazea on 14.07.2021.
//

#ifndef NUUIDisplayManager_h
#define NUUIDisplayManager_h
#import <Foundation/Foundation.h>
#import "NUWebViewSettings.h"
#import "NUCustomJSCode.h"

#define NU_WEB_VIEW_SCHEME @"nextuser"
#define NU_URL_AUTHORITY_CLOSE @"close"
#define NU_URL_AUTHORITY_RELOAD @"reload"

#define ON_WEB_VIEW_START_LOADING_EVENT_NAME @"onWebViewStartLoading"
#define ON_WEB_VIEW_LOADING_PROGRESS_EVENT_NAME @"onWebViewLoadingProgress"
#define ON_WEB_VIEW_FINISH_LOADING_EVENT_NAME @"onWebViewFinishedLoading"
#define ON_WEB_VIEW_LOADING_ERROR_EVENT_NAME @"onWebViewLoadingError"
#define ON_WEB_VIEW_DATA_SENT_EVENT_NAME @"onWebViewDataSent"
#define ON_WEB_VIEW_CLOSE_EVENT_NAME @"onWebViewClose"


@interface NUUIDisplayManager : NSObject 

-(void) showNextInAppMessage;
-(void) showWebView:(NUWebViewSettings *) settings withDelegate:(id<NUWebViewUIDelegate>) delegate
     withCompletion: (void (^)(BOOL success, NSError*error))completion;
-(void) showWebViewWithDictionary:(NSDictionary *) settings withDelegate:(id<NUWebViewUIDelegate>) delegate
     withCompletion: (void (^)(BOOL success, NSError*error))completion;

@end

#endif /* NUUIDisplayManager_h */
