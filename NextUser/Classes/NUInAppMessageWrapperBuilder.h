#import <Foundation/Foundation.h>
#import "NUInAppMsgWrapper.h"
#import "NUInAppMsgViewSettings.h"
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "NUWebViewHelper.h"

typedef void (^InAppMsgPrepareCompletionBlock)(InAppMsgWrapper* wrapper);

@interface InAppMessageWrapperBuilder : NSObject <WKUIDelegate>

-(instancetype)initWithCompetion: (InAppMsgPrepareCompletionBlock) completion;
-(void) prepare:(InAppMessage* ) message;

@end


