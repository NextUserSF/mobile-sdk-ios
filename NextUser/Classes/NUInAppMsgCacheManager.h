#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"
#import "NUCache.h"
#import "NUInAppMessage.h"

@interface InAppMsgCacheManager : NSObject

- (void) cacheMessages:(NSArray<InAppMessage* >*) messages;
- (InAppMessage* ) fetchMessage:(NSString *) iamID;
- (NSString *) getNextMessageID;
- (void) cacheMessage:(InAppMessage* ) message;
- (void) onMessageDismissed:(NSString* ) messageID;

- (NSString *) getNextSHAKey;
- (void) removeSha:(NSString *) sha;
- (void) addNewSha:(NSString *) sha;

@end
