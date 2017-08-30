

#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"
#import "NUWorkflow.h"
#import "NUInAppMessage.h"

@interface NUJSONTransformer : NSObject

+ (NSMutableArray<InAppMessage* >*) toInAppMessages:(id) messagesJSONArray;
+ (NSMutableArray<Workflow* >*) toWorkflows:(id) workflowsJSONArray;


+ (id) toInAppMessagesJSON:(NSArray<InAppMessage* >*) messages;
+ (id) toInAppMessageJSON:(InAppMessage* ) message;
+ (InAppMessage* ) toInAppMessage:(id) messageJSON;


@end
