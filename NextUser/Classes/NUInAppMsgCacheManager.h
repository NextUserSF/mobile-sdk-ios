////
////  NUInAppMsgCacheManager.h
////  Pods
////
////  Created by Adrian Lazea on 29/08/2017.
////
////
//
//
#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"
#import "NUCache.h"
#import "NUInAppMessage.h"

@interface NUInAppMsgCacheManager : NSObject

- (instancetype)initWithCache:(NUCache*) cache;
- (void) cacheMessages:(NSArray<InAppMessage* >*) messages;
- (InAppMessage* ) fetchMessage:(NSString *) iamID;
- (void) clearAll;
- (void) cacheMessage:(InAppMessage* ) message;
- (void) updateMessage:(InAppMessage* ) message withRemoval:(BOOL) remove;
- (void) setPendingMessage:(InAppMessage* ) message;
- (InAppMessage* ) getPendingMessage;
- (void) clearPendingMessage;

@end
