#import <Foundation/Foundation.h>
#import "NUInAppMsgWrapper.h"
#import "NUInAppMsgViewSettings.h"
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef void (^InAppMsgPrepareCompletionBlock)(InAppMsgWrapper* wrapper);

@protocol NUJSExport <JSExport>
-(void)trackEvent: (NSString*) eventString;
@end

@interface InAppMessageWrapperBuilder : NSObject <WKUIDelegate, NUJSExport>

-(instancetype)initWithCompetion: (InAppMsgPrepareCompletionBlock) completion;
-(void) prepare:(InAppMessage* ) message;

@end


