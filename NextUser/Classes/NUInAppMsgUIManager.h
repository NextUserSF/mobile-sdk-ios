#import <Foundation/Foundation.h>
#import "NUInAppMsgViewSettings.h"
#import "NUInAppMessageUIView.h"
#import "NUInAppMsgWrapper.h"

@interface InAppMsgUIManager : NSObject <InAppMsgInteractionListener>

-(void) sendToQueue:(NSString*) iamId;
-(InAppMsgViewSettings*) viewSettings;
-(BOOL) isShowing;

@end
