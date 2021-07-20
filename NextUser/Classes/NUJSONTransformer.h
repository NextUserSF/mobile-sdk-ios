#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"
#import "NUInAppMessage.h"
#import "NUCart.h"

@interface NUJSONTransformer : NSObject

+ (NSMutableArray<InAppMessage* >*) toInAppMessages:(id) messagesJSONArray;
+ (id) toInAppMessagesJSON:(NSArray<InAppMessage* >*) messages;
+ (id) toInAppMessageJSON:(InAppMessage* ) message;
+ (InAppMessage* ) toInAppMessage:(id) messageJSON;
+ (NUCart *) toNUCart:(id)cartJSON;
+ (NSMutableArray<NSString*> *) toLastBrowsedItems:(id)arrayJSON;

@end
