#import <Foundation/Foundation.h>
#import "NUInAppMsgViewSettings.h"
#import "NUInAppMessageUIView.h"
#import "NUInAppMsgWrapper.h"
#import "NUWebViewSettings.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NUWebViewHelper.h"
#import "NUWebViewContainer.h"

@interface InAppMsgUIManager : NSObject <InAppMsgInteractionListener, NUWebViewContainerListener>

-(void) sendToQueue:(NSString*) iamId;
-(InAppMsgViewSettings*) viewSettings;
-(BOOL) isShowing;
-(void) showWebView:(NUWebViewSettings *) settings withDelegate:(id<NUWebViewUIDelegate>) delegate
     withCompletion: (void (^)(BOOL success, NSError*error))completion;
@end
